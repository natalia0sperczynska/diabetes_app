import 'package:diabetes_app/services/service_pdf/widgets/pdf_ai_section.dart';
import 'package:diabetes_app/services/service_pdf/widgets/pdf_header_footer.dart';
import 'package:diabetes_app/services/service_pdf/widgets/pdf_stats_section.dart';

import '../../data/model/AnalysisModel.dart';
import 'save_open_document.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;

class PdfApi {
  static Future<File> generate({
    required AnalysisStats stats,
    required String aiAnalysis,
    required String bestDayText,
  }) async {
    final pdf = pw.Document();
    final theme = pw.ThemeData.withFont(
      base: pw.Font.helvetica(),
      bold: pw.Font.helveticaBold(),
    );
    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          theme: theme,
          margin: const pw.EdgeInsets.all(40),
        ),
        build: (pw.Context context) => [
          PdfHeaderFooter.buildHeader(),

          pw.SizedBox(height: 20),

          PdfStatsSection.buildMetricsTable(stats),

          pw.SizedBox(height: 30),

          PdfStatsSection.buildTimeInRangeSection(stats),

          pw.SizedBox(height: 30),

          if (aiAnalysis.isNotEmpty)
            PdfAiSection.buildAiSummary(aiAnalysis),

          pw.SizedBox(height: 20),

          PdfAiSection.buildBestDay(bestDayText),

          pw.SizedBox(height: 40),

          PdfHeaderFooter.buildFooter(),
        ],
      ),
    );
    return SaveAndOpenDocument.savePDF(
        name: 'diabeto_report${DateTime.now().millisecondsSinceEpoch}.pdf',
        pdf: pdf);
  }
}
