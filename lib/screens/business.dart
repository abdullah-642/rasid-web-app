import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import '../models.dart';
import '../business_logic.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../utils.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class BusinessScreen extends ConsumerStatefulWidget {
  const BusinessScreen({super.key});

  @override
  ConsumerState<BusinessScreen> createState() => _BusinessScreenState();
}

class _BusinessScreenState extends ConsumerState<BusinessScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(businessBudgetsProvider.notifier).loadBudgets();
    });
  }

  @override
  Widget build(BuildContext context) {
    final budgets = ref.watch(businessBudgetsProvider);

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
                    // Mobile Layout
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'إدارة ميزانية الأعمال',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                      fontSize: 24,
                                    ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: () async {
                                await ref
                                    .read(businessBudgetsProvider.notifier)
                                    .loadBudgets();
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'تحكم بمصاريف أعمالك بذكاء',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                              ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => _exportReport(
                                  context,
                                  ref.read(businessBudgetsProvider),
                                ),
                                icon: const Icon(Icons.print_rounded, size: 18),
                                label: const Text('تصدير تقرير'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  foregroundColor: AppTheme.textSecondary,
                                  side: BorderSide(
                                    color: Colors.grey.withValues(alpha: 0.2),
                                  ),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () => _showAddBudgetDialog(context),
                                icon: const Icon(Icons.add_rounded, size: 18),
                                label: const Text('ميزانية جديدة'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  } else {
                    // Desktop Layout
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'إدارة ميزانية الأعمال',
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
                                        .read(businessBudgetsProvider.notifier)
                                        .loadBudgets();
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'تحكم بمصاريف أعمالك بذكاء',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                        Wrap(
                          spacing: 16,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => _exportReport(
                                context,
                                ref.read(businessBudgetsProvider),
                              ),
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
                              onPressed: () => _showAddBudgetDialog(context),
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
                  child: Column(
                    children: [
                      const Icon(
                        Icons.business_center_outlined,
                        size: 48,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'لا توجد ميزانيات أعمال بعد',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
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
                        return _buildBusinessBudgetCard(context, budget);
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBusinessBudgetCard(BuildContext context, BusinessBudget budget) {
    final progress = budget.totalBudget > 0
        ? (budget.totalSpent / budget.totalBudget)
        : 0.0;

    // Alert logic: if remaining <= alert_threshold
    final isWarning = budget.remaining <= budget.alertThreshold;
    final color = isWarning ? Colors.orange : AppTheme.primaryColor;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BusinessBudgetDetailsScreen(budget: budget),
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
                    Icons.business_center_rounded,
                    color: color,
                    size: 24,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.picture_as_pdf,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                      tooltip: 'تصدير PDF',
                      onPressed: () async {
                        // Load expenses for this budget first to ensure we have data
                        try {
                          await ref
                              .read(businessExpensesProvider.notifier)
                              .loadExpenses(budget.id);
                          final expenses = ref.read(
                            businessExpensesProvider,
                          ); // This might be stale if triggered immediately, better specific fetch?
                          // Actually the provider state matches the last load call.
                          // But since expenses are per budget, calling loadExpenses updates the state to THIS budget's expenses.
                          if (context.mounted) {
                            _exportBudgetReport(context, budget, expenses);
                          }
                        } catch (e) {
                          // show error
                        }
                      },
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_horiz_rounded,
                        color: AppTheme.textSecondary,
                      ),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditBudgetDialog(context, budget);
                        } else if (value == 'delete') {
                          _confirmDeleteBudget(context, budget);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18),
                              SizedBox(width: 8),
                              Text('تعديل'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('حذف', style: TextStyle(color: Colors.red)),
                            ],
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
            // Info Section
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
                        'Acc ID:',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          budget.accountantChatId.isNotEmpty
                              ? budget.accountantChatId
                              : '-',
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'التاريخ:',
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
                  formatCurrency(budget.totalBudget),
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

  void _showAddBudgetDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final mainCtrl = TextEditingController();
    final reserveCtrl = TextEditingController();
    final alertCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'إضافة ميزانية أعمال',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'اسم الميزانية',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.label_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: mainCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'الميزانية الرئيسية',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                  ThousandsSeparatorInputFormatter(),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reserveCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'الميزانية الاحتياطية',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.savings_outlined),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                  ThousandsSeparatorInputFormatter(),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: alertCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'حد التنبيه (Alert Threshold)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.notifications_outlined),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                  ThousandsSeparatorInputFormatter(),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty) return;

              final budget = BusinessBudget(
                id: '',
                name: nameCtrl.text,
                mainBudget:
                    double.tryParse(mainCtrl.text.replaceAll(',', '')) ?? 0,
                reserveBudget:
                    double.tryParse(reserveCtrl.text.replaceAll(',', '')) ?? 0,
                alertThreshold:
                    double.tryParse(alertCtrl.text.replaceAll(',', '')) ?? 0,
                accountantChatId: '', // Will be fetched by provider
                isAlertSent: false,
                createdAt: DateTime.now(),
              );

              try {
                await ref
                    .read(businessBudgetsProvider.notifier)
                    .addBudget(budget);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تمت إضافة الميزانية بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('خطأ'),
                      content: Text(e.toString().replaceAll('Exception: ', '')),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('موافق'),
                        ),
                      ],
                    ),
                  );
                }
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showEditBudgetDialog(BuildContext context, BusinessBudget budget) {
    final nameCtrl = TextEditingController(text: budget.name);
    final mainCtrl = TextEditingController(
      text: intl.NumberFormat('#,###').format(budget.mainBudget),
    );
    final reserveCtrl = TextEditingController(
      text: intl.NumberFormat('#,###').format(budget.reserveBudget),
    );
    final alertCtrl = TextEditingController(
      text: intl.NumberFormat('#,###').format(budget.alertThreshold),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'تعديل الميزانية',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'اسم الميزانية',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: mainCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'الميزانية الرئيسية',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                  ThousandsSeparatorInputFormatter(),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reserveCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'الميزانية الاحتياطية',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                  ThousandsSeparatorInputFormatter(),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: alertCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'حد التنبيه',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                  ThousandsSeparatorInputFormatter(),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty) return;

              final updatedBudget = budget.copyWith(
                name: nameCtrl.text,
                mainBudget:
                    double.tryParse(mainCtrl.text.replaceAll(',', '')) ?? 0,
                reserveBudget:
                    double.tryParse(reserveCtrl.text.replaceAll(',', '')) ?? 0,
                alertThreshold:
                    double.tryParse(alertCtrl.text.replaceAll(',', '')) ?? 0,
              );

              try {
                await ref
                    .read(businessBudgetsProvider.notifier)
                    .updateBudget(updatedBudget);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم تحديث الميزانية بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                // error handling
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteBudget(BuildContext context, BusinessBudget budget) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الميزانية'),
        content: const Text(
          'هل أنت متأكد من أنك تريد حذف هذه الميزانية؟ سيتم حذف جميع المصروفات المرتبطة بها.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ref
                    .read(businessBudgetsProvider.notifier)
                    .deleteBudget(budget.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم حذف الميزانية بنجاح'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                // error
              }
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // --- Debug Logic ---

  // --- PDF Export Logic ---

  Future<void> _exportReport(
    BuildContext context,
    List<BusinessBudget> budgets,
  ) async {
    try {
      final font = await PdfGoogleFonts.cairoRegular();
      final fontBold = await PdfGoogleFonts.cairoBold();
      final logo = await imageFromAssetBundle('assets/logo.jpg');
      final doc = pw.Document();

      final totalBudgets = budgets.fold<double>(
        0,
        (sum, b) => sum + b.totalBudget,
      );
      final totalSpent = budgets.fold<double>(
        0,
        (sum, b) => sum + b.totalSpent,
      );
      final remaining = totalBudgets - totalSpent;

      doc.addPage(
        pw.MultiPage(
          textDirection: pw.TextDirection.rtl,
          theme: pw.ThemeData.withFont(base: font),
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              _buildPdfHeader('تقرير ميزانيات الأعمال', logo, font, fontBold),
              pw.SizedBox(height: 30),
              pw.Text(
                'ملخص الأعمال',
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
                    '${formatCurrency(totalBudgets)} ر.س',
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
              pw.Text(
                'تفاصيل الميزانيات',
                style: pw.TextStyle(
                  fontSize: 18,
                  font: fontBold,
                  color: PdfColors.blueGrey800,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 1),
                children: [
                  // Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey100,
                    ),
                    children: [
                      _buildPdfCell('اسم الميزانية', fontBold, isHeader: true),
                      _buildPdfCell('الميزانية', fontBold, isHeader: true),
                      _buildPdfCell('المصروف', fontBold, isHeader: true),
                      _buildPdfCell('المتبقي', fontBold, isHeader: true),
                    ],
                  ),
                  ...budgets.map((b) {
                    return pw.TableRow(
                      children: [
                        _buildPdfCell(b.name, font),
                        _buildPdfCell(formatCurrency(b.totalBudget), font),
                        _buildPdfCell(formatCurrency(b.totalSpent), font),
                        _buildPdfCell(
                          formatCurrency(b.remaining),
                          font,
                          color: b.remaining >= 0
                              ? PdfColors.green
                              : PdfColors.red,
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ];
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) async => doc.save(),
        name: 'business_report.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('فشل التصدير: $e')));
      }
    }
  }

  Future<void> _exportBudgetReport(
    BuildContext context,
    BusinessBudget budget,
    List<BusinessExpense> expenses,
  ) async {
    try {
      final font = await PdfGoogleFonts.cairoRegular();
      final fontBold = await PdfGoogleFonts.cairoBold();
      final logo = await imageFromAssetBundle('assets/logo.jpg');
      final doc = pw.Document();

      doc.addPage(
        pw.MultiPage(
          textDirection: pw.TextDirection.rtl,
          theme: pw.ThemeData.withFont(base: font),
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              _buildPdfHeader(
                'تقرير ميزانية: ${budget.name}',
                logo,
                font,
                fontBold,
              ),
              pw.SizedBox(height: 20),
              // Budget Info - Updated Layout
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCol(
                          'الميزانية الرئيسية',
                          budget.mainBudget,
                          font,
                          fontBold,
                        ),
                        _buildStatCol(
                          'الميزانية الاحتياطية',
                          budget.reserveBudget,
                          font,
                          fontBold,
                        ),
                        _buildStatCol(
                          'اجمالي المصاريف',
                          budget.totalSpent,
                          font,
                          fontBold,
                          isRed: true,
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 10),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCol(
                          'حد التنبيه',
                          budget.alertThreshold,
                          font,
                          fontBold,
                        ),
                        _buildStatCol(
                          'اجمالي الضرائب',
                          expenses.fold<double>(
                            0,
                            (sum, e) => sum + e.taxAmount,
                          ),
                          font,
                          fontBold,
                        ),
                        _buildStatCol(
                          'المتبقي',
                          budget.remaining,
                          font,
                          fontBold,
                          isGreen: budget.remaining >= 0,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),
              pw.Text(
                'تفاصيل المصروفات',
                style: pw.TextStyle(
                  fontSize: 18,
                  font: fontBold,
                  color: PdfColors.blueGrey800,
                ),
              ),
              pw.SizedBox(height: 10),
              if (expenses.isEmpty)
                pw.Center(
                  child: pw.Text(
                    'لا توجد مصروفات',
                    style: pw.TextStyle(font: font),
                  ),
                )
              else
                pw.Table(
                  border: pw.TableBorder.all(
                    color: PdfColors.grey300,
                    width: 1,
                  ),
                  children: [
                    // Header
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey100,
                      ),
                      children: [
                        _buildPdfCell('المنصة', fontBold, isHeader: true),
                        _buildPdfCell('الملاحظات', fontBold, isHeader: true),
                        _buildPdfCell('التاريخ', fontBold, isHeader: true),
                        _buildPdfCell(
                          'الضريبة',
                          fontBold,
                          isHeader: true,
                        ), // Tax Column
                        _buildPdfCell('المبلغ', fontBold, isHeader: true),
                      ],
                    ),
                    ...expenses.map((e) {
                      return pw.TableRow(
                        children: [
                          _buildPdfCell(e.platform, font),
                          _buildPdfCell(e.notes, font),
                          _buildPdfCell(
                            intl.DateFormat('yyyy/MM/dd').format(e.createdAt),
                            font,
                          ),
                          _buildPdfCell(
                            // Tax Value
                            formatCurrency(e.taxAmount),
                            font,
                          ),
                          _buildPdfCell(
                            formatCurrency(e.amount),
                            font,
                            color: PdfColors.red,
                          ),
                        ],
                      );
                    }),
                  ],
                ),
            ];
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) async => doc.save(),
        name: 'budget_${budget.name}.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('فشل التصدير: $e')));
      }
    }
  }

  // --- PDF Helpers ---

  pw.Widget _buildPdfHeader(
    String title,
    pw.ImageProvider logo,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Container(
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
                title,
                style: pw.TextStyle(
                  fontSize: 18,
                  font: font,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                intl.DateFormat(
                  'yyyy/MM/dd - HH:mm',
                  'ar',
                ).format(DateTime.now()),
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
            child: pw.ClipOval(child: pw.Image(logo, fit: pw.BoxFit.cover)),
          ),
        ],
      ),
    );
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
          ? const pw.BoxDecoration(color: PdfColors.grey100)
          : null,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            label,
            style: pw.TextStyle(
              font: isHeader ? fontBold : font,
              fontSize: 12,
              color: PdfColors.black,
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            value,
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 14,
              color: color ?? PdfColors.black,
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildPdfCell(
    String text,
    pw.Font font, {
    bool isHeader = false,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          font: font,
          fontSize: 10,
          color: color ?? (isHeader ? PdfColors.black : PdfColors.grey800),
        ),
      ),
    );
  }

  pw.Widget _buildStatCol(
    String label,
    double val,
    pw.Font font,
    pw.Font fontBold, {
    bool isRed = false,
    bool isGreen = false,
  }) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey),
        ),
        pw.Text(
          formatCurrency(val),
          style: pw.TextStyle(
            font: fontBold,
            fontSize: 14,
            color: isRed
                ? PdfColors.red
                : (isGreen ? PdfColors.green : PdfColors.black),
          ),
        ),
      ],
    );
  }
}

