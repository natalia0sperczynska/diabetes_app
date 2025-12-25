import 'package:diabetes_app/ui/view_models/analysis_view_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../themes/colors/app_colors.dart';
import '../../../widgets/vibe/glitch.dart';
import 'analysis_container.dart';

class AnalysisSensorUsage extends StatelessWidget {
  final double usagePercent;

  const AnalysisSensorUsage({super.key, required this.usagePercent});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = usagePercent > 70 ? AppColors.green : colorScheme.error;
    final vm = context.watch<AnalysisViewModel>();
    return AnalysisContainer(
      color: statusColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CyberGlitchText("SENSOR STATUS",
                    style: GoogleFonts.vt323(
                        color: colorScheme.onSurfaceVariant, fontSize: 22)),
                const SizedBox(height: 4),
                CyberGlitchText("Signal availability",
                    style: GoogleFonts.iceland(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                        fontSize: 12)),
              ],
            ),
            Row(
              children: [
                CyberGlitchText(
                  "$usagePercent",
                  style: TextStyle(
                      color: usagePercent > 70
                          ? AppColors.green
                          : Colors.redAccent,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 2),
                  child: CyberGlitchText("%",
                      style: TextStyle(
                          color: colorScheme.onSurfaceVariant, fontSize: 12)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
