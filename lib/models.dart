class Budget {
  final String id;
  final String name;
  final double totalAmount;
  final double totalSpent;
  final String type; // 'personal', 'business'
  final String receivedFrom;
  final DateTime createdAt;

  Budget({
    required this.id,
    required this.name,
    required this.totalAmount,
    required this.totalSpent,
    required this.type,
    required this.receivedFrom,
    required this.createdAt,
  });

  double get remaining => totalAmount - totalSpent;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': name, // Mapped to DB column 'title'
      'total_amount': totalAmount,
      'total_spent': totalSpent,
      'received_from': receivedFrom,
      'created_at': createdAt.toIso8601String(),
      // 'type': type, // Temporarily removed to fix DB error
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] ?? '',
      name: map['title'] ?? '', // Mapped from DB column 'title'
      totalAmount: (map['total_amount'] ?? 0).toDouble(),
      totalSpent: (map['total_spent'] ?? 0).toDouble(),
      type: map['type'] ?? 'personal',
      receivedFrom: map['received_from'] ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }
  Budget copyWith({
    String? id,
    String? name,
    double? totalAmount,
    double? totalSpent,
    String? type,
    String? receivedFrom,
    DateTime? createdAt,
  }) {
    return Budget(
      id: id ?? this.id,
      name: name ?? this.name,
      totalAmount: totalAmount ?? this.totalAmount,
      totalSpent: totalSpent ?? this.totalSpent,
      type: type ?? this.type,
      receivedFrom: receivedFrom ?? this.receivedFrom,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class TransactionItem {
  final String id;
  final double amount;
  final String category;
  final DateTime date;
  final String budgetId;
  final String title;

  TransactionItem({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    required this.budgetId,
    required this.title,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'budget_id': budgetId,
      'title': title,
    };
  }

  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      id: map['id'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      category: map['category'] ?? 'General',
      date: DateTime.parse(map['date']),
      budgetId: map['budget_id'] ?? '',
      title: map['title'] ?? '',
    );
  }
}

class Tasks {
  // Renamed from Task to Tasks to avoid conflict with dart:async FutureTask or similar if any, but clear enough
  final String id;
  final String title;
  final DateTime dueDate;
  final String priority; // 'High', 'Medium', 'Low'
  final bool isCompleted;

  Tasks({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.priority,
    required this.isCompleted,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'due_date': dueDate.toIso8601String(),
      'priority': priority,
      'is_completed': isCompleted,
    };
  }

  factory Tasks.fromMap(Map<String, dynamic> map) {
    return Tasks(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      dueDate: DateTime.parse(map['due_date']),
      priority: map['priority'] ?? 'Medium',
      isCompleted: map['is_completed'] ?? false,
    );
  }
}

class CustodyWallet {
  final String employeeId;
  final String employeeName;
  final double currentBalance;

  CustodyWallet({
    required this.employeeId,
    required this.employeeName,
    required this.currentBalance,
  });
}

// --- Business Module Models ---

class BusinessBudget {
  final String id;
  final String name;
  final double mainBudget;
  final double reserveBudget;
  final double alertThreshold;
  final String accountantChatId;
  final bool isAlertSent;
  final DateTime createdAt;
  final double totalSpent; // Computed on fetch

  double get totalBudget => mainBudget + reserveBudget;
  double get remaining => totalBudget - totalSpent;

  BusinessBudget({
    required this.id,
    required this.name,
    required this.mainBudget,
    required this.reserveBudget,
    required this.alertThreshold,
    required this.accountantChatId,
    required this.isAlertSent,
    required this.createdAt,
    this.totalSpent = 0.0,
  });

  factory BusinessBudget.fromMap(Map<String, dynamic> map) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return BusinessBudget(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      mainBudget: parseDouble(map['main_budget']),
      reserveBudget: parseDouble(map['reserve_budget']),
      alertThreshold: parseDouble(map['alert_threshold']),
      accountantChatId: map['accountant_chat_id'] ?? '',
      isAlertSent: map['is_alert_sent'] ?? false,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }

  BusinessBudget copyWith({
    String? name,
    double? mainBudget,
    double? reserveBudget,
    double? alertThreshold,
    double? totalSpent,
    bool? isAlertSent,
  }) {
    return BusinessBudget(
      id: id,
      name: name ?? this.name,
      mainBudget: mainBudget ?? this.mainBudget,
      reserveBudget: reserveBudget ?? this.reserveBudget,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      accountantChatId: accountantChatId,
      isAlertSent: isAlertSent ?? this.isAlertSent,
      createdAt: createdAt,
      totalSpent: totalSpent ?? this.totalSpent,
    );
  }
}

class BusinessExpense {
  final String id;
  final String budgetId;
  final double amount;
  final String platform; // Snapchat, TikTok, etc.
  final String notes;
  final DateTime createdAt;
  final double taxAmount;

  BusinessExpense({
    required this.id,
    required this.budgetId,
    required this.amount,
    required this.platform,
    required this.notes,
    required this.createdAt,
    this.taxAmount = 0.0,
  });

  factory BusinessExpense.fromMap(Map<String, dynamic> map) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return BusinessExpense(
      id: map['id'] ?? '',
      budgetId: map['budget_id'] ?? '',
      amount: parseDouble(map['amount']),
      platform: map['platform'] ?? 'Other',
      notes: map['notes'] ?? '',
      taxAmount: parseDouble(map['tax_amount']),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }

  BusinessExpense copyWith({
    double? amount,
    String? platform,
    String? notes,
    double? taxAmount,
  }) {
    return BusinessExpense(
      id: id,
      budgetId: budgetId,
      amount: amount ?? this.amount,
      platform: platform ?? this.platform,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      taxAmount: taxAmount ?? this.taxAmount,
    );
  }
}
