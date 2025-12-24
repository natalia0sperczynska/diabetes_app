import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CyberButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final BuildContext context;


  const CyberButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: colorScheme.outline.withOpacity(0.6),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.primary,
          shadowColor: colorScheme.background,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: BeveledRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(color: colorScheme.outline, width: 2),
          ),
        ),
        child: Text(
          text.toUpperCase(),
          style: GoogleFonts.iceland(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
      ),
    );
  }
}