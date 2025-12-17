import 'package:diabetes_app/ui/view_models/analysis_view_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../themes/colors/app_colors.dart';
import 'package:provider/provider.dart';

//widok, logika biznesowa, rysuje dane na podstawie danych z view modela
class AnalysisContent extends StatelessWidget {
  const AnalysisContent({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AnalysisViewModel>();

    if (vm.isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.mainBlue));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Time in Range", context),
          const SizedBox(height: 16),
          _buildTimeInRangeChart(
              vm.stats.ranges['veryHigh'] ?? 0.0,
              vm.stats.ranges['high'] ?? 0.0 ,
              vm.stats.ranges['inTarget'] ?? 0.0,
              vm.stats.ranges['low'] ?? 0.0, vm.stats.ranges['veryLow'] ?? 0.0
          ),
          const SizedBox(height: 24),
          _buildSectionTitle("Glucose Metrics", context),
          const SizedBox(height: 16),

          _buildMetricsRow(title1: "Average Glucose",
            value1: "${vm.stats.averageGlucose.toInt()}",
            unit1: "mg/dL",
            color1: AppColors.mainBlue,
            title2: "GMI  (Glucose Management Indicator)",
            value2: "${vm.stats.gmi}",
            unit2: "%",
            color2: AppColors.pink,),
          const SizedBox(height: 16),
          _buildMetricsRow(
            title1: "Standard Deviation",
            value1: "${vm.stats.standardDeviation.toInt()}",
            unit1: "mg/dL",
            color1: Colors.orangeAccent,
            title2: "Coefficient of Variation",
            value2: "${vm.stats.coefficientOfVariation}",
            unit2: "%",
            color2: Colors.purpleAccent,
          ),
          const SizedBox(height: 16),
          _buildSensorUsageCard(vm.stats.sensorActivePercent),

          const SizedBox(height: 24),
          _buildSectionTitle("Ambulatory Glucose Profile", context),
          const SizedBox(height: 16),
          _buildGlucoseTrendChart(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, context) {
    final textTheme = Theme.of(context).textTheme;
    return Text(title, style: textTheme.headlineMedium);
  }
  Widget _buildMetricsRow({
    required String title1, required String value1, required String unit1, required Color color1,
    required String title2, required String value2, required String unit2, required Color color2,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(title1, value1, unit1, color1),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(title2, value2, unit2, color2),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkBlue1,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(unit,
                    style:
                    const TextStyle(color: Colors.white54, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildSensorUsageCard(double usagePercent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkBlue1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Sensor Active",
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
              SizedBox(height: 4),
              Text("Data availability",
                  style: TextStyle(color: Colors.white30, fontSize: 10)),
            ],
          ),
          Row(
            children: [
              Text(
                "$usagePercent",
                style: TextStyle(
                    color: usagePercent > 70 ? AppColors.green : Colors.redAccent,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 8.0, left: 2),
                child: Text("%", style: TextStyle(color: Colors.white54, fontSize: 12)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTimeInRangeChart(double veryHigh, double high, double inRange, double low, double veryLow) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.darkBlue1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.pixelBorder.withOpacity(0.3)),
      ),
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
                      radius: 50,
                      titleStyle: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    PieChartSectionData(
                      color: Colors.orange[900],
                      value: veryHigh,
                      title: '${veryHigh.toInt()}%',
                      radius: 45,
                      titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    PieChartSectionData(
                      color: Colors.orangeAccent,
                      value: high,
                      title: '${high.toInt()}%',
                      radius: 45,
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
                  _buildLegendItem(Colors.orange[900]!, "Very High (>250)", veryHigh),
                  const SizedBox(height: 8),
                  _buildLegendItem(Colors.orangeAccent, "High (181-250)", high),
                  const SizedBox(height: 8),
                  _buildLegendItem(AppColors.green, "Target (70-180)", inRange),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegendItem(Colors.redAccent, "Low (54-69)", low),
                  const SizedBox(height: 8),
                  _buildLegendItem(const Color(0xFF8B0000), "Very Low (<54)", veryLow),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildLegendItem(Color color, String label, double value) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text("$label: ${value.toInt()}%",
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _buildGlucoseTrendChart() {
    return Container(
        height: 200,
        decoration: BoxDecoration(
            color: AppColors.darkBlue1,
            borderRadius: BorderRadius.circular(16)),
        child: const Center(
            child: Text("Graph Placeholder",
                style: TextStyle(color: Colors.white))));
  }
}
