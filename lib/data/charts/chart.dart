import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Chart extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0),
        child: LineChart(
          LineChartData(
            rangeAnnotations: RangeAnnotations(
              horizontalRangeAnnotations: [
                HorizontalRangeAnnotation(
                  y1: 70,
                  y2: 180,
                  color: const Color(0xFF00FF00).withOpacity(0.2),
                ),
                HorizontalRangeAnnotation(
                  y1: 50,
                  y2: 50.5,
                  color: Colors.red.withOpacity(0.5),
                ),
              ],
            ),

            lineTouchData: LineTouchData(
              handleBuiltInTouches: true,

              getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
                return spotIndexes.map((spotIndex) {
                  return TouchedSpotIndicatorData(
                    const FlLine(
                      color: Colors.white54,
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    ),
                    FlDotData(
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 5,
                          color: Colors.cyanAccent,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                  );
                }).toList();
              },

              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (spot) => Colors.transparent,
                getTooltipItems: (spots) => spots.map((e) => null).toList(),
              ),

              touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
                if (event is FlPanEndEvent || event is FlTapUpEvent || event is FlLongPressEnd) {
                  onSpotHover?.call(null);
                } else if (touchResponse != null && touchResponse.lineBarSpots != null) {
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
              getDrawingHorizontalLine: (value) {
                if (value == 70 || value == 180) {
                  return FlLine(color: Colors.green.withOpacity(0.3), strokeWidth: 1);
                }
                return const FlLine(color: Colors.white10, strokeWidth: 1);
              },
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
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        value.toInt().toString(),
                        style: GoogleFonts.vt323(color: Colors.white54, fontSize: 14),
                      ),
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
                    Color textColor = Colors.white54;
                    if(value >= 250) textColor = Colors.orangeAccent.withOpacity(0.7);
                    if(value <= 60) textColor = Colors.redAccent.withOpacity(0.7);

                    return Text(
                      value.toInt().toString(),
                      style: GoogleFonts.vt323(color: textColor, fontSize: 14),
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
            ],
          ),
          duration: Duration.zero,
        ),
      ),
    );
  }
}