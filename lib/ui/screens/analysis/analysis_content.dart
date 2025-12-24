import 'package:diabetes_app/ui/view_models/analysis_view_model.dart';
import 'package:diabetes_app/ui/widgets/vibe/glitch.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../themes/colors/app_colors.dart';
import 'package:provider/provider.dart';

//widok, logika biznesowa, rysuje dane na podstawie danych z view modela
class AnalysisContent extends StatelessWidget {
  const AnalysisContent({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AnalysisViewModel>();
    final colorScheme = Theme
        .of(context)
        .colorScheme;

    if (vm.isLoading) {
      return Center(
          child: CircularProgressIndicator(color: colorScheme.primary));
    }
    return Stack(
      children: [
        Container(color: Theme
            .of(context)
            .scaffoldBackgroundColor),
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
              _buildSectionTitle("SYSTEM ANALYSIS", context),
              const SizedBox(height: 16),
              _buildCyberContainer(
                context: context,
                color: colorScheme.primary,
                child: _buildTimeInRangeChart(
                    context,
                    vm.stats.ranges['veryHigh'] ?? 0.0,
                    vm.stats.ranges['high'] ?? 0.0,
                    vm.stats.ranges['inTarget'] ?? 0.0,
                    vm.stats.ranges['low'] ?? 0.0,
                    vm.stats.ranges['veryLow'] ?? 0.0),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle("METRICS DATA", context),
              const SizedBox(height: 16),
              _buildMetricsRow(
                context,
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
              _buildMetricsRow(
                context,
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
              _buildSensorUsageCard(context, vm.stats.sensorActivePercent),
              const SizedBox(height: 24),
              _buildSectionTitle("AMBULATORY PROFILE", context),
              const SizedBox(height: 16),
              _buildGlucoseTrendChart(context),
              const SizedBox(height: 24),
              _buildAIAnalysis(context, vm),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCyberContainer({
    required BuildContext context,
    required Widget child,
    required Color color,
  }) {
    final colorScheme = Theme
        .of(context)
        .colorScheme;
    return Container(
      decoration: ShapeDecoration(
        color: colorScheme.surface.withOpacity(0.85),
        shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color, width: 2),
        ),
        shadows: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: -2,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    final colorScheme = Theme
        .of(context)
        .colorScheme;
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
            color: colorScheme.onBackground,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsRow(BuildContext context, {
    required String title1,
    required String value1,
    required String unit1,
    required Color color1,
    required String title2,
    required String value2,
    required String unit2,
    required Color color2,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(context, title1, value1, unit1, color1),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(context, title2, value2, unit2, color2),
        ),
      ],
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value,
      String unit, Color color) {
    final colorScheme = Theme
        .of(context)
        .colorScheme;
    return _buildCyberContainer(
      context: context,
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CyberGlitchText(title,
              style: GoogleFonts.iceland(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  letterSpacing: 1),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CyberGlitchText(
                  value,
                  style: GoogleFonts.vt323(
                      color: color, fontSize: 40, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: CyberGlitchText(unit,
                      style: TextStyle(
                          color: colorScheme.onSurfaceVariant, fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorUsageCard(BuildContext context, double usagePercent) {
    final colorScheme = Theme
        .of(context)
        .colorScheme;
    final statusColor = usagePercent > 70 ? AppColors.green : colorScheme.error;

    return _buildCyberContainer(
      context: context,
      color: statusColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CyberGlitchText("SENSOR STATUS",
                    style: GoogleFonts.vt323(
                        color: colorScheme.onSurfaceVariant, fontSize: 22)),
                const SizedBox(height: 4),
                CyberGlitchText("Signal availability",
                    style: GoogleFonts.iceland(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                        fontSize: 12)),
              ],
            ),
            Row(
              children: [
                CyberGlitchText(
                  "$usagePercent",
                  style: TextStyle(
                      color: usagePercent > 70
                          ? AppColors.green
                          : Colors.redAccent,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 2),
                  child: CyberGlitchText("%",
                      style: TextStyle(
                          color: colorScheme.onSurfaceVariant, fontSize: 12)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInRangeChart(BuildContext context, double veryHigh,
      double high, double inRange, double low, double veryLow) {
    final colorScheme = Theme
        .of(context)
        .colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      color: AppColors.green,
                      value: inRange,
                      title: '${inRange.toInt()}%',
                      radius: 45,
                      titleStyle: GoogleFonts.vt323(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    PieChartSectionData(
                      color: Colors.orange[900],
                      value: veryHigh,
                      title: '${veryHigh.toInt()}%',
                      radius: 40,
                      titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    PieChartSectionData(
                      color: Colors.orangeAccent,
                      value: high,
                      title: '${high.toInt()}%',
                      radius: 40,
                      titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    PieChartSectionData(
                      color: Colors.redAccent,
                      value: low,
                      title: '${low.toInt()}%',
                      radius: 40,
                      titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    PieChartSectionData(
                      color: const Color(0xFF8B0000),
                      value: veryLow,
                      title: '${veryLow.toInt()}%',
                      radius: 40,
                      titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegendItem(context, Colors.orange[900]!,
                      "Very High (>250)", veryHigh),
                  const SizedBox(height: 8),
                  _buildLegendItem(
                      context, Colors.orangeAccent, "High (181-250)", high),
                  const SizedBox(height: 8),
                  _buildLegendItem(
                      context, AppColors.green, "Target (70-180)", inRange),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegendItem(
                      context, Colors.redAccent, "Low (54-69)", low),
                  const SizedBox(height: 8),
                  _buildLegendItem(context, const Color(0xFF8B0000),
                      "Very Low (<54)", veryLow),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, Color color, String label,
      double value) {
    final textColor = Theme
        .of(context)
        .colorScheme
        .onSurfaceVariant;
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.zero),
        ),
        const SizedBox(width: 8),
        CyberGlitchText(label,
            style: GoogleFonts.iceland(
                color: Theme
                    .of(context)
                    .colorScheme
                    .onSurface, fontSize: 14)),
      ],
    );
  }

  Widget _buildGlucoseTrendChart(BuildContext context) {
    final colorScheme = Theme
        .of(context)
        .colorScheme;
    return _buildCyberContainer(
      context: context,
      color: colorScheme.onSurface.withOpacity(0.3),
      child: Container(
        height: 200,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.show_chart,
                    color: colorScheme.primary.withOpacity(0.5), size: 48),
                CyberGlitchText("[ CHART LOADING... ]",
                    style: GoogleFonts.vt323(
                        color: colorScheme.onSurfaceVariant, fontSize: 18)),
              ],
            )),
      ),
    );
  }

  _buildAIAnalysis(BuildContext context, AnalysisViewModel vm) {
    final colorScheme = Theme
        .of(context)
        .colorScheme;
    return _buildCyberContainer(
      context: context,
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
                    onTap: () => vm.generateSmartAnalysis(),
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
                  const SizedBox(width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.purpleAccent)),
                  const SizedBox(width: 10),
                  Text("Computing...",
                      style: GoogleFonts.vt323(color: Colors.grey)),
                ],
              )
            else
              if (vm.aiAnalysisResult.isNotEmpty)
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
