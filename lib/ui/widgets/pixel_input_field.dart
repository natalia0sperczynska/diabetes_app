import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../themes/colors/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class PixelInputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final Function(String) onChanged;
  final String? suffix;
  final TextInputType keyboardType;
  final int maxLength;

  const PixelInputField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.onChanged,
    this.suffix,
    this.keyboardType = TextInputType.number,
    this.maxLength = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.iceland(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.mainBlue,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.darkBlue1,
            border: Border.all(color: AppColors.mainBlue, width: 2),
            borderRadius: BorderRadius.zero,
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: GoogleFonts.iceland(
              fontSize: 20,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
            onChanged: onChanged,
            maxLength: maxLength,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.iceland(
                fontSize: 18,
                color: Colors.white54,
                letterSpacing: 1.2,
              ),
              suffixText: suffix,
              suffixStyle: GoogleFonts.iceland(
                fontSize: 16,
                color: AppColors.mainComplement,
                letterSpacing: 1.2,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: InputBorder.none,
              counterText: '',
            ),
          ),
        ),
      ],
    );
  }
}
