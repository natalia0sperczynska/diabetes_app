import 'package:diabetes_app/ui/view_models/analysis_view_model.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'analysis_container.dart';

class AnalysisGlucoseTrend extends StatelessWidget {
  const AnalysisGlucoseTrend({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AnalysisViewModel>();
    final agpData = vm.agpData;
    final colorScheme = Theme.of(context).colorScheme;
    if (agpData.isEmpty) {
      return const AnalysisContainer(
          color: Colors.blueAccent,
          child: SizedBox(
              height: 200,
              child: Center(
                  child: Text("Not enough data to generate AGP.",
                      style: TextStyle(color: Colors.white)))));
    }
    return AnalysisContainer(
      color: colorScheme.onSurface.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("AMBULATORY GLUCOSE PROFILE (AGP)",
                style: GoogleFonts.vt323(fontSize: 20, color: Colors.white)),
            Text("24h Trend (Median & Percentiles)",
                style: GoogleFonts.shareTechMono(fontSize: 12, color: Colors.white70)),

            const SizedBox(height: 24),

            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  minY: 40,
                  maxY: 350,
                  minX: 0,
                  maxX: 24,


                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 50,
                    verticalInterval: 6,
                    getDrawingHorizontalLine: (value) {
                      if (value == 70 || value == 180) {
                        return const FlLine(color: Colors.white54, strokeWidth: 1, dashArray: [5, 5]);
                      }
                      return FlLine(color: Colors.white.withOpacity(0.1), strokeWidth: 1);
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(color: Colors.white.withOpacity(0.1), strokeWidth: 1);
                    },
                  ),


                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 6,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0: return const Text("12 AM", style: TextStyle(color: Colors.white70, fontSize: 10));
                            case 6: return const Text("6 AM", style: TextStyle(color: Colors.white70, fontSize: 10));
                            case 12: return const Text("12 PM", style: TextStyle(color: Colors.white70, fontSize: 10));
                            case 18: return const Text("6 PM", style: TextStyle(color: Colors.white70, fontSize: 10));
                            case 24: return const Text("12 AM", style: TextStyle(color: Colors.white70, fontSize: 10));
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 50,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value == 40 || value == 350) return const SizedBox();
                          return Text(value.toInt().toString(), style: const TextStyle(color: Colors.white70, fontSize: 10));
                        },
                      ),
                    ),
                  ),

                  borderData: FlBorderData(show: false),

                  lineBarsData: [

                    LineChartBarData(
                      spots: agpData.map((e) => FlSpot(e.hour.toDouble(), e.p50)).toList(),
                      isCurved: true,
                      color: Colors.white,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),


                    LineChartBarData(
                      spots: agpData.map((e) => FlSpot(e.hour.toDouble(), e.p75)).toList(),
                      isCurved: true,
                      color: Colors.transparent,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ),

                    LineChartBarData(
                      spots: agpData.map((e) => FlSpot(e.hour.toDouble(), e.p25)).toList(),
                      isCurved: true,
                      color: Colors.white.withOpacity(0.5),
                      barWidth: 1,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}