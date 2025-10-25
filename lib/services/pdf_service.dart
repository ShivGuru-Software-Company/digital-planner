import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import '../models/entry_model.dart';

class PdfService {
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
                style: pw.TextStyle(
                  fontSize: 14,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 24),
              pw.Divider(),
              pw.SizedBox(height: 24),
              pw.Text(
                entry.content,
                style: const pw.TextStyle(
                  fontSize: 14,
                  lineSpacing: 1.5,
                ),
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
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
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
                style: pw.TextStyle(
                  fontSize: 14,
                  color: PdfColors.grey700,
                ),
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
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Divider(),
                pw.SizedBox(height: 16),
                pw.Text(
                  entry.content,
                  style: const pw.TextStyle(
                    fontSize: 12,
                    lineSpacing: 1.5,
                  ),
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
}
