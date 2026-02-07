import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

// --- Auth Provider ---
final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<User?> {
  AuthNotifier() : super(Supabase.instance.client.auth.currentUser) {
    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      state = event.session?.user;
    });
  }

  Future<void> signIn(String email, String password) async {
    await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signUp(String email, String password, String fullName) async {
    await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }

  Future<void> updateProfile(String fullName) async {
    await Supabase.instance.client.auth.updateUser(
      UserAttributes(data: {'full_name': fullName}),
    );
    // Trigger state update by refreshing user
    state = Supabase.instance.client.auth.currentUser;
  }
}

// --- Budgets Provider ---
final budgetsProvider = StateNotifierProvider<BudgetsNotifier, List<Budget>>((
  ref,
) {
  final notifier = BudgetsNotifier();
  notifier.loadBudgets();
  return notifier;
});

class BudgetsNotifier extends StateNotifier<List<Budget>> {
  BudgetsNotifier() : super([]);

  Future<void> loadBudgets() async {
    try {
      final response = await Supabase.instance.client
          .from('budgets')
          .select()
          .order('created_at', ascending: false);

      // Force reload schema cache if needed by making a dummy request or ignoring

      final data = response as List<dynamic>;
      state = data.map((e) => Budget.fromMap(e)).toList();

      // Calculate spent amount for each budget locally or via join.
      // For simplicity in this iteration, we might need a separate query or View in DB.
      // But let's keep it simple: we will load transactions and sum them up in the UI or here.
      // Better approach for REAL app: Use a Database View 'budgets_with_spent'.
      // For now, we'll assume total_spent is fetched or updated locally.
      // NOTE: standard 'budgets' table doesn't have 'total_spent'. We added it in 'Budget' model.
      // We will perform a fetch on transactions to compute this.

      _loadSpendingForBudgets();
    } catch (e) {
      // debugPrint('Error loading budgets: $e');
      rethrow; // Don't hide the error!
    }
  }

  Future<void> _loadSpendingForBudgets() async {
    // This is not efficient for large data, but fine for MVP
    final transactionsResponse = await Supabase.instance.client
        .from('transactions')
        .select('budget_id, amount');
    final transactions = transactionsResponse as List<dynamic>;

    List<Budget> updatedState = [];
    for (var budget in state) {
      double spent = 0;
      for (var t in transactions) {
        if (t['budget_id'] == budget.id) {
          spent += (t['amount'] as num).toDouble();
        }
      }
      updatedState.add(
        Budget(
          id: budget.id,
          name: budget.name,
          totalAmount: budget.totalAmount,
          totalSpent: spent,
          type: budget.type,
          receivedFrom: budget.receivedFrom,
          createdAt: budget.createdAt,
        ),
      );
    }
    state = updatedState;
  }

  Future<void> addBudget(Budget budget) async {
    // Optimistic Update
    state = [budget, ...state];

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      await Supabase.instance.client
          .from('budgets')
          .insert({
            'user_id': userId,
            'title': budget.name,
            'total_amount': budget.totalAmount,
            'received_from': budget.receivedFrom,
            // 'type': budget.type, // Removed to fix error
          })
          .select()
          .single();

      // Force reload to sync with DB
      await loadBudgets();
    } catch (e) {
      // Revert if error
      state = state.where((b) => b.id != budget.id).toList();
      rethrow;
    }
  }

  Future<void> deleteBudget(String id) async {
    final previousState = state;

    try {
      // Delete from database first (this will cascade delete transactions via DB rules)
      await Supabase.instance.client.from('budgets').delete().eq('id', id);

      // Only update state after successful deletion
      state = state.where((b) => b.id != id).toList();
    } catch (e) {
      // Revert on error
      state = previousState;
      // Log error but don't crash the app
      // debugPrint('Error deleting budget: $e');
    }
  }

  Future<void> updateBudget(Budget budget) async {
    state = [
      for (final b in state)
        if (b.id == budget.id) budget else b,
    ];
    try {
      await Supabase.instance.client
          .from('budgets')
          .update({
            'title': budget.name,
            'total_amount': budget.totalAmount,
            'received_from': budget.receivedFrom,
          })
          .eq('id', budget.id);
    } catch (e) {
      // revert? complex for update, maybe just reload or ignore for MVP
    }
  }

  void updateSpending(String budgetId, double amount) {
    // Optimistic local update
    state = [
      for (final b in state)
        if (b.id == budgetId)
          Budget(
            id: b.id,
            name: b.name,
            totalAmount: b.totalAmount,
            totalSpent: b.totalSpent + amount,
            type: b.type,
            receivedFrom: b.receivedFrom,
            createdAt: b.createdAt,
          )
        else
          b,
    ];
  }
}

