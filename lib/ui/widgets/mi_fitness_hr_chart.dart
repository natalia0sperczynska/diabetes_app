import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Simple 24h heart-rate bar chart (Mi Fitness style).
///
/// Made generic so it can be fed with any sample type.
/// Provide [timeOf] and [bpmOf] to extract values.
class MiFitnessHrChart<T> extends StatelessWidget {
  final List<T> samples;

  final DateTime Function(T sample) timeOf;
  final double Function(T sample) bpmOf;

  final double minY;
  final double maxY;

  const MiFitnessHrChart({
    super.key,
    required this.samples,
    required this.timeOf,
    required this.bpmOf,
    this.minY = 0,
    this.maxY = 200,
  });

  @override
  Widget build(BuildContext context) {
    if (samples.isEmpty) {
      return _EmptyHrCard();
    }

    final now = DateTime.now();
    final start = now.subtract(const Duration(hours: 24));

    const binMinutes = 10;
    final binCount = (24 * 60 ~/ binMinutes);

    final bins = List<double?>.filled(binCount, null);

    for (final s in samples) {
      final t = timeOf(s);
      final bpm = bpmOf(s);

      if (t.isBefore(start) || t.isAfter(now)) continue;

      final minutes = t.difference(start).inMinutes;
      final idx = minutes ~/ binMinutes;
      if (idx < 0 || idx >= binCount) continue;

      // Keep max in bin (visually closer to Mi Fitness spikes)
      final cur = bins[idx];
      if (cur == null || bpm > cur) bins[idx] = bpm;
    }

    // FIX: do NOT add empty groups for missing bins -> removes baseline "dots"
    final groups = <BarChartGroupData>[];
    for (int i = 0; i < binCount; i++) {
      final v = bins[i];
      if (v == null) continue;

      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: v,
              width: 3,
              borderRadius: BorderRadius.circular(2),
            ),
          ],
        ),
      );
    }

    // Pick the latest by time (samples may not be sorted).
    final latest = samples.reduce((a, b) {
      final ta = timeOf(a);
      final tb = timeOf(b);
      return tb.isAfter(ta) ? b : a;
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Heart rate',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  '${bpmOf(latest).round()}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(width: 6),
                Text(
                  'BPM',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                Text(
                  _fmtTime(timeOf(latest)),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  minY: minY,
                  maxY: maxY,
                  barGroups: groups,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 50,
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.round().toString(),
                            style: Theme.of(context).textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: (60 / binMinutes), // every hour
                        getTitlesWidget: (value, meta) {
                          final bin = value.toInt();
                          final hour = (bin * binMinutes) ~/ 60;
                          if (hour % 6 != 0) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              '${hour.toString().padLeft(2, '0')}:00',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final hour = ((group.x * binMinutes) ~/ 60)
                            .toString()
                            .padLeft(2, '0');
                        final minute = ((group.x * binMinutes) % 60)
                            .toString()
                            .padLeft(2, '0');
                        return BarTooltipItem(
                          '${rod.toY.round()} BPM\n$hour:$minute',
                          Theme.of(context).textTheme.bodySmall!,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pull down to refresh. Data is read from Health Connect HeartRateRecord samples.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  static String _fmtTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _EmptyHrCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'No heart rate samples found in Health Connect for Mi Fitness.\n'
              'If Mi Fitness does not export HR samples (only summaries), this chart will stay empty.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
