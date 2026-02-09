import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../themes/colors/app_colors.dart';
import '../../../view_models/analysis_view_model.dart';
import 'analysis_container.dart';

class AnalysisBenchmarks extends StatelessWidget {
  const AnalysisBenchmarks({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AnalysisViewModel>();
    final colorScheme = Theme.of(context).colorScheme;
    return AnalysisContainer(
      color: colorScheme.inversePrimary,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGoalBar(
                context, "AVERAGE GLUCOSE", vm.stats.averageGlucose, 156,
                isMinGoal: false, unit: "mg/dL", maxValueForBar: 250),
            const SizedBox(height: 12),
            _buildGoalBar(context, "GMI", vm.stats.gmi, 7,
                isMinGoal: false, unit: "%", maxValueForBar: 12),
            const SizedBox(height: 12),
            _buildGoalBar(context, "GLUCOSE STABILITY (CV)",
                vm.stats.coefficientOfVariation, 36,
                isMinGoal: false, unit: "%", maxValueForBar: 60),
            const SizedBox(height: 12),
            _buildGoalBar(
                context, "TIR (Target)", vm.stats.ranges['inTarget'] ?? 0, 70,
                isMinGoal: true, unit: "%", maxValueForBar: 100),
            const SizedBox(height: 12),
            _buildGoalBar(
                context, "SENSOR ACTIVE", vm.stats.sensorActivePercent, 80,
                isMinGoal: true, unit: "%", maxValueForBar: 100),
            const SizedBox(height: 12),
            _buildGoalBar(context, "HYPO RISK",
                (vm.stats.ranges['low']! + vm.stats.ranges['veryLow']!), 4,
                isMinGoal: false, unit: "%", maxValueForBar: 15),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalBar(
      BuildContext context, String label, double value, double goal,
      {required bool isMinGoal,
      required String unit,
      required double maxValueForBar}) {
    bool isGood = isMinGoal ? value >= goal : value <= goal;
    Color statusColor = isGood ? AppColors.green : Colors.redAccent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: GoogleFonts.shareTechMono(
                    color: Colors.grey, fontSize: 12)),
            Text(
                "ACTUAL: ${value.toInt()}$unit/ GOAL: ${isMinGoal ? '>' : '<'}$goal$unit",
                style: GoogleFonts.shareTechMono(
                    color: statusColor, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        LayoutBuilder(builder: (context, constraints) {
          final double maxWidth = constraints.maxWidth;
          double goalPosition =
              (goal / maxValueForBar).clamp(0.0, 1.0) * maxWidth;

          return Stack(
            children: [
              Container(height: 8, width: maxWidth, color: Colors.black45),
              FractionallySizedBox(
                widthFactor: (value / maxValueForBar).clamp(0.0, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    boxShadow: [
                      BoxShadow(
                          color: statusColor.withOpacity(0.5), blurRadius: 6)
                    ],
                  ),
                ),
              ),
              Positioned(
                left: goalPosition,
                child: Container(width: 2, height: 8, color: Colors.white),
              )
            ],
          );
        })
      ],
    );
  }
}
