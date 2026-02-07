import 'dart:typed_data';
import 'package:appnami/models.dart'; // For Tasks model
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart' as intl;

class TasksPdfGenerator {
  static Future<Uint8List> generateReport(List<Tasks> tasks) async {
    final pdf = pw.Document();

    // Load Fonts
    final font = await PdfGoogleFonts.cairoRegular();
    final fontBold = await PdfGoogleFonts.cairoBold();

    // Load Logo
    final logoImage = await imageFromAssetBundle('assets/logo.jpg');

    // Calculate Stats
    final totalTasks = tasks.length;
    final completedTasks = tasks.where((t) => t.isCompleted).length;
    final pendingTasks = totalTasks - completedTasks;
    final completionRate = totalTasks > 0
        ? (completedTasks / totalTasks * 100).toStringAsFixed(1)
        : '0.0';
    final highPriorityTasks = tasks.where((t) => t.priority == 'High').length;
    final highPriorityCompleted = tasks
        .where((t) => t.priority == 'High' && t.isCompleted)
        .length;

    // AI Analysis Simulation
    String aiAnalysis = _generateAIAnalysis(
      tasks,
      totalTasks,
      completedTasks,
      completionRate,
      highPriorityTasks,
      highPriorityCompleted,
    );

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          theme: pw.ThemeData.withFont(base: font, bold: fontBold),
          textDirection: pw.TextDirection.rtl,
          buildBackground: (context) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Container(
              color: PdfColor.fromHex('#F8FAFC'), // Very light background
            ),
          ),
        ),
        header: (context) => _buildHeader(logoImage, fontBold),
        footer: (context) => _buildFooter(context, font),
        build: (context) => [
          _buildStatsSection(
            totalTasks,
            completedTasks,
            pendingTasks,
            completionRate,
            fontBold,
          ),
          pw.SizedBox(height: 20),
          _buildAIAnalysisSection(aiAnalysis, fontBold),
          pw.SizedBox(height: 20),
          _buildTasksTable(tasks, fontBold),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(pw.ImageProvider logo, pw.Font fontBold) {
    return pw.Column(
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(20),
          decoration: const pw.BoxDecoration(
            color: PdfColors.white,
            borderRadius: pw.BorderRadius.vertical(
              bottom: pw.Radius.circular(20),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'تقرير المهام - راصد',
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: 24,
                      color: PdfColor.fromHex('#10B981'),
                    ),
                  ),
                  pw.Text(
                    'تقرير تحليلي شامل مدعوم بالذكاء الاصطناعي',
                    style: const pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.Text(
                    'تاريخ التقرير: ${intl.DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey500,
                    ),
                  ),
                ],
              ),
              pw.Container(
                height: 60,
                width: 60,
                child: pw.ClipOval(child: pw.Image(logo)),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 20),
      ],
    );
  }

  static pw.Widget _buildStatsSection(
    int total,
    int completed,
    int pending,
    String rate,
    pw.Font fontBold,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(12),
        boxShadow: const [
          pw.BoxShadow(blurRadius: 4, color: PdfColors.grey300),
        ],
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'معدل الإنجاز',
            '$rate%',
            PdfColor.fromHex('#10B981'),
            fontBold,
          ),
          _buildStatItem(
            'المهام المتبقية',
            '$pending',
            PdfColor.fromHex('#F59E0B'),
            fontBold,
          ),
          _buildStatItem(
            'المهام المنجزة',
            '$completed',
            PdfColor.fromHex('#3B82F6'),
            fontBold,
          ),
          _buildStatItem(
            'إجمالي المهام',
            '$total',
            PdfColor.fromHex('#6B7280'),
            fontBold,
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildStatItem(
    String label,
    String value,
    PdfColor color,
    pw.Font fontBold,
  ) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(font: fontBold, fontSize: 22, color: color),
        ),
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
        ),
      ],
    );
  }

  static pw.Widget _buildAIAnalysisSection(String analysis, pw.Font fontBold) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F0FDF4'),
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: PdfColor.fromHex('#10B981'), width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Text(
                'تحليل الذكاء الاصطناعي',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 16,
                  color: PdfColor.fromHex('#065F46'),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#10B981'),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  'PRO',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            analysis,
            style: const pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey800,
              lineSpacing: 5,
            ),
            textAlign: pw.TextAlign.justify,
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTasksTable(List<Tasks> tasks, pw.Font fontBold) {
    final headers = ['الحالة', 'الأولوية', 'تاريخ الاستحقاق', 'عنوان المهمة'];
    final data = tasks.map((task) {
      final status = task.isCompleted ? 'مكتملة' : 'قيد التنفيذ';
      final priority = _translatePriority(task.priority);
      final date = intl.DateFormat('yyyy-MM-dd').format(task.dueDate);

      return [status, priority, date, task.title];
    }).toList();

    return pw.Container(
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Table.fromTextArray(
        headers: headers,
        data: data,
        border: null,
        headerStyle: pw.TextStyle(
          font: fontBold,
          color: PdfColor.fromHex('#065F46'),
          fontSize: 12,
        ),
        headerDecoration: pw.BoxDecoration(
          color: PdfColor.fromHex('#ECFDF5'),
          borderRadius: const pw.BorderRadius.vertical(
            top: pw.Radius.circular(12),
          ),
        ),
        cellStyle: const pw.TextStyle(fontSize: 10),
        cellPadding: const pw.EdgeInsets.all(10),
        rowDecoration: const pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey100)),
        ),
        cellAlignments: {
          0: pw.Alignment.center,
          1: pw.Alignment.center,
          2: pw.Alignment.center,
          3: pw.Alignment.centerRight,
        },
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context, pw.Font font) {
    return pw.Container(
      alignment: pw.Alignment.center,
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Text(
        'تم إنشاء هذا التقرير تلقائياً بواسطة نظام راصد الذكي - الصفحة ${context.pageNumber} من ${context.pagesCount}',
        style: const pw.TextStyle(color: PdfColors.grey500, fontSize: 10),
      ),
    );
  }

  static String _translatePriority(String priority) {
    switch (priority) {
      case 'High':
        return 'مرتفع';
      case 'Medium':
        return 'متوسط';
      case 'Low':
        return 'منخفض';
      default:
        return priority;
    }
  }

  static String _generateAIAnalysis(
    List<Tasks> tasks,
    int total,
    int completed,
    String rate,
    int highPriority,
    int highPriorityCompleted,
  ) {
    if (total == 0)
      return 'لا توجد بيانات كافية للتحليل. ابدأ بإضافة المهام للحصول على تحليلات ذكية.';

    final rateVal = double.parse(rate);
    final sb = StringBuffer();

    // Opening
    sb.writeln(
      'بناءً على تحليل أنماط العمل والبيانات المسجلة، إليك تقييم الأداء الحالي:',
    );
    sb.writeln();

    // Performance Analysis
    if (rateVal >= 80) {
      sb.writeln(
        '🚀 **أداء ممتاز:** تظهر البيانات التزاماً استثنائياً بإنجاز المهام. معدل إنجاز $rate% يعكس إنتاجية عالية وإدارة وقت فعالة.',
      );
    } else if (rateVal >= 50) {
      sb.writeln(
        '📈 **أداء جيد:** تسير الأمور بشكل جيد بمعدل إنجاز $rate%. هناك مجال للتحسين لزيادة الإنتاجية والوصول إلى أقصى إمكاناتك.',
      );
    } else {
      sb.writeln(
        '⚠️ **تنبيه بالأداء:** معدل الإنجاز الحالي هو $rate%، وهو أقل من المتوقع. يوصى بمراجعة الأولويات وتقسيم المهام الكبيرة لتسهيل إنجازها.',
      );
    }

    // Priority Analysis
    if (highPriority > 0) {
      sb.writeln();
      final hpRate = (highPriorityCompleted / highPriority * 100).toInt();
      if (hpRate > 80) {
        sb.writeln(
          '⭐ **تركيز مثالي:** تم إنجاز معظم المهام ذات الأولوية العالية ($hpRate%). هذا يشير إلى قدرة ممتازة على التمييز بين العاجل والمهم.',
        );
      } else {
        sb.writeln(
          '🎯 **نصيحة استراتيجية:** لاحظنا تأخراً في بعض المهام ذات الأولوية العالية. يُنصح بالبدء بها في ساعات الصباح الأولى لضمان إنجازها.',
        );
      }
    }

    // Workload Analysis
    if (tasks.length > 10 && rateVal < 40) {
      sb.writeln();
      sb.writeln(
        '⚖️ **توازن عبء العمل:** يبدو أن هناك تراكماً في المهام. قد يكون من المفيد تفويض بعض المهام أو إعادة جدولتها لتجنب الإرهاق.',
      );
    }

    // Closing
    sb.writeln();
    sb.writeln(
      '💡 **توصية الذكاء الاصطناعي:** استمر في الحفاظ على تحديث حالة المهام يومياً للحصول على دقة أكبر في التحليلات المستقبلية.',
    );

    return sb.toString();
  }
}
