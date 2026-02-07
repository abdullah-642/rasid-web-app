import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logic.dart';
import '../business_logic.dart'; // Import Business Logic
import '../models.dart';
import '../theme.dart';
import '../utils.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final user = ref.watch(authProvider);
    final userName = user?.userMetadata?['full_name'] ?? 'أحمد';
    // const isDark = false; // Force Light/Emerald Clarity

    return Focus(
      autofocus: true,
      child: SingleChildScrollView(
        key: const PageStorageKey('dashboard_scroll'),
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مرحباً، $userName 👋',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'نظرة عامة على وضعك المالي',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Summary Cards Row
            // Business Summary Cards
            Text(
              'أعمال (Business)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final businessBudgets = ref.watch(businessBudgetsProvider);

                final totalBusinessBudget = businessBudgets.fold<double>(
                  0,
                  (sum, b) => sum + b.totalBudget,
                );
                final totalBusinessSpent = businessBudgets.fold<double>(
                  0,
                  (sum, b) => sum + b.totalSpent,
                );
                final businessRemaining =
                    totalBusinessBudget - totalBusinessSpent;

                final isMobile = constraints.maxWidth < 800;
                final children = [
                  _buildSummaryCard(
                    context,
                    'إجمالي المصروفات',
                    '${formatCurrency(totalBusinessSpent)} ر.س',
                    'الأعمال',
                    Icons.trending_down_rounded,
                    AppTheme.error,
                  ),
                  _buildSummaryCard(
                    context,
                    'المتبقي',
                    '${formatCurrency(businessRemaining)} ر.س',
                    businessRemaining >= 0 ? 'متبقي من الميزانية' : 'عجز',
                    Icons.savings_rounded,
                    businessRemaining >= 0 ? AppTheme.success : AppTheme.error,
                  ),
                ];

                if (isMobile) {
                  return Column(
                    children: children
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: e,
                          ),
                        )
                        .toList(),
                  );
                } else {
                  return Row(
                    children: children
                        .map(
                          (e) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: e,
                            ),
                          ),
                        )
                        .toList(),
                  );
                }
              },
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),

            Text(
              'ميزانياتي (Personal)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Personal Summary Cards
            LayoutBuilder(
              builder: (context, constraints) {
                // Get real data from providers
                final budgets = ref.watch(budgetsProvider);
                final transactions = ref.watch(transactionsProvider);

                // Calculate real totals
                final totalBudget = budgets.fold<double>(
                  0,
                  (sum, b) => sum + b.totalAmount,
                );
                final totalSpent = budgets.fold<double>(
                  0,
                  (sum, b) => sum + b.totalSpent,
                );
                final remaining = totalBudget - totalSpent;

                // Simple responsive check
                final isMobile = constraints.maxWidth < 800;
                final children = [
                  _buildSummaryCard(
                    context,
                    'الميزانية الإجمالية',
                    '${formatCurrency(totalBudget)} ر.س',
                    budgets.isEmpty
                        ? 'ابدأ بإضافة ميزانية'
                        : '${budgets.length} ميزانية',
                    Icons.account_balance_wallet_rounded,
                    AppTheme.primaryColor,
                  ),
                  _buildSummaryCard(
                    context,
                    'المصروفات',
                    '${formatCurrency(totalSpent)} ر.س',
                    transactions.isEmpty
                        ? 'لا توجد مصروفات'
                        : '${transactions.length} عملية',
                    Icons.trending_down_rounded,
                    AppTheme.error,
                  ),
                  _buildSummaryCard(
                    context,
                    'الرصيد المتبقي',
                    '${formatCurrency(remaining)} ر.س',
                    remaining >= 0
                        ? 'أنت في المنطقة الآمنة'
                        : 'تحذير: تجاوزت الميزانية',
                    Icons.savings_rounded,
                    remaining >= 0 ? AppTheme.success : AppTheme.error,
                  ),
                ];

                if (isMobile) {
                  return Column(
                    children: children
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: e,
                          ),
                        )
                        .toList(),
                  );
                } else {
                  return Row(
                    children: children
                        .map(
                          (e) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: e,
                            ),
                          ),
                        )
                        .toList(),
                  );
                }
              },
            ),

            const SizedBox(height: 32),

            // Charts & Insights
            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 900;
                if (isDesktop) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildChartSection(context, ref),
                      ),
                      const SizedBox(width: 24),
                      Expanded(flex: 1, child: _buildRightColumn(context)),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildChartSection(context, ref),
                      const SizedBox(height: 24),
                      _buildRightColumn(context),
                    ],
                  );
                }
              },
            ),

            const SizedBox(height: 80),
          ],
        ),
      ), // Close SingleChildScrollView
    ); // Close Focus
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    String sub,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              sub,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(budgetsProvider);

    // Calculate percentages for each budget
    final totalSpent = budgets.fold<double>(0, (sum, b) => sum + b.totalSpent);

    // Generate chart sections dynamically
    final List<PieChartSectionData> sections = [];
    final List<Color> budgetColors = [
      AppTheme.primaryColor,
      const Color(0xFF34D399),
      const Color(0xFF6EE7B7),
      const Color(0xFFFBBF24),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
    ];

    if (budgets.isEmpty) {
      sections.add(
        PieChartSectionData(
          color: Colors.grey.shade200,
          value: 100,
          radius: 40,
          showTitle: false,
        ),
      );
    } else {
      for (var i = 0; i < budgets.length; i++) {
        final budget = budgets[i];
        if (budget.totalSpent > 0) {
          sections.add(
            PieChartSectionData(
              color: budgetColors[i % budgetColors.length],
              value: budget.totalSpent,
              radius: 40,
              showTitle: false,
            ),
          );
        }
      }

      // If no spending yet, show empty chart
      if (sections.isEmpty) {
        sections.add(
          PieChartSectionData(
            color: Colors.grey.shade200,
            value: 100,
            radius: 40,
            showTitle: false,
          ),
        );
      }
    }

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
      ),
      height: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تحليل المصروفات',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: budgets.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.pie_chart_outline,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد بيانات لعرضها',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ابدأ بإضافة ميزانيات ومصروفات',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 4,
                            centerSpaceRadius: 50,
                            sections: sections,
                          ),
                        ),
                      ),
                      const SizedBox(width: 32),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (budgets.isEmpty)
                            _buildLegend(
                              'لا توجد بيانات',
                              Colors.grey.shade200,
                              '100%',
                            )
                          else
                            ...budgets
                                .asMap()
                                .entries
                                .where((e) => e.value.totalSpent > 0)
                                .map((entry) {
                                  final index = entry.key;
                                  final budget = entry.value;
                                  final percentage = totalSpent > 0
                                      ? (budget.totalSpent / totalSpent * 100)
                                            .toStringAsFixed(1)
                                      : '0';
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: _buildLegend(
                                      budget.name,
                                      budgetColors[index % budgetColors.length],
                                      '$percentage%',
                                    ),
                                  );
                                }),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color, String pct) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Text(pct, style: const TextStyle(color: AppTheme.textSecondary)),
      ],
    );
  }

  Widget _buildRightColumn(BuildContext context) {
    return Column(
      children: [
        // AI Insight
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor.withValues(alpha: 0.05),
                Colors.white,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'المساعد الذكي',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Consumer(
                builder: (context, ref, _) {
                  final budgets = ref.watch(budgetsProvider);
                  final transactions = ref.watch(transactionsProvider);
                  final insight = _generateAIInsight(budgets, transactions);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insight,
                        style: const TextStyle(
                          height: 1.6,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () => _showAIAnalysisDialog(context, ref),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          side: const BorderSide(color: AppTheme.primaryColor),
                        ),
                        child: const Text('تفاصيل أكثر'),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Recent Transactions
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'آخر العمليات',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Consumer(
                builder: (context, ref, _) {
                  final transactions = ref.watch(transactionsProvider);
                  final budgets = ref.watch(budgetsProvider);

                  // Filter transactions to show ONLY those belonging to active budgets
                  final activeBudgetIds = budgets.map((b) => b.id).toSet();
                  final existingTransactions = transactions
                      .where((t) => activeBudgetIds.contains(t.budgetId))
                      .toList();

                  final recentTransactions = existingTransactions
                      .take(5)
                      .toList();

                  if (recentTransactions.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 48,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'لا توجد معاملات حديثة',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      for (var i = 0; i < recentTransactions.length; i++) ...[
                        _buildTransactionItem(
                          recentTransactions[i].title,
                          formatCurrency(recentTransactions[i].amount),
                          recentTransactions[i].date,
                        ),
                        if (i < recentTransactions.length - 1)
                          const Divider(height: 24),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(String title, String amount, DateTime date) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.shopping_bag_outlined,
            color: AppTheme.textSecondary,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                'اليوم',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
        Text(
          '- $amount',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const Text(
          ' ر.س',
          style: TextStyle(fontSize: 10, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  // Generate AI insight based on real data
  String _generateAIInsight(
    List<Budget> budgets,
    List<TransactionItem> transactions,
  ) {
    if (budgets.isEmpty) {
      return 'ابدأ بإضافة ميزانيات لتتبع مصروفاتك والحصول على تحليل ذكي!';
    }

    final totalBudget = budgets.fold<double>(
      0,
      (sum, b) => sum + b.totalAmount,
    );
    final totalSpent = budgets.fold<double>(0, (sum, b) => sum + b.totalSpent);
    final percentage = totalBudget > 0 ? (totalSpent / totalBudget * 100) : 0;

    if (transactions.isEmpty) {
      return 'لم تسجل أي مصروفات بعد. ابدأ بتسجيل مصروفاتك للحصول على تحليل دقيق!';
    }

    // Advanced AI Logic
    // 1. Identify Top Spending Category
    final categoryTotals = <String, double>{};
    for (var t in transactions) {
      // Only verify active transactions roughly if passed filtered list, assuming 'transactions' passed here might be raw
      // For insight, let's use all provided transactions, but filtering might be better.
      // Assuming 'budgets' list controls validity.
      final isValid = budgets.any((b) => b.id == t.budgetId);
      if (isValid) {
        categoryTotals[t.category] =
            (categoryTotals[t.category] ?? 0) + t.amount;
      }
    }
    String topCategory = '';
    double topCategoryAmount = 0;
    categoryTotals.forEach((key, value) {
      if (value > topCategoryAmount) {
        topCategoryAmount = value;
        topCategory = key;
      }
    });

    // 2. Day of Month Logic
    final now = DateTime.now();
    final dayOfMonth = now.day;
    final progress = dayOfMonth / 30.0; // Rough month progress
    final expectedSpendingPct = progress * 100;

    String advice = '';
    if (percentage > expectedSpendingPct + 15) {
      advice = 'إنفاقك أسرع من المعتاد لهذا الوقت من الشهر.';
    } else if (percentage < expectedSpendingPct - 10) {
      advice = 'وتيرة إنفاقك ممتازة ومنضبطة!';
    } else {
      advice = 'أنت تسير وفق المعدل الطبيعي.';
    }

    if (percentage < 50) {
      return '✨ أداء ممتاز! أنفقت ${percentage.toStringAsFixed(0)}% فقط. $advice';
    } else if (percentage < 75) {
      return '👍 جيد جداً. أنفقت ${percentage.toStringAsFixed(0)}%. أكثر مصاريفك في "$topCategory". $advice';
    } else if (percentage < 90) {
      return '⚠️ تنبيه: اقتربت من الحد (أنفقت ${percentage.toStringAsFixed(0)}%). حاول تقليل مصاريف "$topCategory".';
    } else {
      return '🚨 خطر! تجاوزت الميزانية أو أوشكت (${percentage.toStringAsFixed(0)}%). عليك التوقف عن الصرف في "$topCategory"!';
    }
  }

  // Show detailed AI analysis dialog
  void _showAIAnalysisDialog(BuildContext context, WidgetRef ref) {
    final budgets = ref.read(budgetsProvider);
    final transactions = ref.read(transactionsProvider);

    final totalBudget = budgets.fold<double>(
      0,
      (sum, b) => sum + b.totalAmount,
    );
    final totalSpent = budgets.fold<double>(0, (sum, b) => sum + b.totalSpent);
    final remaining = totalBudget - totalSpent;

    // Calculate insights
    final insights = <Map<String, dynamic>>[];

    // Budget usage analysis
    for (var budget in budgets) {
      final percentage = budget.totalAmount > 0
          ? (budget.totalSpent / budget.totalAmount * 100)
          : 0;
      final status = percentage >= 90
          ? 'حرج'
          : percentage >= 75
          ? 'تحذير'
          : percentage >= 50
          ? 'جيد'
          : 'ممتاز';

      insights.add({
        'title': budget.name,
        'value': '${percentage.toStringAsFixed(0)}%',
        'status': status,
        'color': percentage >= 90
            ? Colors.red
            : percentage >= 75
            ? Colors.orange
            : AppTheme.success,
      });
    }

    // Recent spending trend
    final recentTransactions = transactions.take(10).toList();
    final avgAmount = recentTransactions.isNotEmpty
        ? recentTransactions.fold<double>(0, (sum, t) => sum + t.amount) /
              recentTransactions.length
        : 0;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: 500,
          constraints: const BoxConstraints(maxHeight: 600),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: AppTheme.primaryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'تحليل ذكي مفصّل',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Summary Cards
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor.withValues(alpha: 0.1),
                      Colors.white,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSummaryItem(
                          'الميزانية',
                          '${formatCurrency(totalBudget)} ر.س',
                          Icons.account_balance_wallet,
                        ),
                        _buildSummaryItem(
                          'المصروف',
                          '${formatCurrency(totalSpent)} ر.س',
                          Icons.trending_down,
                        ),
                        _buildSummaryItem(
                          'المتبقي',
                          '${formatCurrency(remaining)} ر.س',
                          Icons.savings,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'تحليل الميزانيات',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: insights.length,
                  itemBuilder: (context, index) {
                    final insight = insights[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                insight['title'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: (insight['color'] as Color).withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                insight['value'],
                                style: TextStyle(
                                  color: insight['color'],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              insight['status'],
                              style: TextStyle(
                                color: insight['color'],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb, color: AppTheme.primaryColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'متوسط المصروف: ${formatCurrency(avgAmount)} ر.س | المعاملات الأخيرة: ${recentTransactions.length}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}
