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
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(4.0),
            decoration: const BoxDecoration(
              color: AppColors.darkBlue1,
              borderRadius: BorderRadius.zero,
              boxShadow: [
                BoxShadow(
                  color: AppColors.grey,
                  offset: Offset(4, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.all(4.0),
              decoration: const BoxDecoration(color: AppColors.darkBlue2),
              child: Stack(
                children: [
                  Image.asset(image, height: 220, fit: BoxFit.contain),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.iceland(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppColors.mainBlue,
              letterSpacing: 1.5,
              shadows: [
                const Shadow(
                  offset: Offset(2, 2),
                  blurRadius: 0,
                  color: Colors.black,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              border: Border.all(
                color: AppColors.mainBlue.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              description.toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.iceland(
                fontSize: 20,
                color: AppColors.green,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