// --- Transactions Provider ---
final transactionsProvider =
    StateNotifierProvider<TransactionsNotifier, List<TransactionItem>>((ref) {
      final notifier = TransactionsNotifier();
      notifier.loadTransactions();
      return notifier;
    });

class TransactionsNotifier extends StateNotifier<List<TransactionItem>> {
  TransactionsNotifier() : super([]);

  Future<void> loadTransactions() async {
    try {
      final response = await Supabase.instance.client
          .from('transactions')
          .select()
          .order('date', ascending: false)
          .limit(100);

      final data = response as List<dynamic>;
      state = data.map((e) => TransactionItem.fromMap(e)).toList();
    } catch (e) {
      // debugPrint('Error transactions: $e');
    }
  }

  Future<void> addTransaction(TransactionItem item) async {
    // Optimistic
    state = [item, ...state];

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      await Supabase.instance.client
          .from('transactions')
          .insert({
            'user_id': userId,
            'budget_id': item.budgetId,
            'amount': item.amount,
            'category': item.category,
            'title': item.title,
            'date': item.date.toIso8601String(),
          })
          .select()
          .single();

      // Force reload to guarantee we have the correct ID from DB
      await loadTransactions();
    } catch (e) {
      // Revert optimistic update on error
      state = state.where((t) => t.id != item.id).toList();
      rethrow;
    }
  }

  Future<void> deleteTransaction(
    String id,
    String budgetId,
    double amount,
  ) async {
    final previousState = state;

    try {
      // Delete from database first
      await Supabase.instance.client.from('transactions').delete().eq('id', id);

      // Only update state after successful deletion
      state = state.where((t) => t.id != id).toList();
    } catch (e) {
      // Revert on error
      state = previousState;
      // Rethrow to let UI know it failed
      rethrow;
    }
  }

  Future<void> updateTransaction(TransactionItem item) async {
    state = [
      for (final t in state)
        if (t.id == item.id) item else t,
    ];
    try {
      await Supabase.instance.client
          .from('transactions')
          .update({
            'amount': item.amount,
            'title': item.title,
            'category': item.category,
            // 'date': item.date.toIso8601String(), // Optional: if date is editable
          })
          .eq('id', item.id);
    } catch (e) {
      // Revert or reload
    }
  }
}

// --- Tasks Provider ---
final tasksProvider = StateNotifierProvider<TasksNotifier, List<Tasks>>((ref) {
  final notifier = TasksNotifier();
  notifier.loadTasks();
  return notifier;
});

class TasksNotifier extends StateNotifier<List<Tasks>> {
  TasksNotifier() : super([]);

  Future<void> loadTasks() async {
    try {
      final response = await Supabase.instance.client
          .from('tasks')
          .select()
          .order('due_date', ascending: true);

      final data = response as List<dynamic>;
      state = data.map((e) => Tasks.fromMap(e)).toList();
    } catch (e) {
      // error
    }
  }

