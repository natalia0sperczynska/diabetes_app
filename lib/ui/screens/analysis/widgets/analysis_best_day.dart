import 'package:diabetes_app/ui/view_models/analysis_view_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../widgets/vibe/glitch.dart';
import 'analysis_container.dart';

class BestDayWidget extends StatelessWidget {
  final String bestDayText;

  const BestDayWidget
      ({super.key, required this.bestDayText});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AnalysisViewModel>();
    final colorScheme = Theme
        .of(context)
        .colorScheme;
    return AnalysisContainer(
      color: Colors.amber,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amberAccent.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                  Icons.emoji_events, color: Colors.amberAccent, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CyberGlitchText(
                    "RECORD BREAKER",
                    style: GoogleFonts.vt323(
                      color: Colors.amberAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vm.bestDayText,
                    style: GoogleFonts.shareTechMono(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}