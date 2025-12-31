import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:diabetes_app/ui/view_models/statistics_view_model.dart';
import 'package:diabetes_app/data/charts/chart.dart';
import '../../themes/colors/app_colors.dart';
import 'package:diabetes_app/ui/widgets/vibe/glitch.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  FlSpot? _hoverSpot;

  Future<void> _selectDate(BuildContext context, StatisticsViewModel viewModel) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: viewModel.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
            dialogBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                textStyle: GoogleFonts.vt323(fontSize: 18),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != viewModel.selectedDate) {
      viewModel.updateSelectedDate(picked);
      setState(() => _hoverSpot = null);
    }
  }

  Color _getStatusColor(double value) {
    if (value < 70) return const Color(0xFFFF0000);
    if (value > 250) return const Color(0xFFFF9100);
    if (value > 180) return const Color(0xFFFFFF00);
    return const Color(0xFF00FF00);
  }

  String _getStatusLabel(double value) {
    if (value < 70) return "HYPOGLYCEMIA";
    if (value > 250) return "HYPERGLYCEMIA";
    if (value > 180) return "HIGH GLUCOSE";
    return "TARGET RANGE";
  }

  IconData _getTrendIcon(double currentY, List<FlSpot> allSpots) {
    int index = allSpots.indexWhere((s) => s.y == currentY);
    if (index <= 0) return Icons.arrow_forward;

    double previous = allSpots[index - 1].y;
    double diff = currentY - previous;

    if (diff > 2) return Icons.arrow_upward;
    if (diff > 1) return Icons.north_east;
    if (diff < -2) return Icons.arrow_downward;
    if (diff < -1) return Icons.south_east;
    return Icons.arrow_forward;
  }

  Widget _buildGlucoseHUD(BuildContext context, StatisticsViewModel viewModel) {
    if (viewModel.glucoseSpots.isEmpty) return const SizedBox.shrink();

    final activeSpot = _hoverSpot ?? viewModel.glucoseSpots.last;
    final currentValue = activeSpot.y;
    final bool isLive = _hoverSpot == null;

    final statusColor = _getStatusColor(currentValue);
    final statusText = _getStatusLabel(currentValue);
    final trendIcon = _getTrendIcon(currentValue, viewModel.glucoseSpots);

    final int hours = activeSpot.x.toInt();
    final int minutes = ((activeSpot.x - hours) * 60).toInt();
    final String timeStr = "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: ShapeDecoration(
        color: Colors.black.withOpacity(0.6),
        shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: statusColor, width: 2),
        ),
        shadows: [
          BoxShadow(
            color: statusColor.withOpacity(0.25),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currentValue.toInt().toString(),
                  style: GoogleFonts.vt323(
                    fontSize: 64,
                    height: 0.9,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),

                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(trendIcon, size: 38, color: statusColor),
                    Text(
                        "mg/dL",
                        style: GoogleFonts.iceland(
                            fontSize: 16,
                            color: Colors.white54,
                            fontWeight: FontWeight.bold
                        )
                    ),
                  ],
                ),
              ],
            ),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    isLive ? "LIVE FEED" : "TIME: $timeStr",
                    style: GoogleFonts.vt323(
                      fontSize: 28,
                      color: isLive ? Colors.redAccent : Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    statusText,
                    textAlign: TextAlign.end,
                    style: GoogleFonts.iceland(
                      fontSize: 16,
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StatisticsViewModel>();
    final colorScheme = Theme.of(context).colorScheme;
    final dateStr = DateFormat('EEE, d MMM yyyy').format(viewModel.selectedDate).toUpperCase();

    return Stack(
      children: [
        Container(color: Theme.of(context).scaffoldBackgroundColor),
        Positioned.fill(
          child: Opacity(
            opacity: 0.1,
            child: Image.asset(
              'assets/images/grid.png',
              repeat: ImageRepeat.repeat,
              scale: 1.0,
              errorBuilder: (c, e, s) => const SizedBox(),
            ),
          ),
        ),

        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: CyberGlitchText(
              'GLUCOSE MONITOR',
              style: GoogleFonts.vt323(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
                letterSpacing: 2.0,
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios, size: 18, color: colorScheme.primary),
                        onPressed: () => viewModel.previousDay(),
                      ),

                      InkWell(
                        onTap: () => _selectDate(context, viewModel),
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: colorScheme.primary, width: 2)),
                            color: colorScheme.primary.withOpacity(0.05),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_month, size: 18, color: colorScheme.secondary),
                              const SizedBox(width: 8),
                              Text(
                                dateStr,
                                style: GoogleFonts.vt323(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onBackground,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      IconButton(
                        icon: Icon(Icons.arrow_forward_ios, size: 18, color: colorScheme.primary),
                        onPressed: viewModel.canGoNext ? () => viewModel.nextDay() : null,
                      ),
                    ],
                  ),
                ),

                if (!viewModel.isLoading && viewModel.glucoseSpots.isNotEmpty)
                  _buildGlucoseHUD(context, viewModel),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration: ShapeDecoration(
                        color: colorScheme.surface.withOpacity(0.85),
                        shape: BeveledRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: AppColors.mainBlue, width: 1.5),
                        ),
                        shadows: [
                          BoxShadow(
                            color: AppColors.mainBlue.withOpacity(0.2),
                            blurRadius: 12,
                            spreadRadius: -2,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("SENSOR HISTORY", style: GoogleFonts.iceland(color: AppColors.mainBlue, fontSize: 16)),
                                Text(
                                  _hoverSpot != null ? "INTERACTIVE" : "MONITORING",
                                  style: GoogleFonts.vt323(
                                      color: _hoverSpot != null ? Colors.orangeAccent : Colors.greenAccent
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: viewModel.isLoading
                                  ? const Center(child: CircularProgressIndicator())
                                  : viewModel.errorMessage.isNotEmpty
                                  ? Center(child: Text("ERR: ${viewModel.errorMessage}", style: GoogleFonts.vt323(color: colorScheme.error)))
                                  : viewModel.glucoseSpots.isEmpty
                                  ? Center(child: Text("NO DATA FOUND", style: GoogleFonts.vt323(fontSize: 24, color: Colors.white54)))
                                  : Chart(
                                title: 'Glucose',
                                glucoseSpots: viewModel.glucoseSpots,
                                onSpotHover: (spot) {
                                  setState(() {
                                    _hoverSpot = spot;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.mainBlue,
            shape: const BeveledRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            onPressed: () => context.read<StatisticsViewModel>().fetchGlucoseData(),
            child: const Icon(Icons.refresh),
          ),
        ),
      ],
    );
  }
}