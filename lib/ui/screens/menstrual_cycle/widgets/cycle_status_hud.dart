import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../themes/colors/app_colors.dart';

class CycleStatusHud extends StatelessWidget {
  final int dayOfCycle;
  final String phaseName;

  const CycleStatusHud({
    super.key,
    required this.dayOfCycle,
    required this.phaseName,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.mainBlue, width: 3),
            color: Colors.black.withOpacity(0.5),
            boxShadow: [
              BoxShadow(
                  color: AppColors.mainBlue.withOpacity(0.4),
                  blurRadius: 15
              )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  "DAY",
                  style: GoogleFonts.iceland(color: Colors.white70, fontSize: 14)
              ),
              Text(
                "$dayOfCycle",
                style: GoogleFonts.vt323(
                    fontSize: 42,
                    color: Colors.white,
                    height: 1.0
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "CURRENT PHASE:",
                style: GoogleFonts.iceland(
                    color: AppColors.mainBlue,
                    fontSize: 16
                ),
              ),
              Text(
                phaseName.toUpperCase(),
                style: GoogleFonts.vt323(fontSize: 32, color: Colors.white),
              ),
              const SizedBox(height: 4),

              LinearProgressIndicator(
                value: 0.8, // obliczanie dnisa
                backgroundColor: Colors.white10,
                color: Colors.pinkAccent,
                minHeight: 6,
              ),
              const SizedBox(height: 4),
              Text(
                "Est. 4 days to next cycle",
                style: GoogleFonts.roboto(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        )
      ],
    );
  }
}