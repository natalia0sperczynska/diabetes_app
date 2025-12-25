import 'package:diabetes_app/ui/view_models/analysis_view_model.dart';
import 'package:diabetes_app/ui/widgets/vibe/glitch.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'analysis_container.dart';

class AnalysisAI extends StatelessWidget {
  const AnalysisAI({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AnalysisViewModel>();
    final colorScheme = Theme.of(context).colorScheme;
    return AnalysisContainer(
      color: Colors.purpleAccent,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.purpleAccent),
                    const SizedBox(width: 8),
                    CyberGlitchText(
                      "AI DIAGNOSTIC",
                      style: GoogleFonts.vt323(
                        fontSize: 22,
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (vm.aiAnalysisResult.isEmpty && !vm.isAiLoading)
                  GestureDetector(
                    onTap: () => vm.generateAIAnalysis(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.purpleAccent),
                        color: Colors.purpleAccent.withOpacity(0.2),
                      ),
                      child: Text("ANALYZE",
                          style: GoogleFonts.vt323(color: Colors.white)),
                    ),
                  )
              ],
            ),
            const SizedBox(height: 12),
            if (vm.isAiLoading)
              Row(
                children: [
                  const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.purpleAccent)),
                  const SizedBox(width: 10),
                  Text("Computing...",
                      style: GoogleFonts.vt323(color: Colors.grey)),
                ],
              )
            else if (vm.aiAnalysisResult.isNotEmpty)
              Text(
                vm.aiAnalysisResult,
                style: GoogleFonts.shareTechMono(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.4,
                ),
              )
            else
              Text(
                "Click ANALYZE to process your data",
                style: GoogleFonts.vt323(
                    color: Colors.grey.withOpacity(0.5), fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}
