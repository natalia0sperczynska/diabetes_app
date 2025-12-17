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
          _buildTimeInRangeChart(vm.stats.timeInTarget, vm.stats.timeHigh, vm.stats.timeLow),
          const SizedBox(height: 24),
          _buildSectionTitle("Glucose Metrics", context),
          const SizedBox(height: 16),
          _buildMetricsRow(vm.stats.averageGlucose, vm.stats.gmi),
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

  Widget _buildTimeInRangeChart(double inRange, double high, double low) {
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
              height: 150,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 30,
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
                  ],
                ),
              ),
            ),
          ),
          // Legenda...
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("In Range: ${inRange.toInt()}%",
                  style: TextStyle(color: AppColors.green)),
              Text("High: ${high.toInt()}%",
                  style: TextStyle(color: Colors.orangeAccent)),
              Text("Low: ${low.toInt()}%",
                  style: TextStyle(color: Colors.redAccent)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMetricsRow(double avgGlucose, double gmi) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard("Average Glucose", "${avgGlucose.toInt()}",
              "mg/dL", AppColors.mainBlue),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard("GMI", "$gmi", "%", AppColors.pink),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
      String title, String value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkBlue1,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
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
