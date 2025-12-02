import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class Chart extends StatefulWidget {
  final String title;
  final List<FlSpot> glucoseSpots;

  const Chart({super.key, required this.title, required this.glucoseSpots});

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  var baselineX = 12.0;
  var baselineY = 100.0;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: Padding(
        padding: const EdgeInsets.only(top: 18.0, right: 18.0,bottom: 18.0,
          left: 0.0,),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                children: [
                  RotatedBox(
                    quarterTurns: 1,
                    child: Slider(
                      value: baselineY,
                      onChanged: (newValue) {
                        setState(() {
                          baselineY = newValue;
                        });
                      },
                      min: 40,
                      max: 300,
                    ),
                  ),
                  Expanded(
                    child: _Chart(baselineX, baselineY, widget.glucoseSpots),
                  ),
                ],
              ),
            ),
            Slider(
              value: baselineX,
              onChanged: (newValue) {
                setState(() {
                  baselineX = newValue;
                });
              },
              min: 0,
              max: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class _Chart extends StatelessWidget {
  final double baselineX;
  final double baselineY;
  final List<FlSpot> glucoseSpots;

  const _Chart(this.baselineX, this.baselineY, this.glucoseSpots) : super();

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    if (value % 2 != 0) {
      return const SizedBox.shrink();
    }

    final String timeText = "${value.toInt()}:00";

    return SideTitleWidget(
      meta: meta,
      child: Text(
        timeText,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    return SideTitleWidget(
      meta: meta,
      child: Text(
        value.toInt().toString(),
        style: const TextStyle(color: Colors.white70, fontSize: 10),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: glucoseSpots,
            isCurved: true,
            barWidth: 4,
            isStrokeCapRound: true,
            color: theme.hintColor,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  theme.primaryColor.withOpacity(0.8),
                  theme.primaryColor.withOpacity(0.5),
                  theme.primaryColor.withOpacity(0.3),
                  theme.primaryColor.withOpacity(0.1),
                ],
              ),
              show: true,
            ),
          ),
        ],
        rangeAnnotations: RangeAnnotations(
          horizontalRangeAnnotations: [
            HorizontalRangeAnnotation(
              y1: 70,
              y2: 180,
              color: Colors.green.withOpacity(0.08),
            ),
          ],
        ),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: baselineY,
              color: Colors.white,
              strokeWidth: 1,
              dashArray: [5, 5],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12
                ),
                labelResolver: (line) => "${line.y.toInt()}",
              ),
            ),
          ],
          verticalLines: [
            VerticalLine(
              x: baselineX,
              color: Colors.white,
              strokeWidth: 1,
              dashArray: [5, 5],
              label: VerticalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12
                ),
                labelResolver: (line) {
                  int h = line.x.toInt();
                  int m = ((line.x - h) * 60).toInt();
                  return "$h:${m.toString().padLeft(2, '0')}";
                },
              ),
            ),
          ],
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: bottomTitleWidgets,
              reservedSize: 32,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 50,
              getTitlesWidget: leftTitleWidgets,
              reservedSize: 30,
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),

        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          verticalInterval: 1,
          horizontalInterval: 50,
          getDrawingHorizontalLine: (value) => const FlLine(
            color: Colors.white10,
            strokeWidth: 1,
          ),
          getDrawingVerticalLine: (value) {
            if (value % 6 == 0) {
              return const FlLine(color: Colors.white24, strokeWidth: 1);
            }
            return const FlLine(color: Colors.white10, strokeWidth: 0.5);
          },
        ),
        minX: 0,
        maxX: 24,
        minY: 40,
        maxY: 300,
      ),
      duration: Duration.zero,
    );
  }
}