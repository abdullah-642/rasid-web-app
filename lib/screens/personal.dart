import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../logic.dart';
import '../models.dart';
import '../theme.dart';
import '../utils.dart';

class PersonalFinanceScreen extends ConsumerWidget {
  const PersonalFinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(budgetsProvider);
    final transactions = ref.watch(transactionsProvider);

    // AI Analysis Logic
    final totalBudget = budgets.fold(0.0, (sum, b) => sum + b.totalAmount);
    final totalSpent = budgets.fold(0.0, (sum, b) => sum + b.totalSpent);
    final spendingPct = totalBudget > 0 ? (totalSpent / totalBudget) : 0.0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Focus(
        autofocus: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Responsive Header
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;

                  if (isMobile) {
                    // 📱 Mobile Layout: Stacked
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'الميزانية والمصاريف',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                      fontSize:
                                          24, // Slightly smaller for mobile
                                    ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: () async {
                                try {
                                  await ref
                                      .read(budgetsProvider.notifier)
                                      .loadBudgets();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'تم تحديث البيانات بنجاح',
                                          style: TextStyle(fontFamily: 'Cairo'),
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  // Ignore error
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'تحكم بمصاريفك بذكاء',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                              ),
                        ),
                        const SizedBox(height: 24),
                        // Actions Row (Full Width Buttons)
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _exportReport(
                                  context,
                                  budgets,
                                  transactions,
                                ),
                                icon: const Icon(Icons.print_rounded, size: 18),
                                label: const Text(
                                  'تصدير',
                                  style: TextStyle(fontSize: 13),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  foregroundColor: AppTheme.textSecondary,
                                  side: BorderSide(
                                    color: Colors.grey.withValues(alpha: 0.2),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    _showAddBudgetDialog(context, ref),
                                icon: const Icon(Icons.add_rounded, size: 18),
                                label: const Text(
                                  'ميزانية جديدة',
                                  style: TextStyle(fontSize: 13),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  } else {
                    // 🖥️ Desktop/Tablet Layout: Row (Original)
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'الميزانية والمصاريف',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimary,
                                      ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.refresh),
                                  onPressed: () async {
                                    await ref
                                        .read(budgetsProvider.notifier)
                                        .loadBudgets();
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'تحكم بمصاريفك بذكاء',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                        Wrap(
                          spacing: 16,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () =>
                                  _exportReport(context, budgets, transactions),
                              icon: const Icon(Icons.print_rounded),
                              label: const Text('تصدير تقرير'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.textSecondary,
                                side: BorderSide(
                                  color: Colors.grey.withValues(alpha: 0.2),
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () =>
                                  _showAddBudgetDialog(context, ref),
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('ميزانية جديدة'),
                              style: ElevatedButton.styleFrom(elevation: 0),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 32),

              // AI Analysis Card
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
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تحليل الذكاء الاصطناعي',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            spendingPct > 1.0
                                ? 'تنبيه: لقد تجاوزت إجمالي ميزانيتك! حاول تقليص المصاريف الغير ضرورية.'
                                : (spendingPct > 0.8
                                      ? 'أنت تقترب من الحد الأقصى للميزانية (${(spendingPct * 100).toStringAsFixed(0)}%). كن حذراً.'
                                      : 'وضعك المالي ممتاز! لقد استهلكت فقط ${(spendingPct * 100).toStringAsFixed(0)}% من الميزانية.'),
                            style: const TextStyle(color: AppTheme.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Budgets Grid
              if (budgets.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(48),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.1),
                    ),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 48,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'لا توجد ميزانيات بعد',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    int crossAxisCount = width > 900
                        ? 3
                        : (width > 600 ? 2 : 1);

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 24,
                        mainAxisSpacing: 24,
                        childAspectRatio: 1.25,
                      ),
                      itemCount: budgets.length,
                      itemBuilder: (context, index) {
                        final budget = budgets[index];
                        return _buildBudgetCard(context, budget, ref);
                      },
                    );
                  },
                ),

              const SizedBox(height: 48),

              const SizedBox(height: 80),
            ],
          ),
        ), // Close SingleChildScrollView
      ), // Close Focus
    );
  }

  Widget _buildBudgetCard(BuildContext context, Budget budget, WidgetRef ref) {
    final progress = budget.totalAmount > 0
        ? (budget.totalSpent / budget.totalAmount)
        : 0.0;
    final isOverBudget = progress > 1.0;
    final color = isOverBudget ? AppTheme.error : AppTheme.primaryColor;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BudgetDetailScreen(budget: budget),
          ),
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.monetization_on_rounded,
                    color: color,
                    size: 24,
                  ),
                ),
                // PDF Export Button
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.picture_as_pdf,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                      tooltip: 'تصدير PDF',
                      onPressed: () {
                        final budgetTransactions = ref
                            .read(transactionsProvider)
                            .where((t) => t.budgetId == budget.id)
                            .toList();
                        _exportBudgetReport(
                          context,
                          budget,
                          budgetTransactions,
                        );
                      },
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_horiz_rounded,
                        color: AppTheme.textSecondary,
                      ),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditBudgetDialog(context, ref, budget);
                        } else if (value == 'delete') {
                          _confirmDeleteBudget(context, ref, budget.id);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('تعديل'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'حذف',
                            style: TextStyle(color: AppTheme.error),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              budget.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            // New Info Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'مستلمه من:',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        budget.receivedFrom.isNotEmpty
                            ? budget.receivedFrom
                            : '-',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'تاريخ الإنشاء:',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        intl.DateFormat('yyyy/MM/dd').format(budget.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              textBaseline: TextBaseline.alphabetic,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              children: [
                Text(
                  formatCurrency(budget.totalSpent),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(' / ', style: TextStyle(color: Colors.grey)),
                Text(
                  formatCurrency(budget.totalAmount),
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const Text(
                  ' ر.س',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress > 1 ? 1 : progress,
                backgroundColor: Colors.grey.withValues(alpha: 0.1),
                color: color,
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Actions ---

  Future<void> _exportReport(
    BuildContext context,
    List<Budget> budgets,
    List<TransactionItem> transactions,
  ) async {
    try {
      final font = await PdfGoogleFonts.cairoRegular();
      final fontBold = await PdfGoogleFonts.cairoBold();
      final logo = await imageFromAssetBundle('assets/logo.jpg');
      final doc = pw.Document();

      // Calculate totals
      final totalBudget = budgets.fold<double>(
        0,
        (sum, b) => sum + b.totalAmount,
      );
      final totalSpent = budgets.fold<double>(
        0,
        (sum, b) => sum + b.totalSpent,
      );
      final remaining = totalBudget - totalSpent;
      final now = DateTime.now();

      doc.addPage(
        pw.MultiPage(
          textDirection: pw.TextDirection.rtl,
          theme: pw.ThemeData.withFont(base: font),
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: pw.BorderRadius.circular(10),
                  border: pw.Border.all(color: PdfColors.grey200),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'راصد',
                          style: pw.TextStyle(
                            fontSize: 32,
                            font: fontBold,
                            color: PdfColors.green900,
                          ),
                        ),
                        pw.Text(
                          'تقرير مالي شامل',
                          style: pw.TextStyle(
                            fontSize: 18,
                            font: font,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          '${intl.DateFormat('yyyy/MM/dd - HH:mm', 'ar').format(now)}',
                          style: pw.TextStyle(
                            fontSize: 12,
                            font: font,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ],
                    ),
                    pw.Container(
                      width: 70,
                      height: 70,
                      child: pw.ClipOval(
                        child: pw.Image(logo, fit: pw.BoxFit.cover),
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 30),

              // Summary Section
              pw.Text(
                'الملخص المالي',
                style: pw.TextStyle(
                  fontSize: 20,
                  font: fontBold,
                  color: PdfColors.green900,
                ),
              ),
              pw.SizedBox(height: 15),

              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 1),
                children: [
                  _buildPdfTableRow(
                    'إجمالي الميزانيات',
                    '${formatCurrency(totalBudget)} ر.س',
                    font,
                    fontBold,
                    isHeader: true,
                  ),
                  _buildPdfTableRow(
                    'إجمالي المصروفات',
                    '${formatCurrency(totalSpent)} ر.س',
                    font,
                    fontBold,
                  ),
                  _buildPdfTableRow(
                    'المتبقي',
                    '${formatCurrency(remaining)} ر.س',
                    font,
                    fontBold,
                    color: remaining >= 0 ? PdfColors.green : PdfColors.red,
                  ),
                ],
              ),

              pw.SizedBox(height: 30),

              // Budgets Section
              pw.Text(
                'تفاصيل الميزانيات (${budgets.length})',
                style: pw.TextStyle(
                  fontSize: 20,
                  font: fontBold,
                  color: PdfColors.green900,
                ),
              ),
              pw.SizedBox(height: 15),

              if (budgets.isEmpty)
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    'لا توجد ميزانيات مسجلة',
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 12,
                      color: PdfColors.grey600,
                    ),
                  ),
                )
              else
                pw.Table(
                  border: pw.TableBorder.all(
                    color: PdfColors.grey300,
                    width: 1,
                  ),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(2),
                    1: const pw.FlexColumnWidth(1.5),
                    2: const pw.FlexColumnWidth(1.5),
                    3: const pw.FlexColumnWidth(1.5),
                  },
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.green100,
                      ),
                      children: [
                        _buildPdfCell('اسم الميزانية', fontBold),
                        _buildPdfCell(
                          'مستلمه من / التاريخ',
                          fontBold,
                        ), // New Column Header
                        _buildPdfCell('المخصص', fontBold),
                        _buildPdfCell('المتبقي', fontBold),
                      ],
                    ),
                    ...budgets.map((b) {
                      final budgetRemaining = b.totalAmount - b.totalSpent;
                      return pw.TableRow(
                        children: [
                          _buildPdfCell(b.name, font),
                          _buildPdfCell(
                            '${b.receivedFrom}\n${intl.DateFormat('yyyy-MM-dd').format(b.createdAt)}',
                            font,
                          ),
                          _buildPdfCell(
                            '${formatCurrency(b.totalAmount)} ر.س',
                            font,
                          ),
                          _buildPdfCell(
                            '${formatCurrency(budgetRemaining)} ر.س',
                            font,
                            color: budgetRemaining >= 0
                                ? PdfColors.green
                                : PdfColors.red,
                          ),
                        ],
                      );
                    }),
                  ],
                ),

              pw.SizedBox(height: 30),

              // Transactions Section
              pw.Text(
                'آخر المصروفات (${transactions.length > 30 ? '30 من ${transactions.length}' : transactions.length})',
                style: pw.TextStyle(
                  fontSize: 20,
                  font: fontBold,
                  color: PdfColors.green900,
                ),
              ),
              pw.SizedBox(height: 15),

              if (transactions.isEmpty)
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    'لا توجد مصروفات مسجلة',
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 12,
                      color: PdfColors.grey600,
                    ),
                  ),
                )
              else
                pw.Table(
                  border: pw.TableBorder.all(
                    color: PdfColors.grey300,
                    width: 1,
                  ),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3),
                    1: const pw.FlexColumnWidth(2),
                    2: const pw.FlexColumnWidth(2),
                  },
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.green100,
                      ),
                      children: [
                        _buildPdfCell('الوصف', fontBold),
                        _buildPdfCell('المبلغ', fontBold),
                        _buildPdfCell('التاريخ', fontBold),
                      ],
                    ),
                    ...transactions.take(30).map((t) {
                      return pw.TableRow(
                        children: [
                          _buildPdfCell(t.title, font),
                          _buildPdfCell(
                            '${formatCurrency(t.amount)} ر.س',
                            font,
                          ),
                          _buildPdfCell(
                            intl.DateFormat('yyyy/MM/dd', 'ar').format(t.date),
                            font,
                          ),
                        ],
                      );
                    }),
                  ],
                ),

              pw.SizedBox(height: 40),

              // Footer
              pw.Divider(color: PdfColors.grey400),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  'تم الانشاء بواسطة تطبيق راصد - ادارة التقارير',
                  style: pw.TextStyle(
                    fontSize: 10,
                    font: font,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
            ];
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save(),
        name:
            'تقرير_مالي_${intl.DateFormat('yyyyMMdd_HHmmss').format(now)}.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تصدير التقرير: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  pw.TableRow _buildPdfTableRow(
    String label,
    String value,
    pw.Font font,
    pw.Font fontBold, {
    bool isHeader = false,
    PdfColor? color,
  }) {
    return pw.TableRow(
      decoration: isHeader
          ? const pw.BoxDecoration(color: PdfColors.green100)
          : null,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          child: pw.Text(
            label,
            style: pw.TextStyle(font: isHeader ? fontBold : font, fontSize: 12),
          ),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          child: pw.Text(
            value,
            style: pw.TextStyle(font: fontBold, fontSize: 12, color: color),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildPdfCell(String text, pw.Font font, {PdfColor? color}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: 11,
          color: color ?? PdfColors.black,
        ),
        textAlign: pw.TextAlign.right,
      ),
    );
  }

  // Export single budget report
  Future<void> _exportBudgetReport(
    BuildContext context,
    Budget budget,
    List<TransactionItem> transactions,
  ) async {
    try {
      final font = await PdfGoogleFonts.cairoRegular();
      final fontBold = await PdfGoogleFonts.cairoBold();
      final logo = await imageFromAssetBundle('assets/logo.jpg');
      final doc = pw.Document();

      final remaining = budget.totalAmount - budget.totalSpent;
      final now = DateTime.now();

      doc.addPage(
        pw.MultiPage(
          textDirection: pw.TextDirection.rtl,
          theme: pw.ThemeData.withFont(base: font),
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: pw.BorderRadius.circular(10),
                  border: pw.Border.all(color: PdfColors.grey200),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'راصد',
                          style: pw.TextStyle(
                            fontSize: 32,
                            font: fontBold,
                            color: PdfColors.green900,
                          ),
                        ),
                        pw.Text(
                          'تقرير ميزانية: ${budget.name}',
                          style: pw.TextStyle(
                            fontSize: 18,
                            font: font,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          '${intl.DateFormat('yyyy/MM/dd - HH:mm', 'ar').format(now)}',
                          style: pw.TextStyle(
                            fontSize: 12,
                            font: font,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ],
                    ),
                    pw.Container(
                      width: 70,
                      height: 70,
                      child: pw.ClipOval(
                        child: pw.Image(logo, fit: pw.BoxFit.cover),
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 30),

              // Summary Section
              pw.Text(
                'الملخص المالي',
                style: pw.TextStyle(
                  fontSize: 20,
                  font: fontBold,
                  color: PdfColors.green900,
                ),
              ),
              pw.SizedBox(height: 15),

              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 1),
                children: [
                  _buildPdfTableRow(
                    'اسم الميزانية',
                    budget.name,
                    font,
                    fontBold,
                    isHeader: true,
                  ),
                  _buildPdfTableRow(
                    'تاريخ الإنشاء',
                    intl.DateFormat('yyyy-MM-dd').format(budget.createdAt),
                    font,
                    fontBold,
                  ),
                  _buildPdfTableRow(
                    'مستلمه من',
                    budget.receivedFrom,
                    font,
                    fontBold,
                  ),
                  _buildPdfTableRow(
                    'المبلغ المخصص',
                    '${formatCurrency(budget.totalAmount)} ر.س',
                    font,
                    fontBold,
                  ),
                  _buildPdfTableRow(
                    'إجمالي المصروفات',
                    '${formatCurrency(budget.totalSpent)} ر.س',
                    font,
                    fontBold,
                  ),
                  _buildPdfTableRow(
                    'المتبقي',
                    '${formatCurrency(remaining)} ر.س',
                    font,
                    fontBold,
                    color: remaining >= 0 ? PdfColors.green : PdfColors.red,
                  ),
                ],
              ),

              pw.SizedBox(height: 30),

              // Transactions Section
              pw.Text(
                'المصروفات (${transactions.length})',
                style: pw.TextStyle(
                  fontSize: 20,
                  font: fontBold,
                  color: PdfColors.green900,
                ),
              ),
              pw.SizedBox(height: 15),

              if (transactions.isEmpty)
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    'لا توجد مصروفات مسجلة',
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 12,
                      color: PdfColors.grey600,
                    ),
                  ),
                )
              else
                pw.Table(
                  border: pw.TableBorder.all(
                    color: PdfColors.grey300,
                    width: 1,
                  ),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3),
                    1: const pw.FlexColumnWidth(2),
                    2: const pw.FlexColumnWidth(2),
                  },
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.green100,
                      ),
                      children: [
                        _buildPdfCell('الوصف', fontBold),
                        _buildPdfCell('المبلغ', fontBold),
                        _buildPdfCell('التاريخ', fontBold),
                      ],
                    ),
                    ...transactions.map((t) {
                      return pw.TableRow(
                        children: [
                          _buildPdfCell(t.title, font),
                          _buildPdfCell(
                            '${formatCurrency(t.amount)} ر.س',
                            font,
                          ),
                          _buildPdfCell(
                            intl.DateFormat('yyyy/MM/dd', 'ar').format(t.date),
                            font,
                          ),
                        ],
                      );
                    }),
                  ],
                ),

              pw.SizedBox(height: 40),

              // Footer
              pw.Divider(color: PdfColors.grey400),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  'تم الانشاء بواسطة تطبيق راصد - ادارة التقارير',
                  style: pw.TextStyle(
                    fontSize: 10,
                    font: font,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
            ];
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save(),
        name:
            'ميزانية_${budget.name}_${intl.DateFormat('yyyyMMdd_HHmmss').format(now)}.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تصدير التقرير: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddBudgetDialog(BuildContext context, WidgetRef ref) {
    _showBudgetDialog(context, ref, null);
  }

  void _showEditBudgetDialog(
    BuildContext context,
    WidgetRef ref,
    Budget budget,
  ) {
    _showBudgetDialog(context, ref, budget);
  }

  void _showBudgetDialog(BuildContext context, WidgetRef ref, Budget? budget) {
    final isEditing = budget != null;
    final nameController = TextEditingController(text: budget?.name);
    final receivedFromController = TextEditingController(
      text: budget?.receivedFrom,
    );
    final amountController = TextEditingController(
      text: budget != null ? formatCurrency(budget.totalAmount) : '',
    );

    DateTime selectedDate = budget?.createdAt ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isEditing ? 'تعديل الميزانية' : 'ميزانية جديدة',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'اسم الميزانية',
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Date Picker
                  InkWell(
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (d != null) {
                        setState(() => selectedDate = d);
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.5),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'تاريخ الإنشاء',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                          Text(
                            intl.DateFormat('yyyy-MM-dd').format(selectedDate),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: receivedFromController,
                    decoration: const InputDecoration(labelText: 'مستلمه من'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(
                      labelText: 'المبلغ المخصص (ر.س)',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                      ThousandsSeparatorInputFormatter(),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      final name = nameController.text;
                      final receivedFrom = receivedFromController.text;
                      final amount =
                          double.tryParse(
                            amountController.text.replaceAll(',', ''),
                          ) ??
                          0;
                      if (name.isNotEmpty && amount > 0) {
                        if (isEditing) {
                          ref
                              .read(budgetsProvider.notifier)
                              .updateBudget(
                                budget.copyWith(
                                  name: name,
                                  totalAmount: amount,
                                  receivedFrom: receivedFrom,
                                ),
                              );
                        } else {
                          final newBudget = Budget(
                            id: DateTime.now().toString(),
                            name: name,
                            totalAmount: amount,
                            totalSpent: 0,
                            type: 'personal',
                            receivedFrom: receivedFrom,
                            createdAt: selectedDate,
                          );

                          // Using async to catch errors
                          () async {
                            try {
                              await ref
                                  .read(budgetsProvider.notifier)
                                  .addBudget(newBudget);
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'تم إضافة الميزانية',
                                      style: TextStyle(fontFamily: 'Cairo'),
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'فشل الحفظ: $e',
                                      style: const TextStyle(
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }();
                        }
                        if (isEditing) {
                          Navigator.pop(context); // Pop for edit case
                        }
                      }
                    },
                    child: Text(isEditing ? 'حفظ التعديلات' : 'إضافة'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmDeleteBudget(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف الميزانية'),
        content: const Text(
          'هل أنت متأكد من حذف هذه الميزانية؟ سيتم حذف جميع العمليات المرتبطة بها.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              // Close dialog first
              Navigator.pop(dialogContext);

              // Delete budget
              await ref.read(budgetsProvider.notifier).deleteBudget(id);

              // Reload both budgets and transactions
              await ref.read(budgetsProvider.notifier).loadBudgets();
              await ref.read(transactionsProvider.notifier).loadTransactions();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم حذف الميزانية بنجاح'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class BudgetDetailScreen extends ConsumerWidget {
  final Budget budget;
  const BudgetDetailScreen({super.key, required this.budget});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref
        .watch(transactionsProvider)
        .where((t) => t.budgetId == budget.id)
        .toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text(budget.name)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Spending Summary
            Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'حالة الاستهلاك',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              formatCurrency(budget.totalSpent),
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              ' من ${formatCurrency(budget.totalAmount)}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: (budget.totalSpent / budget.totalAmount).clamp(
                            0.0,
                            1.0,
                          ),
                          color: AppTheme.primaryColor,
                          backgroundColor: Colors.grey.withValues(alpha: 0.1),
                          minHeight: 12,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Button "Create Task" (was OCR) - Updated per request (re-interpreted as main CTA)
            // Wait, "Make Add Operation button Create Task button". That likely refers to adding a transaction.

            // Transactions List
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'تفاصيل المصاريف',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            if (transactions.isEmpty)
              Padding(
                padding: const EdgeInsets.all(48),
                child: Text(
                  'لا توجد مصاريف',
                  style: TextStyle(color: Colors.grey[400]),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: transactions.length,
                separatorBuilder: (context, index) =>
                    Divider(color: Colors.grey.withValues(alpha: 0.1)),
                itemBuilder: (context, index) {
                  final t = transactions[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      t.title,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    subtitle: Text(
                      intl.DateFormat('yyyy-MM-dd').format(t.date),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${t.amount} ر.س',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert,
                            size: 20,
                            color: Colors.grey,
                          ),
                          onSelected: (val) async {
                            if (val == 'delete') {
                              _confirmDeleteTransaction(
                                context,
                                ref,
                                t,
                                budget,
                              );
                            } else if (val == 'edit') {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.white,
                                isScrollControlled: true,
                                builder: (_) => AddExpenseModal(
                                  budgetId: budget.id,
                                  transaction: t,
                                ),
                              );
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('تعديل'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text(
                                'حذف',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'إنشاء مصروف',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.white,
            isScrollControlled: true,
            builder: (_) => AddExpenseModal(budgetId: budget.id),
          );
        },
      ),
    );
  }

  Future<void> _confirmDeleteTransaction(
    BuildContext context,
    WidgetRef ref,
    TransactionItem t,
    Budget b,
  ) async {
    // إغلاق النافذة المنبثقة أولاً
    Navigator.of(context).pop();

    try {
      // 1. الحذف باستخدام المزود (الذي يتصل بـ Supabase ويعيد تحميل البيانات)
      await ref
          .read(transactionsProvider.notifier)
          .deleteTransaction(t.id, b.id, t.amount);

      // تحديث الميزانية أيضاً
      await ref.read(budgetsProvider.notifier).loadBudgets();

      // 2. رسالة نجاح
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تم حذف المصروف بنجاح',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل الحذف: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

class AddExpenseModal extends ConsumerStatefulWidget {
  final String budgetId;
  final TransactionItem? transaction;
  const AddExpenseModal({super.key, required this.budgetId, this.transaction});
  @override
  ConsumerState<AddExpenseModal> createState() => _AddExpenseModalState();
}

class _AddExpenseModalState extends ConsumerState<AddExpenseModal> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.transaction?.title);
    _amountController = TextEditingController(
      text: widget.transaction != null
          ? formatCurrency(widget.transaction!.amount)
          : '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.transaction != null;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isEditing ? 'تعديل المصروف' : 'إنشاء  (مصروف)',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: 'المبلغ',
              suffixText: 'ر.س',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
              ThousandsSeparatorInputFormatter(),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'الوصف'),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              final amount =
                  double.tryParse(_amountController.text.replaceAll(',', '')) ??
                  0;
              if (amount > 0) {
                if (isEditing) {
                  // Calculate difference for budget update
                  final oldAmount = widget.transaction!.amount;
                  final diff = amount - oldAmount;

                  final updatedItem = TransactionItem(
                    id: widget.transaction!.id,
                    amount: amount,
                    category: widget.transaction!.category,
                    date: widget.transaction!.date,
                    budgetId: widget.transaction!.budgetId,
                    title: _titleController.text.isEmpty
                        ? 'مصروف'
                        : _titleController.text,
                  );

                  ref
                      .read(transactionsProvider.notifier)
                      .updateTransaction(updatedItem);
                  if (diff != 0) {
                    ref
                        .read(budgetsProvider.notifier)
                        .updateSpending(widget.budgetId, diff);
                  }
                } else {
                  final newItem = TransactionItem(
                    id: DateTime.now().toString(),
                    amount: amount,
                    category: 'General',
                    date: DateTime.now(),
                    budgetId: widget.budgetId,
                    title: _titleController.text.isEmpty
                        ? 'مصروف'
                        : _titleController.text,
                  );
                  ref
                      .read(transactionsProvider.notifier)
                      .addTransaction(newItem);
                  ref
                      .read(budgetsProvider.notifier)
                      .updateSpending(widget.budgetId, amount);
                }
                Navigator.pop(context);
              }
            },
            child: Text(isEditing ? 'حفظ التعديلات' : 'حفظ'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
