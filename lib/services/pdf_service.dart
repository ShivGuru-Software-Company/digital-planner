import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import '../models/entry_model.dart';
import '../models/saved_template_model.dart';

class PdfService {
  // Standard PDF page formats
  static const PdfPageFormat standardPageFormat = PdfPageFormat.a4;
  static const double pageMargin = 20.0;

  // Calculate usable page dimensions
  static double get pageWidth => standardPageFormat.width - (pageMargin * 2);
  static double get pageHeight => standardPageFormat.height - (pageMargin * 2);
  static Future<File> generateEntryPdf(EntryModel entry) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                entry.title,
                style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Text(
                'Date: ${entry.date.day}/${entry.date.month}/${entry.date.year}',
                style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
              ),
              pw.SizedBox(height: 24),
              pw.Divider(),
              pw.SizedBox(height: 24),
              pw.Text(
                entry.content,
                style: const pw.TextStyle(fontSize: 14, lineSpacing: 1.5),
              ),
              if (entry.images.isNotEmpty) ...[
                pw.SizedBox(height: 24),
                pw.Text(
                  'Images (${entry.images.length})',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
              pw.Spacer(),
              pw.Divider(),
              pw.SizedBox(height: 8),
              pw.Text(
                'Created: ${entry.createdAt.day}/${entry.createdAt.month}/${entry.createdAt.year}',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/entry_${entry.id}.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  static Future<File> generateMultipleEntriesPdf(
    List<EntryModel> entries,
    String title,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 32,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                '${entries.length} entries',
                style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
              ),
              pw.SizedBox(height: 24),
              pw.Divider(),
            ],
          );
        },
      ),
    );

    for (final entry in entries) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  entry.title,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Text(
                  'Date: ${entry.date.day}/${entry.date.month}/${entry.date.year}',
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                ),
                pw.SizedBox(height: 16),
                pw.Divider(),
                pw.SizedBox(height: 16),
                pw.Text(
                  entry.content,
                  style: const pw.TextStyle(fontSize: 12, lineSpacing: 1.5),
                ),
              ],
            );
          },
        ),
      );
    }

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/journal_export.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  static Future<void> printEntry(EntryModel entry) async {
    final pdf = await generateEntryPdf(entry);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.readAsBytesSync(),
    );
  }

  static Future<void> shareEntry(EntryModel entry) async {
    final pdf = await generateEntryPdf(entry);
    await Printing.sharePdf(
      bytes: pdf.readAsBytesSync(),
      filename: 'entry_${entry.id}.pdf',
    );
  }

  // New method for exporting templates as PDF
  static Future<File> generateTemplatePdf(SavedTemplateModel template) async {
    final pdf = pw.Document();
    final templateData = template.data;

    switch (template.templateType.toLowerCase()) {
      case 'daily':
        await _generateDailyTemplatePdf(pdf, template, templateData);
        break;
      case 'weekly':
        await _generateWeeklyTemplatePdf(pdf, template, templateData);
        break;
      case 'monthly':
        await _generateMonthlyTemplatePdf(pdf, template, templateData);
        break;
      case 'yearly':
        await _generateYearlyTemplatePdf(pdf, template, templateData);
        break;
      case 'meal':
        await _generateMealTemplatePdf(pdf, template, templateData);
        break;
      case 'mood':
        await _generateMoodTemplatePdf(pdf, template, templateData);
        break;
      default:
        throw Exception('Unsupported template type: ${template.templateType}');
    }

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/template_${template.id}.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  static Future<void> _generateDailyTemplatePdf(
    pw.Document pdf,
    SavedTemplateModel template,
    Map<String, dynamic> data,
  ) async {
    // Page 1: Header and priorities
    pdf.addPage(
      pw.Page(
        pageFormat: standardPageFormat,
        margin: pw.EdgeInsets.all(pageMargin),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              _buildPdfHeader(template),
              pw.SizedBox(height: 20),

              // Date and Weather
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Date: ${_formatDate(DateTime.parse(data['date'] ?? DateTime.now().toIso8601String()))}',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Weather: ${data['weather'] ?? ''}',
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Priorities Section
              _buildPdfSection(
                'Today\'s Priorities',
                data['priorities'] as List<dynamic>? ?? [],
              ),
              pw.SizedBox(height: 20),

              // Water Intake
              pw.Text(
                'Water Intake: ${data['waterIntake'] ?? 0} glasses',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          );
        },
      ),
    );

    // Page 2: Schedule and tasks
    pdf.addPage(
      pw.Page(
        pageFormat: standardPageFormat,
        margin: pw.EdgeInsets.all(pageMargin),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Daily Schedule',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 15),

              // Schedule items
              ..._buildScheduleItems(
                data['schedule'] as Map<String, dynamic>? ?? {},
              ),

              pw.SizedBox(height: 20),

              // To-do items
              _buildPdfSection(
                'To-Do List',
                data['todos'] as List<dynamic>? ?? [],
              ),
            ],
          );
        },
      ),
    );

    // Page 3: Additional content if needed
    if ((data['tasks'] as List<dynamic>? ?? []).isNotEmpty ||
        (data['comment'] as String? ?? '').isNotEmpty) {
      pdf.addPage(
        pw.Page(
          pageFormat: standardPageFormat,
          margin: pw.EdgeInsets.all(pageMargin),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Tasks
                if ((data['tasks'] as List<dynamic>? ?? []).isNotEmpty) ...[
                  _buildPdfSection('Tasks', data['tasks'] as List<dynamic>),
                  pw.SizedBox(height: 20),
                ],

                // Comments
                if ((data['comment'] as String? ?? '').isNotEmpty) ...[
                  pw.Text(
                    'Notes & Comments',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    data['comment'] as String,
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ],
              ],
            );
          },
        ),
      );
    }
  }

  static Future<void> _generateWeeklyTemplatePdf(
    pw.Document pdf,
    SavedTemplateModel template,
    Map<String, dynamic> data,
  ) async {
    pdf.addPage(
      pw.Page(
        pageFormat: standardPageFormat,
        margin: pw.EdgeInsets.all(pageMargin),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildPdfHeader(template),
              pw.SizedBox(height: 20),

              pw.Text(
                'Week: ${data['weekStart'] ?? ''} - ${data['weekEnd'] ?? ''}',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),

              // Weekly goals
              _buildPdfSection(
                'Weekly Goals',
                data['goals'] as List<dynamic>? ?? [],
              ),
              pw.SizedBox(height: 20),

              // Daily entries for the week
              ..._buildWeeklyDays(data['days'] as Map<String, dynamic>? ?? {}),
            ],
          );
        },
      ),
    );
  }

  static Future<void> _generateMonthlyTemplatePdf(
    pw.Document pdf,
    SavedTemplateModel template,
    Map<String, dynamic> data,
  ) async {
    pdf.addPage(
      pw.Page(
        pageFormat: standardPageFormat,
        margin: pw.EdgeInsets.all(pageMargin),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildPdfHeader(template),
              pw.SizedBox(height: 20),

              pw.Text(
                'Month: ${data['month'] ?? ''} ${data['year'] ?? ''}',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),

              // Monthly goals
              _buildPdfSection(
                'Monthly Goals',
                data['goals'] as List<dynamic>? ?? [],
              ),
              pw.SizedBox(height: 20),

              // Important dates
              _buildPdfSection(
                'Important Dates',
                data['importantDates'] as List<dynamic>? ?? [],
              ),
            ],
          );
        },
      ),
    );
  }

  static Future<void> _generateYearlyTemplatePdf(
    pw.Document pdf,
    SavedTemplateModel template,
    Map<String, dynamic> data,
  ) async {
    pdf.addPage(
      pw.Page(
        pageFormat: standardPageFormat,
        margin: pw.EdgeInsets.all(pageMargin),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildPdfHeader(template),
              pw.SizedBox(height: 20),

              pw.Text(
                'Year: ${data['year'] ?? DateTime.now().year}',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),

              // Yearly goals
              _buildPdfSection(
                'Yearly Goals',
                data['goals'] as List<dynamic>? ?? [],
              ),
              pw.SizedBox(height: 20),

              // Monthly breakdown
              ..._buildYearlyMonths(
                data['months'] as Map<String, dynamic>? ?? {},
              ),
            ],
          );
        },
      ),
    );
  }

  static Future<void> _generateMealTemplatePdf(
    pw.Document pdf,
    SavedTemplateModel template,
    Map<String, dynamic> data,
  ) async {
    pdf.addPage(
      pw.Page(
        pageFormat: standardPageFormat,
        margin: pw.EdgeInsets.all(pageMargin),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildPdfHeader(template),
              pw.SizedBox(height: 20),

              // Meal planning sections
              _buildMealSection(
                'Breakfast',
                data['breakfast'] as Map<String, dynamic>? ?? {},
              ),
              pw.SizedBox(height: 15),
              _buildMealSection(
                'Lunch',
                data['lunch'] as Map<String, dynamic>? ?? {},
              ),
              pw.SizedBox(height: 15),
              _buildMealSection(
                'Dinner',
                data['dinner'] as Map<String, dynamic>? ?? {},
              ),
              pw.SizedBox(height: 15),
              _buildMealSection(
                'Snacks',
                data['snacks'] as Map<String, dynamic>? ?? {},
              ),
            ],
          );
        },
      ),
    );
  }

  static Future<void> _generateMoodTemplatePdf(
    pw.Document pdf,
    SavedTemplateModel template,
    Map<String, dynamic> data,
  ) async {
    pdf.addPage(
      pw.Page(
        pageFormat: standardPageFormat,
        margin: pw.EdgeInsets.all(pageMargin),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildPdfHeader(template),
              pw.SizedBox(height: 20),

              // Mood tracking
              pw.Text(
                'Mood: ${data['mood'] ?? 'Not set'}',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 15),

              // Emotions
              _buildPdfSection(
                'Emotions',
                data['emotions'] as List<dynamic>? ?? [],
              ),
              pw.SizedBox(height: 15),

              // Activities
              _buildPdfSection(
                'Activities',
                data['activities'] as List<dynamic>? ?? [],
              ),
              pw.SizedBox(height: 15),

              // Reflections
              if ((data['reflection'] as String? ?? '').isNotEmpty) ...[
                pw.Text(
                  'Reflection',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  data['reflection'] as String,
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  // Helper methods for PDF generation
  static pw.Widget _buildPdfHeader(SavedTemplateModel template) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            template.templateName,
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            '${template.templateType} • ${template.templateDesign}',
            style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPdfSection(String title, List<dynamic> items) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        ...items.map(
          (item) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 5),
            child: pw.Row(
              children: [
                pw.Text('• ', style: const pw.TextStyle(fontSize: 12)),
                pw.Expanded(
                  child: pw.Text(
                    item.toString(),
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static List<pw.Widget> _buildScheduleItems(Map<String, dynamic> schedule) {
    return schedule.entries
        .map(
          (entry) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Row(
              children: [
                pw.Container(
                  width: 80,
                  child: pw.Text(
                    entry.key,
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    entry.value.toString(),
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  static List<pw.Widget> _buildWeeklyDays(Map<String, dynamic> days) {
    return days.entries
        .map(
          (entry) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 15),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  entry.key,
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  entry.value.toString(),
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  static List<pw.Widget> _buildYearlyMonths(Map<String, dynamic> months) {
    return months.entries
        .map(
          (entry) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 10),
            child: pw.Row(
              children: [
                pw.Container(
                  width: 100,
                  child: pw.Text(
                    entry.key,
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    entry.value.toString(),
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  static pw.Widget _buildMealSection(
    String mealType,
    Map<String, dynamic> mealData,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          mealType,
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Recipe: ${mealData['recipe'] ?? 'Not specified'}',
          style: const pw.TextStyle(fontSize: 12),
        ),
        pw.Text(
          'Calories: ${mealData['calories'] ?? 'Not specified'}',
          style: const pw.TextStyle(fontSize: 12),
        ),
        if ((mealData['notes'] as String? ?? '').isNotEmpty)
          pw.Text(
            'Notes: ${mealData['notes']}',
            style: const pw.TextStyle(fontSize: 12),
          ),
      ],
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Method to share template as PDF
  static Future<void> shareTemplate(SavedTemplateModel template) async {
    final pdf = await generateTemplatePdf(template);
    await Printing.sharePdf(
      bytes: pdf.readAsBytesSync(),
      filename: 'template_${template.templateName.replaceAll(' ', '_')}.pdf',
    );
  }

  // Method to print template
  static Future<void> printTemplate(SavedTemplateModel template) async {
    final pdf = await generateTemplatePdf(template);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.readAsBytesSync(),
    );
  }
}
