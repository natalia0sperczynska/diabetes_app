import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InsulinInsightCard extends StatelessWidget {
  final bool isHighResistancePhase;
  final bool isHighSensitivityPhase;

  const InsulinInsightCard({
    super.key,
    this.isHighResistancePhase = false,
    this.isHighSensitivityPhase = false,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    String title;
    String description;

    if (isHighResistancePhase) {
      statusColor = Colors.orangeAccent;
      statusIcon = Icons.warning_amber_rounded;
      title = "INSULIN RESISTANCE ALERT";
      description =
          "Luteal phase detected. Hormones may increase glucose levels. Consider higher basal.";
    } else if (isHighSensitivityPhase) {
      statusColor = Colors.greenAccent;
      statusIcon = Icons.trending_down;
      title = "HIGH INSULIN SENSITIVITY";
      description =
          "Follicular phase. You might be more sensitive to insulin. Watch out for hypoglycemia.";
    } else {
      statusColor = Colors.blueGrey;
      statusIcon = Icons.check_circle_outline;
      title = "BASELINE SENSITIVITY";
      description = "Hormonal impact on glucose is minimal right now.";
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withOpacity(0.9),
        border: Border.all(
          color: statusColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.1),
            blurRadius: 10,
          )
        ],
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.iceland(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style:
                      GoogleFonts.roboto(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
