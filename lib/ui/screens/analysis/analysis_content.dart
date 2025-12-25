import 'package:diabetes_app/ui/screens/analysis/widgets/analysis_ai.dart';
import 'package:diabetes_app/ui/screens/analysis/widgets/analysis_best_day.dart';
import 'package:diabetes_app/ui/screens/analysis/widgets/analysis_clinical_benchmarks.dart';
import 'package:diabetes_app/ui/screens/analysis/widgets/analysis_glucose_trend.dart';
import 'package:diabetes_app/ui/screens/analysis/widgets/analysis_mertics.dart';
import 'package:diabetes_app/ui/screens/analysis/widgets/analysis_sensor_usage.dart';
import 'package:diabetes_app/ui/screens/analysis/widgets/analysis_time_in_range.dart';
import 'package:diabetes_app/ui/screens/analysis/widgets/analysis_title.dart';
import 'package:diabetes_app/ui/view_models/analysis_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//widok, logika biznesowa, rysuje dane na podstawie danych z view modela
class AnalysisContent extends StatelessWidget {
  const AnalysisContent({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AnalysisViewModel>();
    final colorScheme = Theme.of(context).colorScheme;

    if (vm.isLoading) {
      return Center(
          child: CircularProgressIndicator(color: colorScheme.primary));
    }
    return Stack(
      children: [
        Container(color: Theme.of(context).scaffoldBackgroundColor),
        Positioned.fill(
          child: Opacity(
            opacity: 0.15,
            child: Image.asset(
              'assets/images/grid.png',
              repeat: ImageRepeat.repeat,
              scale: 1.0,
            ),
          ),
        ),
        SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AnalysisTitle(title: "SYSTEM ANALYSIS"),
              const SizedBox(height: 16),
              AnalysisTimeInRange(
                veryHigh: vm.stats.ranges['veryHigh'] ?? 0.0,
                high: vm.stats.ranges['high'] ?? 0.0,
                inRange: vm.stats.ranges['inTarget'] ?? 0.0,
                low: vm.stats.ranges['low'] ?? 0.0,
                veryLow: vm.stats.ranges['veryLow'] ?? 0.0,
              ),
              const SizedBox(height: 24),
              const AnalysisTitle(title: "METRICS DATA"),
              const SizedBox(height: 16),
              AnalysisMetrics(
                title1: "AVERAGE GLUCOSE",
                value1: "${vm.stats.averageGlucose.toInt()}",
                unit1: "mg/dL",
                color1: colorScheme.primary,
                title2: "GMI  (GLUCOSE MANAGEMENT INDICATOR)",
                value2: "${vm.stats.gmi}",
                unit2: "%",
                color2: colorScheme.secondary,
              ),
              const SizedBox(height: 16),
              AnalysisMetrics(
                title1: "STANDARD DEVIATION",
                value1: "${vm.stats.standardDeviation.toInt()}",
                unit1: "mg/dL",
                color1: colorScheme.tertiary,
                title2: "COEFFICIENT OF VARIATION",
                value2: "${vm.stats.coefficientOfVariation}",
                unit2: "%",
                color2: colorScheme.error,
              ),
              const SizedBox(height: 16),
              AnalysisSensorUsage(usagePercent: vm.stats.sensorActivePercent),
              const SizedBox(height: 24),
              const AnalysisTitle(title: "AMBULATORY PROFILE"),
              const SizedBox(height: 16),
              const AnalysisGlucoseTrend(),
              const SizedBox(height: 24),
              const AnalysisTitle(title: "CLINICAL BENCHMARKS"),
              const SizedBox(height: 16),
              const AnalysisBenchmarks(),
              const SizedBox(height: 24),
              const AnalysisTitle(title: "TEMPORAL ANOMALY SCAN"),
              const AnalysisTitle(title: "ACHIEVEMENTS"),
              BestDayWidget(bestDayText: vm.bestDayText),
              const SizedBox(height: 24),
              const AnalysisTitle(title: "AI DIAGNOSTIC"),
              const AnalysisAI(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}