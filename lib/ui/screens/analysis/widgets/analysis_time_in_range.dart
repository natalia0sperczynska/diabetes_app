import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:diabetes_app/ui/widgets/vibe/glitch.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../themes/colors/app_colors.dart';
import 'analysis_container.dart';

class AnalysisTimeInRange extends StatelessWidget {
  final double veryHigh;
  final double high;
  final double inRange;
  final double low;
  final double veryLow;

  const AnalysisTimeInRange({
    super.key,
    required this.veryHigh,
    required this.high,
    required this.inRange,
    required this.low,
    required this.veryLow,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryBlue = Colors.blueAccent;

    final sections = <PieChartSectionData>[
      if (inRange > 0) _section(AppColors.green, inRange, '${inRange.toInt()}%'),
      if (veryHigh > 0) _section(Colors.orange[900]!, veryHigh, '${veryHigh.toInt()}%'),
      if (high > 0) _section(Colors.orangeAccent, high, '${high.toInt()}%'),
      if (low > 0) _section(Colors.redAccent, low, '${low.toInt()}%'),
      if (veryLow > 0) _section(const Color(0xFF8B0000), veryLow, '${veryLow.toInt()}%'),
    ];

    return AnalysisContainer(
      color: primaryBlue,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: SizedBox(
                height: 180,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 35,
                    sections: sections,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 35),

            Expanded(
              flex: 5,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: ShapeDecoration(
                  color: colorScheme.surface.withOpacity(0.5),
                  shape: BeveledRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                        color: primaryBlue.withOpacity(0.4),
                        width: 1
                    ),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CyberGlitchText(
                      "GLUCOSE RANGES",
                      style: GoogleFonts.vt323(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildLegendItem(Colors.orange[900]!, "Very High (>250)"),
                    _buildLegendItem(Colors.orangeAccent, "High (181-250)"),
                    _buildLegendItem(AppColors.green, "Target (70-180)"),
                    _buildLegendItem(Colors.redAccent, "Low (54-69)"),
                    _buildLegendItem(const Color(0xFF8B0000), "Very Low (<54)"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PieChartSectionData _section(Color color, double val, String title) {
    return PieChartSectionData(
      color: color,
      value: val,
      title: title,
      radius: 40,
      titleStyle: GoogleFonts.vt323(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(width: 8, height: 8, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.iceland(fontSize: 13, color: Colors.white70),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}