class BusinessBudgetDetailsScreen extends ConsumerStatefulWidget {
  final BusinessBudget budget;
  const BusinessBudgetDetailsScreen({super.key, required this.budget});

  @override
  ConsumerState<BusinessBudgetDetailsScreen> createState() =>
      _BusinessBudgetDetailsScreenState();
}

class _BusinessBudgetDetailsScreenState
    extends ConsumerState<BusinessBudgetDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(businessExpensesProvider.notifier)
          .loadExpenses(widget.budget.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenses = ref.watch(businessExpensesProvider);
    final currentBudget = ref
        .watch(businessBudgetsProvider)
        .firstWhere(
          (b) => b.id == widget.budget.id,
          orElse: () => widget.budget,
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(currentBudget.name, style: GoogleFonts.cairo()),
      ),
      body: Column(
        children: [
          // Summary Header
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.grey[50],
            child: Column(
              children: [
                // Row 1: Main, Reserve, Expenses
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem(
                      'الميزانية الرئيسية',
                      currentBudget.mainBudget,
                    ),
                    _buildStatItem(
                      'الميزانية الاحتياطية',
                      currentBudget.reserveBudget,
                    ),
                    _buildStatItem(
                      'اجمالي المصاريف',
                      currentBudget.totalSpent,
                      isRed: true,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Row 2: Threshold, Taxes, Remaining
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem(
                      'الحد (التنبيه)',
                      currentBudget.alertThreshold,
                    ),
                    _buildStatItem(
                      'اجمالي الضرائب',
                      expenses.fold<double>(0, (sum, e) => sum + e.taxAmount),
                    ),
                    Column(
                      children: [
                        Text(
                          'المتبقي',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          formatCurrency(currentBudget.remaining),
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: currentBudget.remaining < 0
                                ? Colors.red
                                : Colors.green[800],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: expenses.isEmpty
                ? Center(
                    child: Text(
                      'لا توجد مصروفات',
                      style: GoogleFonts.cairo(color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    itemCount: expenses.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final e = expenses[index];
                      return ListTile(
                        onTap: () =>
                            _showExpenseOptions(context, e, currentBudget),
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryColor.withOpacity(
                            0.1,
                          ),
                          child: Icon(
                            _getPlatformIcon(e.platform),
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          e.platform,
                          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          e.notes.isNotEmpty
                              ? e.notes
                              : intl.DateFormat(
                                  'yyyy/MM/dd',
                                ).format(e.createdAt),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '- ${formatCurrency(e.amount)}',
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const SizedBox(width: 8),
                            PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_vert_rounded,
                                color: Colors.grey,
                                size: 20,
                              ),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showEditExpenseDialog(
                                    context,
                                    e,
                                    currentBudget,
                                  );
                                } else if (value == 'delete') {
                                  _confirmDeleteExpense(
                                    context,
                                    e,
                                    currentBudget,
                                  );
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text('تعديل'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'حذف',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseDialog(context, currentBudget),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatItem(String label, double val, {bool isRed = false}) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey)),
        Text(
          formatCurrency(val),
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isRed ? Colors.red : null,
          ),
        ),
      ],
    );
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'snapchat':
        return Icons.snapchat;
      case 'tiktok':
        return Icons.music_note;
      case 'instagram':
        return Icons.camera_alt;
      case 'twitter':
        return Icons.alternate_email;
      case 'google ads':
        return Icons.g_mobiledata;
      default:
        return Icons.attach_money;
    }
  }

  void _showAddExpenseDialog(BuildContext context, BusinessBudget budget) {
    final amountCtrl = TextEditingController();
    final taxCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String selectedPlatform = 'Other';
    final platforms = [
      'Snapchat',
      'TikTok',
      'Instagram',
      'Twitter',
      'Google Ads',
      'Other',
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'إضافة مصروف',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'المبلغ'),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                    ThousandsSeparatorInputFormatter(),
                  ],
                ),

                const SizedBox(height: 10),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: amountCtrl,
                  builder: (context, value, child) {
                    final amt =
                        double.tryParse(value.text.replaceAll(',', '')) ?? 0;
                    final tax = amt * 0.15;
                    // Keep taxCtrl in sync for submission if needed, but we calculate on save primarily
                    taxCtrl.text = intl.NumberFormat('#,###.##').format(tax);
                    return TextField(
                      controller: taxCtrl,
                      readOnly: true, // Auto-calculated
                      decoration: const InputDecoration(
                        labelText: 'الضريبة (15%) - تلقائي',
                        filled: true,
                        fillColor: Colors.white70,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedPlatform,
                  decoration: const InputDecoration(labelText: 'المنصة'),
                  items: platforms
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (val) => setState(() => selectedPlatform = val!),
                ),
                TextField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(labelText: 'ملاحظات'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (amountCtrl.text.isEmpty) return;

                final amount =
                    double.tryParse(amountCtrl.text.replaceAll(',', '')) ?? 0;
                if (amount <= 0) return;

                // Auto-calculate tax 15%
                final tax = amount * 0.15;

                final expense = BusinessExpense(
                  id: '',
                  budgetId: budget.id,
                  amount: amount,
                  platform: selectedPlatform,
                  notes: notesCtrl.text,
                  createdAt: DateTime.now(),
                  taxAmount: tax,
                );

                try {
                  await ref
                      .read(businessExpensesProvider.notifier)
                      .addExpense(expense, budget);

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم إضافة المصروف بنجاح'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('خطأ'),
                        content: Text(
                          e.toString().replaceAll('Exception: ', ''),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('موافق'),
                          ),
                        ],
                      ),
                    );
                  }
                }
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  void _showExpenseOptions(
    BuildContext context,
    BusinessExpense expense,
    BusinessBudget budget,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('تعديل المصروف'),
              onTap: () {
                Navigator.pop(context);
                _showEditExpenseDialog(context, expense, budget);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('حذف المصروف'),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteExpense(context, expense, budget);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditExpenseDialog(
    BuildContext context,
    BusinessExpense expense,
    BusinessBudget budget,
  ) {
    final amountCtrl = TextEditingController(
      text: intl.NumberFormat('#,###').format(expense.amount),
    );
    final notesCtrl = TextEditingController(text: expense.notes);
    String selectedPlatform = expense.platform;
    final platforms = [
      'Snapchat',
      'TikTok',
      'Instagram',
      'Twitter',
      'Google Ads',
      'Other',
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('تعديل المصروف'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'المبلغ'),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                    ThousandsSeparatorInputFormatter(),
                  ],
                ),
                const SizedBox(height: 10),
                // Edit Dialog Tax Display
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: amountCtrl,
                  builder: (context, value, child) {
                    final amt =
                        double.tryParse(value.text.replaceAll(',', '')) ?? 0;
                    final tax = amt * 0.15;
                    final taxStr = intl.NumberFormat('#,###.##').format(tax);
                    return TextField(
                      controller: TextEditingController(text: taxStr),
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'الضريبة (15%) - تلقائي',
                        filled: true,
                        fillColor: Colors.white70,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: platforms.contains(selectedPlatform)
                      ? selectedPlatform
                      : 'Other',
                  decoration: const InputDecoration(labelText: 'المنصة'),
                  items: platforms
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (val) => setState(() => selectedPlatform = val!),
                ),
                TextField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(labelText: 'ملاحظات'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount =
                    double.tryParse(amountCtrl.text.replaceAll(',', '')) ?? 0;
                if (amount <= 0) return;

                final updatedExpense = expense.copyWith(
                  amount: amount,
                  platform: selectedPlatform,
                  notes: notesCtrl.text,
                  taxAmount: amount * 0.15, // Update tax as well
                );

                try {
                  await ref
                      .read(businessExpensesProvider.notifier)
                      .updateExpense(updatedExpense, budget);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم تعديل المصروف'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  // error
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteExpense(
    BuildContext context,
    BusinessExpense expense,
    BusinessBudget budget,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المصروف'),
        content: const Text('هل أنت متأكد من حذف هذا المصروف؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ref
                    .read(businessExpensesProvider.notifier)
                    .deleteExpense(expense.id, budget.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم حذف المصروف'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                // error
              }
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
