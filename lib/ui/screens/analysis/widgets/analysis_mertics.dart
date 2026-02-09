import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../widgets/vibe/glitch.dart';
import 'analysis_container.dart';

class AnalysisMetrics extends StatelessWidget {
  final String title1;
  final String value1;
  final String unit1;
  final Color color1;
  final String title2;
  final String value2;
  final String unit2;
  final Color color2;

  const AnalysisMetrics(
      {super.key,
      required this.title1,
      required this.value1,
      required this.unit1,
      required this.color1,
      required this.title2,
      required this.value2,
      required this.unit2,
      required this.color2});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(context, title1, value1, unit1, color1),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(context, title2, value2, unit2, color2),
        ),
      ],
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value,
      String unit, Color color) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnalysisContainer(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CyberGlitchText(
              title,
              style: GoogleFonts.iceland(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  letterSpacing: 1),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CyberGlitchText(
                  value,
                  style: GoogleFonts.vt323(
                      color: color, fontSize: 40, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: CyberGlitchText(unit,
                      style: TextStyle(
                          color: colorScheme.onSurfaceVariant, fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
