import 'package:diabetes_app/ui/view_models/analysis_view_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../widgets/vibe/glitch.dart';
import 'analysis_container.dart';

class AnalysisGlucoseTrend extends StatelessWidget {
  const AnalysisGlucoseTrend({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AnalysisViewModel>();
    final colorScheme = Theme.of(context).colorScheme;
    return AnalysisContainer(
      color: colorScheme.onSurface.withOpacity(0.3),
      child: Container(
        height: 200,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart,
                color: colorScheme.primary.withOpacity(0.5), size: 48),
            CyberGlitchText("[ CHART LOADING... ]",
                style: GoogleFonts.vt323(
                    color: colorScheme.onSurfaceVariant, fontSize: 18)),
          ],
        )),
      ),
    );
  }
}
