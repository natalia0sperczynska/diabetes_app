import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Chart extends StatefulWidget {
  final String title;
  final List<FlSpot> glucoseSpots;

  final Function(FlSpot?)? onSpotHover;

  const Chart({
    super.key,
    required this.title,
    required this.glucoseSpots,
    this.onSpotHover,
  });

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
        padding: const EdgeInsets.all(18.0),
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
                      onChanged: (newValue) => setState(() => baselineY = newValue),
                      min: 40,
                      max: 300,
                      activeColor: Colors.blueGrey,
                      inactiveColor: Colors.white10,
                    ),
                  ),
                  Expanded(
                    child: _ChartGraph(
                      baselineX: baselineX,
                      baselineY: baselineY,
                      glucoseSpots: widget.glucoseSpots,
                      onSpotHover: widget.onSpotHover,
                    ),
                  ),
                ],
              ),
            ),
            Slider(
              value: baselineX,
              onChanged: (newValue) => setState(() => baselineX = newValue),
              min: 0,
              max: 24,
              activeColor: Colors.blueGrey,
              inactiveColor: Colors.white10,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartGraph extends StatelessWidget {
  final double baselineX;
  final double baselineY;
  final List<FlSpot> glucoseSpots;
  final Function(FlSpot?)? onSpotHover;

  const _ChartGraph({
    required this.baselineX,
    required this.baselineY,
    required this.glucoseSpots,
    this.onSpotHover,
  });

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) => Colors.transparent,
            getTooltipItems: (spots) => spots.map((e) => null).toList(),
          ),
          touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
            if (event is FlPanEndEvent || event is FlTapUpEvent || event is FlLongPressEnd) {
              onSpotHover?.call(null);
            }
            else if (touchResponse != null && touchResponse.lineBarSpots != null) {
              final spot = touchResponse.lineBarSpots!.first;
              onSpotHover?.call(spot);
            }
          },
        ),

        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          verticalInterval: 1,
          horizontalInterval: 50,
          getDrawingHorizontalLine: (value) => const FlLine(color: Colors.white10, strokeWidth: 1),
          getDrawingVerticalLine: (value) {
            if (value % 6 == 0) return const FlLine(color: Colors.white24, strokeWidth: 1);
            return const FlLine(color: Colors.white10, strokeWidth: 0.5);
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 4,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: GoogleFonts.vt323(color: Colors.white54, fontSize: 14),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 50,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                return Text(
                  value.toInt().toString(),
                  style: GoogleFonts.vt323(color: Colors.white54, fontSize: 14),
                );
              },
              reservedSize: 40,
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),

        minX: 0, maxX: 24, minY: 40, maxY: 300,
        lineBarsData: [
          LineChartBarData(
            spots: glucoseSpots,
            isCurved: true,
            color: const Color(0xFF00E5FF),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF00E5FF).withOpacity(0.3),
                  const Color(0xFF00E5FF).withOpacity(0.0),
                ],
              ),
            ),
          ),
          LineChartBarData(
            spots: [const FlSpot(0, 0), const FlSpot(24, 0)].map((e) => FlSpot(e.x, baselineY)).toList(),
            isCurved: false,
            color: Colors.white24,
            barWidth: 1,
            dashArray: [5, 5],
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}