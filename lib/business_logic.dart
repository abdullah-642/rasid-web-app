import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'models.dart';

// Use a FutureProvider or similar for simple lists, but StateNotifier is better for CRUD
final businessBudgetsProvider =
    StateNotifierProvider<BusinessBudgetsNotifier, List<BusinessBudget>>((ref) {
      final notifier = BusinessBudgetsNotifier();
      notifier.loadBudgets();
      return notifier;
    });

class BusinessBudgetsNotifier extends StateNotifier<List<BusinessBudget>> {
  BusinessBudgetsNotifier() : super([]);

  Future<void> loadBudgets() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        state = [];
        return;
      }

      // Explicitly filter by user_id AND order by created_at
      final response = await Supabase.instance.client
          .from('business_budgets')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;

      // Parse safely, logging any errors but keeping good records
      List<BusinessBudget> loaded = [];
      for (var item in data) {
        try {
          loaded.add(BusinessBudget.fromMap(item));
        } catch (e) {
          print('Error parsing budget item: $e (Item: $item)');
        }
      }

      if (loaded.isEmpty && data.isNotEmpty) {
        print('Warning: Fetched ${data.length} records but parsed 0.');
      }

      // Load spending safely
      List<dynamic> expenses = [];
      try {
        final expensesResponse = await Supabase.instance.client
            .from('business_expenses')
            .select('budget_id, amount');
        expenses = expensesResponse as List<dynamic>;
      } catch (e) {
        print('Error loading expenses: $e');
      }

      List<BusinessBudget> withSpending = [];
      for (var b in loaded) {
        double spent = 0;
        for (var e in expenses) {
          try {
            if (e['budget_id'] == b.id) {
              spent += (e['amount'] as num).toDouble();
            }
          } catch (_) {}
        }
        withSpending.add(b.copyWith(totalSpent: spent));
      }

      state = withSpending;
    } catch (e, stack) {
      print('CRITICAL Error loading business budgets: $e');
      print(stack);
    }
  }

  Future<void> addBudget(BusinessBudget budget) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('الرجاء تسجيل الدخول أولاً');

      // 1. Fetch Chat ID from Profile
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('telegram_chat_id')
          .eq('id', userId)
          .maybeSingle();

      final chatId = profile?['telegram_chat_id'] as String?;

      if (chatId == null || chatId.isEmpty) {
        throw Exception(
          'الرجاء ضبط معرف المحاسب (Telegram Chat ID) في الملف الشخصي أولاً.',
        );
      }

      await Supabase.instance.client.from('business_budgets').insert({
        'user_id': userId,
        'name': budget.name,
        'main_budget': budget.mainBudget,
        'reserve_budget': budget.reserveBudget,
        'alert_threshold': budget.alertThreshold,
        'accountant_chat_id': chatId, // Fetched from profile
      });
      await loadBudgets();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateBudget(BusinessBudget budget) async {
    try {
      await Supabase.instance.client
          .from('business_budgets')
          .update({
            'name': budget.name,
            'main_budget': budget.mainBudget,
            'reserve_budget': budget.reserveBudget,
            'alert_threshold': budget.alertThreshold,
          })
          .eq('id', budget.id);
      await loadBudgets();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteBudget(String budgetId) async {
    try {
      await Supabase.instance.client
          .from('business_budgets')
          .delete()
          .eq('id', budgetId);
      await loadBudgets();
    } catch (e) {
      rethrow;
    }
  }

  // Reload single budget
  Future<void> reloadBudget(String budgetId) async {
    // Ideally just fetch one, but full reload is safer for MVP consistency
    await loadBudgets();
  }
}

final businessExpensesProvider =
    StateNotifierProvider<BusinessExpensesNotifier, List<BusinessExpense>>((
      ref,
    ) {
      return BusinessExpensesNotifier(ref);
    });

class BusinessExpensesNotifier extends StateNotifier<List<BusinessExpense>> {
  final Ref ref;
  BusinessExpensesNotifier(this.ref) : super([]);

  Future<void> loadExpenses(String budgetId) async {
    try {
      final response = await Supabase.instance.client
          .from('business_expenses')
          .select()
          .eq('budget_id', budgetId)
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;
      state = data.map((e) => BusinessExpense.fromMap(e)).toList();
    } catch (e) {
      // error
    }
  }

  Future<void> addExpense(
    BusinessExpense expense,
    BusinessBudget budget,
  ) async {
    // 1. Insert Expense
    try {
      await Supabase.instance.client.from('business_expenses').insert({
        'budget_id': expense.budgetId,
        'amount': expense.amount,
        'platform': expense.platform,
        'notes': expense.notes,
        'tax_amount': expense.taxAmount,
      });

      // 2. Update Local State (Budget Spending)
      // Calculate new totals
      final newTotalSpent = budget.totalSpent + expense.amount;
      final newRemaining = budget.totalBudget - newTotalSpent;

      // 3. Logic & Automation (Zero-Click Alert)
      if (newRemaining <= budget.alertThreshold && !budget.isAlertSent) {
        // Trigger Webhook
        try {
          final url = Uri.parse(
            'https://n8n.alqamuh.com/webhook/ff53e1c5-02df-4276-aea9-962fda4e13aa',
          );

          // Fire and forget? Better to await to ensure it runs, but don't block UI too long.
          // We await it here.
          await http.post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "chat_id": budget.accountantChatId,
              "budget_name": budget.name,
              "main_budget": budget.mainBudget,
              "reserve_budget": budget.reserveBudget,
              "total_spent": newTotalSpent,
              "remaining": newRemaining,
            }),
          );

          // Update DB
          await Supabase.instance.client
              .from('business_budgets')
              .update({'is_alert_sent': true})
              .eq('id', budget.id);
        } catch (e) {
          // Log webhook failure
        }
      }

      // Refresh Data
      await loadExpenses(expense.budgetId);
      ref.read(businessBudgetsProvider.notifier).reloadBudget(budget.id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteExpense(String expenseId, String budgetId) async {
    try {
      await Supabase.instance.client
          .from('business_expenses')
          .delete()
          .eq('id', expenseId);

      // Refresh both lists to update totals
      await loadExpenses(budgetId);
      ref.read(businessBudgetsProvider.notifier).reloadBudget(budgetId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateExpense(
    BusinessExpense expense,
    BusinessBudget budget,
  ) async {
    try {
      await Supabase.instance.client
          .from('business_expenses')
          .update({
            'amount': expense.amount,
            'platform': expense.platform,
            'notes': expense.notes,
            'tax_amount': expense.taxAmount,
          })
          .eq('id', expense.id);

      // Refresh
      await loadExpenses(expense.budgetId);
      ref.read(businessBudgetsProvider.notifier).reloadBudget(budget.id);
    } catch (e) {
      rethrow;
    }
  }
}
