import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfHeaderFooter {
  static pw.Widget buildHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text("DIABETES ANALYTICS REPORT",
                style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blueAccent)),
            pw.Text("Diabeto App",
                style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey)),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Text(
            "Generated on: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}",
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        pw.Divider(thickness: 1, color: PdfColors.grey300),
      ],
    );
  }

  static pw.Widget buildFooter() {
    return pw.Column(children: [
      pw.Divider(color: PdfColors.grey300),
      pw.SizedBox(height: 5),
      pw.Center(
        child: pw.Text(
            "IMPORTANT: This report is for informational purposes only. Consult a doctor before making medical decisions.",
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            textAlign: pw.TextAlign.center),
      ),
    ]);
  }
}