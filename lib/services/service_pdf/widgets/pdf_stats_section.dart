import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../data/model/AnalysisModel.dart';

class PdfStatsSection {


  static pw.Widget buildMetricsTable(AnalysisStats stats) {
    return pw.TableHelper.fromTextArray(
      headers: ['Metric', 'Value', 'Unit', 'Goal (Ref)'],
      data: [
        ['Average Glucose', stats.averageGlucose.toInt().toString(), 'mg/dL', '< 154'],
        ['GMI', stats.gmi.toString(), '%', '< 7.0'],
        ['Std. Deviation', stats.standardDeviation.toInt().toString(), 'mg/dL', '-'],
        ['CV (Stability)', stats.coefficientOfVariation.toString(), '%', '< 36%'],
        ['Sensor Active', stats.sensorActivePercent.toString(), '%', '> 80%'],
      ],
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueAccent),
      rowDecoration: const pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200))),
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.all(8),
    );
  }

  // Time In Range
  static pw.Widget buildTimeInRangeSection(AnalysisStats stats) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("TIME IN RANGES",
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        _buildBarRow("Very High (>250)", stats.ranges['veryHigh'] ?? 0, PdfColors.orange900),
        _buildBarRow("High (181-250)", stats.ranges['high'] ?? 0, PdfColors.orange),
        _buildBarRow("Target (70-180)", stats.ranges['inTarget'] ?? 0, PdfColors.green, isTarget: true),
        _buildBarRow("Low (54-69)", stats.ranges['low'] ?? 0, PdfColors.red),
        _buildBarRow("Very Low (<54)", stats.ranges['veryLow'] ?? 0, PdfColors.red900),
      ],
    );
  }
  
  static pw.Widget _buildBarRow(String label, double value, PdfColor color,
      {bool isTarget = false}) {
    final barWidth = (value * 2.5).clamp(0.0, 250.0);

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        children: [
          pw.Container(
              width: 100,
              child: pw.Text(label, style: const pw.TextStyle(fontSize: 10))),
          pw.Stack(children: [
            pw.Container(height: 12, width: 250, color: PdfColors.grey100),
            pw.Container(height: 12, width: barWidth, color: color),
          ]),
          pw.SizedBox(width: 10),
          pw.Text("${value.toInt()}%",
              style: pw.TextStyle(
                  fontWeight: isTarget ? pw.FontWeight.bold : pw.FontWeight.normal,
                  fontSize: 10)),
        ],
      ),
    );
  }
}