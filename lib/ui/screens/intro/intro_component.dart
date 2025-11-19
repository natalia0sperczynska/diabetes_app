import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../themes/colors/app_colors.dart';

class IntroComponent extends StatelessWidget {
  final String title;
  final String description;
  final String image;

  const IntroComponent({
    super.key,
    required this.title,
    required this.description,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(4.0),
          decoration: const BoxDecoration(
            color: AppColors.darkBlue1,
            borderRadius: BorderRadius.zero,
          ),
          child: Image.asset(image, height: 250, fit: BoxFit.contain),
        ),

        const SizedBox(height: 40),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.iceland(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.mainBlue,
            letterSpacing: 1.5,
          ),
        ),

        const SizedBox(height: 20),

        Text(
          description,
          textAlign: TextAlign.center,
          style: GoogleFonts.iceland(fontSize: 20, color: Colors.white70),
        ),
      ],
    );
  }
}
