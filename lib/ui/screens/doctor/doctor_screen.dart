import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../data/model/AnalysisModel.dart';
import '../../view_models/doctor_view_model.dart';
import '../../themes/colors/app_colors.dart';
import '../../widgets/vibe/glitch.dart';

class DoctorScreen extends StatelessWidget {
  const DoctorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DoctorViewModel>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: CyberGlitchText(
          'Doctor Panel',
          style: GoogleFonts.vt323(
            fontSize: 32,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        backgroundColor: AppColors.cyberBlack.withOpacity(0.8),
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      body: Stack(
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
          SafeArea(
            child: vm.selectedPatient == null
                ? _buildPatientList(context, vm)
                : _buildPatientDetail(context, vm),
          ),
        ],
      ),
    );
  }

  // ── Patient list ──
  Widget _buildPatientList(BuildContext context, DoctorViewModel vm) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SELECT PATIENT',
            style: GoogleFonts.vt323(
              fontSize: 28,
              color: AppColors.neonCyan,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a patient to view their glucose data',
            style: GoogleFonts.iceland(
              fontSize: 16,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: vm.isPatientsLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.neonCyan))
                : vm.patients.isEmpty
                    ? Center(
                        child: Text(
                          'NO PATIENTS ASSIGNED',
                          style: GoogleFonts.vt323(
                            fontSize: 22,
                            color: Colors.white38,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: vm.patients.length,
                        itemBuilder: (context, index) {
                          final patient = vm.patients[index];
                          return _buildPatientCard(context, vm, patient);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(
    BuildContext context,
    DoctorViewModel vm,
    PatientInfo patient,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: ShapeDecoration(
        color: Colors.black.withOpacity(0.5),
        shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: AppColors.neonCyan,
            width: 1.5,
          ),
        ),
        shadows: [
          BoxShadow(
            color: AppColors.neonCyan.withOpacity(0.15),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Icon(
          Icons.person,
          color: AppColors.neonCyan,
          size: 32,
        ),
        title: Text(
          patient.displayName,
          style: GoogleFonts.vt323(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          patient.email,
          style: GoogleFonts.iceland(
            fontSize: 14,
            color: Colors.white54,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.white38,
          size: 18,
        ),
        onTap: () => vm.selectPatient(patient),
      ),
    );
  }

  // ── Patient detail view ──
  Widget _buildPatientDetail(BuildContext context, DoctorViewModel vm) {
    if (vm.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.neonCyan),
      );
    }

    final stats = vm.analysisStats;
    final dateStr =
        DateFormat('EEE, d MMM yyyy').format(vm.selectedDate).toUpperCase();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildBackHeader(context, vm),
          const SizedBox(height: 16),

          // Summary cards
          _buildSummaryCards(context, stats),
          const SizedBox(height: 20),

          // Ranges
          _buildRangesCard(context, stats),
          const SizedBox(height: 20),

          // Day chart
          _buildDayChartSection(context, vm, dateStr),
        ],
      ),
    );
  }

  Widget _buildBackHeader(BuildContext context, DoctorViewModel vm) {
    final patient = vm.selectedPatient!;

    return Row(
      children: [
        GestureDetector(
          onTap: () {
            // Clear selection by re-creating the view model state
            // We'll use a simple approach: call a method
            _clearSelection(context);
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.neonCyan, width: 1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.arrow_back,
                color: AppColors.neonCyan, size: 20),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                patient.displayName.toUpperCase(),
                style: GoogleFonts.vt323(
                  fontSize: 26,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              Row(
                children: [
                  Text(
                    patient.email,
                    style: GoogleFonts.iceland(
                      fontSize: 14,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _clearSelection(BuildContext context) {
    final vm = context.read<DoctorViewModel>();
    vm.clearSelection();
  }

  Widget _buildSummaryCards(BuildContext context, AnalysisStats stats) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _metricCard('AVG GLUCOSE', '${stats.averageGlucose.toInt()} mg/dL',
            AppColors.neonCyan),
        _metricCard('GMI', '${stats.gmi}%', AppColors.neonPink),
        _metricCard('SD', '${stats.standardDeviation.toInt()} mg/dL',
            AppColors.neonGreen),
        _metricCard(
            'CV', '${stats.coefficientOfVariation}%', const Color(0xFFFFFF00)),
      ],
    );
  }

  Widget _metricCard(String label, String value, Color color) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: ShapeDecoration(
        color: Colors.black.withOpacity(0.5),
        shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color.withOpacity(0.6), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.iceland(
              fontSize: 13,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.vt323(
              fontSize: 26,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRangesCard(BuildContext context, AnalysisStats stats) {
    final ranges = stats.ranges;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.black.withOpacity(0.5),
        shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side:
              BorderSide(color: AppColors.neonCyan.withOpacity(0.4), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TIME IN RANGES (14 DAYS)',
            style: GoogleFonts.vt323(
              fontSize: 20,
              color: AppColors.neonCyan,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          _rangeRow('Very High (>250)', ranges['veryHigh'] ?? 0,
              const Color(0xFFFF9100)),
          _rangeRow(
              'High (181-250)', ranges['high'] ?? 0, const Color(0xFFFFFF00)),
          _rangeRow('In Target (70-180)', ranges['inTarget'] ?? 0,
              const Color(0xFF39FF14)),
          _rangeRow('Low (54-69)', ranges['low'] ?? 0, const Color(0xFFFF4444)),
          _rangeRow('Very Low (<54)', ranges['veryLow'] ?? 0,
              const Color(0xFFFF0000)),
        ],
      ),
    );
  }

  Widget _rangeRow(String label, double pct, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 10, height: 10, color: color),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: GoogleFonts.iceland(fontSize: 14, color: Colors.white70),
            ),
          ),
          Expanded(
            flex: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: pct / 100,
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 45,
            child: Text(
              '${pct.toStringAsFixed(1)}%',
              textAlign: TextAlign.right,
              style: GoogleFonts.vt323(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayChartSection(
      BuildContext context, DoctorViewModel vm, String dateStr) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.black.withOpacity(0.5),
        shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side:
              BorderSide(color: AppColors.neonCyan.withOpacity(0.4), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => vm.previousDay(),
                icon: const Icon(Icons.chevron_left, color: AppColors.neonCyan),
              ),
              Text(
                dateStr,
                style: GoogleFonts.vt323(
                  fontSize: 20,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              IconButton(
                onPressed: vm.canGoNext ? () => vm.nextDay() : null,
                icon: Icon(
                  Icons.chevron_right,
                  color: vm.canGoNext ? AppColors.neonCyan : Colors.white24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Chart
          SizedBox(
            height: 220,
            child: vm.glucoseSpots.isEmpty
                ? Center(
                    child: Text(
                      'NO DATA FOR THIS DAY',
                      style: GoogleFonts.vt323(
                          fontSize: 18, color: Colors.white38),
                    ),
                  )
                : _buildGlucoseChart(vm),
          ),
        ],
      ),
    );
  }

  Widget _buildGlucoseChart(DoctorViewModel vm) {
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 24,
        minY: 40,
        maxY: 350,
        gridData: FlGridData(
          show: true,
          horizontalInterval: 50,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.white.withOpacity(0.05),
            strokeWidth: 1,
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: Colors.white.withOpacity(0.03),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 4,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${value.toInt()}h',
                  style: GoogleFonts.vt323(fontSize: 14, color: Colors.white38),
                ),
              ),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 50,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                '${value.toInt()}',
                style: GoogleFonts.vt323(fontSize: 12, color: Colors.white38),
              ),
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.white12),
        ),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: 70,
              color: Colors.red.withOpacity(0.3),
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
            HorizontalLine(
              y: 180,
              color: Colors.yellow.withOpacity(0.3),
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
          ],
        ),
        lineBarsData: [
          LineChartBarData(
            spots: vm.glucoseSpots,
            isCurved: true,
            color: AppColors.neonCyan,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.neonCyan.withOpacity(0.07),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final h = spot.x.toInt();
                final m = ((spot.x - h) * 60).toInt();
                return LineTooltipItem(
                  '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}\n${spot.y.toInt()} mg/dL',
                  GoogleFonts.vt323(color: Colors.white, fontSize: 14),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}
