import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../widgets/vibe/glitch.dart';

class AnalysisTitle extends StatelessWidget {
  final String title;

  const AnalysisTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 8,
          height: 24,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 8),
        CyberGlitchText(
          title.toUpperCase(),
          style: GoogleFonts.vt323(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
