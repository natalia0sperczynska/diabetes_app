import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:health/health.dart';

import '../../view_models/health_connect_view_model.dart';
import '../../widgets/vibe/glitch.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  late final HealthConnectViewModel _googleFitVm;
  late final HealthConnectViewModel _miFitnessVm;

  @override
  void initState() {
    super.initState();
    // Keep view models stable across rebuilds.
    _googleFitVm = HealthConnectViewModel(source: HealthConnectSource.googleFit);
    _miFitnessVm = HealthConnectViewModel(source: HealthConnectSource.miFitness);
  }

  @override
  void dispose() {
    _googleFitVm.dispose();
    _miFitnessVm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: CyberGlitchText(
                "HEALTH CONNECT",
                style: GoogleFonts.vt323(
                  fontSize: 28,
                  letterSpacing: 2.0,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Google Fit'),
                  Tab(text: 'Mi Fitness'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                ChangeNotifierProvider.value(
                  value: _googleFitVm,
                  child: const _HealthConnectTabBody(
                    source: HealthConnectSource.googleFit,
                  ),
                ),
                ChangeNotifierProvider.value(
                  value: _miFitnessVm,
                  child: const _MiFitnessDashboardTab(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HealthConnectTabBody extends StatelessWidget {
  final HealthConnectSource source;

  const _HealthConnectTabBody({required this.source});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HealthConnectViewModel>();
    final colorScheme = Theme.of(context).colorScheme;

    // Only show the setup hint for the new Mi Fitness tab, and only when we
    // have permissions but are not seeing any data from that origin.
    final showMiHint =
        source == HealthConnectSource.miFitness &&
            viewModel.isAuthorized &&
            !viewModel.isLoading &&
            viewModel.healthDataList.isEmpty;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(width: 4, height: 24, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  CyberGlitchText(
                    "STATISTICS",
                    style: GoogleFonts.iceland(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            if (!viewModel.isAuthorized)
              Expanded(
                child: Center(
                  child: ElevatedButton(
                    onPressed: () => viewModel.authorize(),
                    child: const Text("Connect to Health Connect"),
                  ),
                ),
              )
            else
              Expanded(
                child: viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                  onRefresh: () => viewModel.fetchData(),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    children: [
                      if (showMiHint) ...[
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  "No data from Mi Fitness yet.",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Open Mi Fitness → Settings → Health Connect and enable sharing (Steps).\n"
                                      "Then come back and pull-to-refresh.",
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      _SummaryCard(steps: viewModel.steps),
                      const SizedBox(height: 12),
                      _StatsGrid(
                        peakHourlySteps: viewModel.peakHourlySteps,
                        peakHourStart: viewModel.peakHourStart,
                        activeHours: viewModel.activeHours,
                        avgStepsPerHour: viewModel.avgStepsPerHour,
                      ),
                      const SizedBox(height: 16),
                      const _SectionHeader(
                        title: "STEPS (LAST 24H)",
                        subtitle: "Hourly total",
                      ),
                      const SizedBox(height: 10),
                      _StepsLineChart(hourly: viewModel.hourlySteps),
                      const SizedBox(height: 14),
                      _RawDataExpansion(points: viewModel.healthDataList),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: viewModel.isAuthorized
          ? FloatingActionButton(
        onPressed: () => viewModel.fetchData(),
        child: const Icon(Icons.refresh),
      )
          : null,
    );
  }
}

class _MiFitnessDashboardTab extends StatelessWidget {
  const _MiFitnessDashboardTab();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HealthConnectViewModel>();
    final cs = Theme.of(context).colorScheme;

    if (!vm.isAuthorized) {
      return Center(
        child: ElevatedButton(
          onPressed: vm.authorize,
          child: const Text("Connect to Health Connect"),
        ),
      );
    }

    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: vm.fetchData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Row(
            children: [
              Container(width: 4, height: 24, color: cs.primary),
              const SizedBox(width: 8),
              CyberGlitchText(
                "MI FITNESS",
                style: GoogleFonts.iceland(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Top: Calories / Steps / Moving
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                children: [
                  Expanded(
                    child: _TopMetric(
                      icon: Icons.local_fire_department,
                      title: "Calories",
                      value: vm.caloriesKcal.toString(),
                      sub: "/500 kcal",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TopMetric(
                      icon: Icons.directions_walk,
                      title: "Steps",
                      value: vm.steps.toString(),
                      sub: "/10000 steps",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TopMetric(
                      icon: Icons.directions_run,
                      title: "Moving",
                      value: vm.movingMinutes.toString(),
                      sub: "/30 mins",
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Tiles (no blood pressure / no heart rate)
          Row(
            children: [
              Expanded(
                child: _TileCard(
                  icon: Icons.bedtime_outlined,
                  title: "Sleep",
                  value: _formatDuration(vm.sleepDuration),
                  subtitle: "Last 24h",
                  locked: !vm.hasAdditionalPermissions,
                  onEnable: vm.requestAdditionalPermissions,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TileCard(
                  icon: Icons.bloodtype_outlined,
                  title: "Blood oxygen",
                  value: vm.latestBloodOxygenPercent == null
                      ? "-"
                      : "${vm.latestBloodOxygenPercent!.round()}%",
                  subtitle: "",
                  locked: !vm.hasAdditionalPermissions,
                  onEnable: vm.requestAdditionalPermissions,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          const _SectionHeader(
            title: "STEPS (LAST 24H)",
            subtitle: "Hourly total",
          ),
          const SizedBox(height: 10),
          _StepsLineChart(hourly: vm.hourlySteps),

          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Text(
                vm.hasAdditionalPermissions
                    ? "Pull down to refresh. Data is filtered to Mi Fitness origin in Health Connect."
                    : "Sleep/Blood oxygen require additional Health Connect read permissions. "
                    "They are requested only after you tap Enable.",
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDuration(Duration d) {
    if (d == Duration.zero) return "-";
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h <= 0) return "${m}m";
    return "${h}h ${m.toString().padLeft(2, '0')}m";
  }
}

class _TopMetric extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String sub;

  const _TopMetric({
    required this.icon,
    required this.title,
    required this.value,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                title,
                style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          sub,
          style: t.bodySmall,
        ),
      ],
    );
  }
}

class _TileCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final bool locked;
  final Future<void> Function() onEnable;

  const _TileCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.locked,
    required this.onEnable,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (!locked) ...[
              Text(
                value,
                style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(subtitle, style: t.bodySmall),
              ],
            ] else ...[
              Text(
                "Locked",
                style: t.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                "Tap Enable to grant additional permissions",
                style: t.bodySmall,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  await onEnable();
                },
                child: const Text("Enable"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _SectionHeader({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.iceland(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int steps;

  const _SummaryCard({required this.steps});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.directions_walk, size: 42),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$steps",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Total steps (last 24h)",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final int peakHourlySteps;
  final DateTime? peakHourStart;
  final int activeHours;
  final double avgStepsPerHour;

  const _StatsGrid({
    required this.peakHourlySteps,
    required this.peakHourStart,
    required this.activeHours,
    required this.avgStepsPerHour,
  });

  String _fmtHour(DateTime? dt) {
    if (dt == null) return "-";
    final h = dt.hour.toString().padLeft(2, '0');
    return "$h:00";
  }

  @override
  Widget build(BuildContext context) {
    final items = <_StatTileData>[
      _StatTileData(
        icon: Icons.show_chart,
        label: "Peak hour",
        value: _fmtHour(peakHourStart),
      ),
      _StatTileData(
        icon: Icons.flash_on,
        label: "Peak steps/hr",
        value: "$peakHourlySteps",
      ),
      _StatTileData(
        icon: Icons.timelapse,
        label: "Active hours",
        value: "$activeHours / 24",
      ),
      _StatTileData(
        icon: Icons.av_timer,
        label: "Avg steps/hr",
        value: avgStepsPerHour.isNaN ? "0" : avgStepsPerHour.round().toString(),
      ),
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) => _StatTile(items[index]),
    );
  }
}

class _StatTileData {
  final IconData icon;
  final String label;
  final String value;

  const _StatTileData({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _StatTile extends StatelessWidget {
  final _StatTileData data;
  const _StatTile(this.data);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(data.icon, color: cs.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.value,
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.label,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepsLineChart extends StatelessWidget {
  final List<HourlySteps> hourly;
  const _StepsLineChart({required this.hourly});

  @override
  Widget build(BuildContext context) {
    if (hourly.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text("No step data for the last 24 hours."),
        ),
      );
    }

    final maxY =
    hourly.map((e) => e.steps).fold<int>(0, (a, b) => a > b ? a : b);
    final yTop = (maxY == 0) ? 10.0 : (maxY * 1.2);

    final spots = <FlSpot>[];
    for (int i = 0; i < hourly.length; i++) {
      spots.add(FlSpot(i.toDouble(), hourly[i].steps.toDouble()));
    }

    String hourLabel(int idx) {
      final dt = hourly[idx.clamp(0, hourly.length - 1)].hourStart;
      return dt.hour.toString().padLeft(2, '0');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
        child: SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: (hourly.length - 1).toDouble(),
              minY: 0,
              maxY: yTop,
              gridData: const FlGridData(show: true),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: yTop <= 50 ? 10 : (yTop / 4),
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.round().toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 6,
                    getTitlesWidget: (value, meta) {
                      final idx = value.round();
                      if (idx < 0 || idx >= hourly.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          hourLabel(idx),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  tooltipPadding: const EdgeInsets.all(8),
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((s) {
                      final idx = s.x.round().clamp(0, hourly.length - 1);
                      final h = hourLabel(idx);
                      final steps = s.y.round();
                      return LineTooltipItem(
                        "$h:00  •  $steps steps",
                        Theme.of(context).textTheme.bodySmall ??
                            const TextStyle(),
                      );
                    }).toList();
                  },
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: true),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RawDataExpansion extends StatelessWidget {
  final List<HealthDataPoint> points;
  const _RawDataExpansion({required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();

    final sorted = [...points]..sort((a, b) => b.dateFrom.compareTo(a.dateFrom));

    return Card(
      child: ExpansionTile(
        title: const Text("Raw data (debug)"),
        subtitle: Text("${sorted.length} records"),
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sorted.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final p = sorted[index];
              return ListTile(
                dense: true,
                leading: const Icon(Icons.bug_report_outlined),
                title:
                Text(p.type.toString().split('.').last.replaceAll('_', ' ')),
                subtitle: Text("${p.value}\n${p.dateFrom} → ${p.dateTo}"),
                isThreeLine: true,
              );
            },
          ),
        ],
      ),
    );
  }
}