  Future<void> addTask(Tasks task) async {
    state = [task, ...state];
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final response = await Supabase.instance.client
          .from('tasks')
          .insert({
            'user_id': userId,
            'title': task.title,
            'due_date': task.dueDateString(), // Helper if needed or just iso
            'priority': task.priority,
            'is_completed': task.isCompleted,
          })
          .select()
          .single();

      final realTask = Tasks.fromMap(response);
      state = [realTask, ...state.where((t) => t.id != task.id)];

      // Webhook Logic for specific user
      final user = Supabase.instance.client.auth.currentUser;
      if (user?.email == 'kingmr642@gmail.com') {
        try {
          http.post(
            Uri.parse(
              'https://n8n.alqamuh.com/webhook/8ec6fd3b-659a-49c5-a07e-2bc7fc8826c7',
            ),
            body: {
              'task_title': realTask.title,
              'due_date_date':
                  "${realTask.dueDate.year}-${realTask.dueDate.month.toString().padLeft(2, '0')}-${realTask.dueDate.day.toString().padLeft(2, '0')}",
              'due_date_time':
                  "${realTask.dueDate.hour.toString().padLeft(2, '0')}:${realTask.dueDate.minute.toString().padLeft(2, '0')}",
              'priority': realTask.priority,
              'created_at': DateTime.now().toIso8601String(),
              'user_email': user!.email!,
            },
          );
        } catch (e) {
          // Ignore webhook errors
        }
      } else if (user?.email == 'sharoofy16@gmail.com') {
        try {
          final prefs = await SharedPreferences.getInstance();
          final webhookUrl =
              prefs.getString('sharoofy_webhook') ??
              'https://n8n.alqamuh.com/webhook/8ec6fd3b-659a-49c5-a07e-2bc7fc8826c7';

          http.post(
            Uri.parse(webhookUrl),
            body: {
              'task_title': realTask.title,
              'due_date_date':
                  "${realTask.dueDate.year}-${realTask.dueDate.month.toString().padLeft(2, '0')}-${realTask.dueDate.day.toString().padLeft(2, '0')}",
              'due_date_time':
                  "${realTask.dueDate.hour.toString().padLeft(2, '0')}:${realTask.dueDate.minute.toString().padLeft(2, '0')}",
              'priority': realTask.priority,
              'created_at': DateTime.now().toIso8601String(),
              'user_email': user!.email!,
            },
          );
        } catch (e) {
          // Ignore webhook errors
        }
      }
    } catch (e) {
      state = state.where((t) => t.id != task.id).toList();
    }
  }

  Future<void> deleteAllTasks() async {
    final previousState = state;
    state = [];
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      await Supabase.instance.client
          .from('tasks')
          .delete()
          .eq('user_id', userId);
    } catch (e) {
      state = previousState;
      rethrow;
    }
  }

  Future<void> toggleTask(String id) async {
    // Find task
    final task = state.firstWhere((t) => t.id == id);
    final newState = !task.isCompleted;

    // Optimistic
    state = [
      for (final t in state)
        if (t.id == id)
          Tasks(
            id: t.id,
            title: t.title,
            dueDate: t.dueDate,
            priority: t.priority,
            isCompleted: newState,
          )
        else
          t,
    ];

    try {
      await Supabase.instance.client
          .from('tasks')
          .update({'is_completed': newState})
          .eq('id', id);
    } catch (e) {
      // revert
    }
  }

  Future<void> deleteTask(String id) async {
    final previousState = state;
    state = state.where((t) => t.id != id).toList();
    try {
      await Supabase.instance.client.from('tasks').delete().eq('id', id);
    } catch (e) {
      state = previousState;
    }
  }

  Future<void> updateTask(Tasks task) async {
    state = [
      for (final t in state)
        if (t.id == task.id) task else t,
    ];

    try {
      await Supabase.instance.client
          .from('tasks')
          .update({
            'title': task.title,
            'due_date': task.dueDate.toIso8601String(),
            'priority': task.priority,
            'is_completed': task.isCompleted,
          })
          .eq('id', task.id);
    } catch (e) {
      // revert?
    }
  }
}

extension on Tasks {
  String dueDateString() => dueDate.toIso8601String();
}
