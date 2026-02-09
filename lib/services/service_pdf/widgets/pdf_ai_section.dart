import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfAiSection {
  static pw.Widget buildAiSummary(String aiText) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.purple, width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        color: PdfColors.purple50,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text("AI DIAGNOSTIC SUMMARY",
              style: pw.TextStyle(
                  color: PdfColors.purple,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12)),
          pw.SizedBox(height: 8),
          pw.Text(aiText,
              style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.5)),
        ],
      ),
    );
  }

  static pw.Widget buildBestDay(String bestDay) {
    return pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.all(10),
        decoration: const pw.BoxDecoration(
          color: PdfColors.amber50,
          borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
        ),
        child: pw.Row(children: [
          pw.Text("ACHIEVEMENT: ",
              style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.orange800,
                  fontSize: 10)),
          pw.Text(bestDay, style: const pw.TextStyle(fontSize: 10)),
        ]));
  }
}