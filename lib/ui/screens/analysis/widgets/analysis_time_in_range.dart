import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:diabetes_app/ui/widgets/vibe/glitch.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../themes/colors/app_colors.dart';

class AnalysisTimeInRange extends StatelessWidget {
  final double veryHigh;
  final double high;
  final double inRange;
  final double low;
  final double veryLow;

  const AnalysisTimeInRange({super.key,
    required this.veryHigh,
    required this.high,
    required this.inRange,
    required this.low,
    required this.veryLow,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme
        .of(context)
        .colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      color: AppColors.green,
                      value: inRange,
                      title: '${inRange.toInt()}%',
                      radius: 45,
                      titleStyle: GoogleFonts.vt323(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    PieChartSectionData(
                      color: Colors.orange[900],
                      value: veryHigh,
                      title: '${veryHigh.toInt()}%',
                      radius: 40,
                      titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    PieChartSectionData(
                      color: Colors.orangeAccent,
                      value: high,
                      title: '${high.toInt()}%',
                      radius: 40,
                      titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    PieChartSectionData(
                      color: Colors.redAccent,
                      value: low,
                      title: '${low.toInt()}%',
                      radius: 40,
                      titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    PieChartSectionData(
                      color: const Color(0xFF8B0000),
                      value: veryLow,
                      title: '${veryLow.toInt()}%',
                      radius: 40,
                      titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegendItem(context, Colors.orange[900]!,
                      "Very High (>250)", veryHigh),
                  const SizedBox(height: 8),
                  _buildLegendItem(
                      context, Colors.orangeAccent, "High (181-250)", high),
                  const SizedBox(height: 8),
                  _buildLegendItem(
                      context, AppColors.green, "Target (70-180)", inRange),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegendItem(
                      context, Colors.redAccent, "Low (54-69)", low),
                  const SizedBox(height: 8),
                  _buildLegendItem(context, const Color(0xFF8B0000),
                      "Very Low (<54)", veryLow),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, Color color, String label,
      double value) {
    final textColor = Theme
        .of(context)
        .colorScheme
        .onSurfaceVariant;
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.zero),
        ),
        const SizedBox(width: 8),
        CyberGlitchText(label,
            style: GoogleFonts.iceland(
                color: Theme
                    .of(context)
                    .colorScheme
                    .onSurface, fontSize: 14)),
      ],
    );
  }
}
