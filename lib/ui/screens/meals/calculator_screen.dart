import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../view_models/meal_view_model.dart';
import '../../view_models/statistics_view_model.dart';
import '../../screens/meals/services/meal_repository.dart';
import '../../screens/meals/models/meal.dart';

import '../../themes/colors/app_colors.dart';
import '../../widgets/cyber_container.dart';
import '../../widgets/pixel_input_field.dart';
import '../../widgets/vibe/glitch.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final TextEditingController _currentBgController = TextEditingController();
  final TextEditingController _targetBgController = TextEditingController(text: "100");
  final TextEditingController _icrController = TextEditingController(text: "10");
  final TextEditingController _isfController = TextEditingController(text: "50");
  final TextEditingController _iobController = TextEditingController(text: "0");

  final TextEditingController _tddController = TextEditingController();

  double _calculatedBolus = 0.0;
  double _correctionDose = 0.0;
  double _mealDose = 0.0;
  double _dailyCarbs = 0.0;
  bool _bgPrefilled = false;

  @override
  void initState() {
    super.initState();
    _loadDailyCarbs();

    _currentBgController.addListener(_calculateInsulin);
    _targetBgController.addListener(_calculateInsulin);
    _icrController.addListener(_calculateInsulin);
    _isfController.addListener(_calculateInsulin);
    _iobController.addListener(_calculateInsulin);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tryPrefillCurrentBg();
    _loadDailyCarbs();
  }

  void _loadDailyCarbs() {
    final repository = MealRepository();
    final now = DateTime.now();
    final List<Meal> todayMeals = repository.getMealsForDate(now);

    double total = 0;
    for (var meal in todayMeals) {
      total += meal.carbs;
    }

    if (total != _dailyCarbs) {
      setState(() {
        _dailyCarbs = total;
      });
      _calculateInsulin();
    }
  }

  void _tryPrefillCurrentBg() {
    if (_bgPrefilled) return;

    final statsVm = context.read<StatisticsViewModel>();
    if (statsVm.glucoseSpots.isNotEmpty) {
      final lastGlucose = statsVm.glucoseSpots.last.y;
      _currentBgController.text = lastGlucose.toInt().toString();
      _bgPrefilled = true;
      _calculateInsulin();
    }
  }

  @override
  void dispose() {
    _currentBgController.dispose();
    _targetBgController.dispose();
    _icrController.dispose();
    _isfController.dispose();
    _iobController.dispose();
    _tddController.dispose();
    super.dispose();
  }

  void _calculateInsulin() {
    final double netCarbs = _dailyCarbs;

    final double currentBg = double.tryParse(_currentBgController.text) ?? 0;
    final double targetBg = double.tryParse(_targetBgController.text) ?? 100;
    final double icr = double.tryParse(_icrController.text) ?? 10;
    final double isf = double.tryParse(_isfController.text) ?? 50;
    final double iob = double.tryParse(_iobController.text) ?? 0;

    double mealDose = 0;
    if (icr > 0) {
      mealDose = netCarbs / icr;
    }

    double correctionDose = 0;
    if (isf > 0 && currentBg > targetBg) {
      correctionDose = (currentBg - targetBg) / isf;
    }

    double total = mealDose + correctionDose - iob;
    if (total < 0) total = 0;

    setState(() {
      _mealDose = mealDose;
      _correctionDose = correctionDose;
      _calculatedBolus = total;
    });
  }

  void _estimateFactorsFromTDD() {
    final tdd = double.tryParse(_tddController.text);
    if (tdd != null && tdd > 0) {
      _icrController.text = (500 / tdd).toStringAsFixed(1);
      _isfController.text = (1800 / tdd).toStringAsFixed(0);
      _calculateInsulin();
      Navigator.pop(context);
    }
  }

  void _showTDDDialog() {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkBlue2,
        shape: BeveledRectangleBorder(
            side: BorderSide(color: colorScheme.primary),
            borderRadius: BorderRadius.circular(10)),
        title: Text("ESTIMATE FACTORS", style: GoogleFonts.vt323(color: colorScheme.primary, fontSize: 24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Enter Total Daily Dose (TDD) to estimate ICR (Rule of 500) and ISF (Rule of 1800).",
              style: GoogleFonts.iceland(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            PixelInputField(
              label: "TOTAL DAILY DOSE",
              controller: _tddController,
              hint: "e.g. 40",
              onChanged: (val) {},
              suffix: "u",
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("CANCEL", style: GoogleFonts.iceland(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary.withOpacity(0.2),
              side: BorderSide(color: colorScheme.primary),
              shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            onPressed: _estimateFactorsFromTDD,
            child: Text("CALCULATE", style: GoogleFonts.iceland(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Positioned.fill(
          child: Container(color: Theme.of(context).scaffoldBackgroundColor),
        ),
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
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                Center(
                  child: CyberGlitchText(
                    "BOLUS WIZARD",
                    style: GoogleFonts.vt323(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                      letterSpacing: 3.0,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                _buildResultHUD(colorScheme),

                const SizedBox(height: 24),

                _buildSectionHeader("TODAY'S DIET LOG", colorScheme),
                CyberContainer(
                  child: _buildMealReadOnly(colorScheme),
                ),

                const SizedBox(height: 16),

                _buildSectionHeader("GLUCOSE & IOB", colorScheme),
                CyberContainer(
                  child: _buildBioSection(colorScheme),
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionHeader("FACTORS (ICR / ISF)", colorScheme),
                    IconButton(
                      icon: Icon(Icons.calculate, color: colorScheme.tertiary),
                      onPressed: _showTDDDialog,
                      tooltip: "Calculate from TDD",
                    )
                  ],
                ),
                CyberContainer(
                  child: _buildFactorsSection(colorScheme),
                ),

                const SizedBox(height: 32),

                _buildActionButtons(context, colorScheme),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultHUD(ColorScheme colorScheme) {
    return CyberContainer(
      borderColor: colorScheme.primary,
      child: Column(
        children: [
          Text(
            "SUGGESTED DOSE",
            style: GoogleFonts.iceland(
              fontSize: 16,
              color: colorScheme.primary.withOpacity(0.8),
              letterSpacing: 2.0,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _calculatedBolus.toStringAsFixed(1),
                style: GoogleFonts.vt323(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 0.9
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "UNITS",
                style: GoogleFonts.iceland(
                  fontSize: 20,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat("MEAL", "${_mealDose.toStringAsFixed(1)}u"),
              _buildMiniStat("CORR", "${_correctionDose.toStringAsFixed(1)}u"),
              _buildMiniStat("IOB", "-${_iobController.text}u", color: colorScheme.tertiary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, {Color color = Colors.white}) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.iceland(color: Colors.white54, fontSize: 12)),
        Text(value, style: GoogleFonts.vt323(color: color, fontSize: 22)),
      ],
    );
  }

  Widget _buildSectionHeader(String title, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title,
        style: GoogleFonts.iceland(
          color: colorScheme.primary,
          fontSize: 18,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMealReadOnly(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("TOTAL DAILY CARBS", style: GoogleFonts.iceland(color: Colors.white60, fontSize: 14)),
            Text("SUM FROM LOGGED MEALS", style: GoogleFonts.iceland(color: Colors.white24, fontSize: 10)),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              _dailyCarbs.toStringAsFixed(1),
              style: GoogleFonts.vt323(color: AppColors.green, fontSize: 36),
            ),
            const SizedBox(width: 4),
            Text("g", style: GoogleFonts.vt323(color: AppColors.green, fontSize: 24)),
          ],
        )
      ],
    );
  }

  Widget _buildBioSection(ColorScheme colorScheme) {
    final bgVal = double.tryParse(_currentBgController.text) ?? 0;
    final bool isHigh = bgVal > 180;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "CURRENT BG",
                style: GoogleFonts.iceland(fontSize: 18, fontWeight: FontWeight.bold, color: isHigh ? colorScheme.error : colorScheme.primary, letterSpacing: 1.2)
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border.all(color: isHigh ? colorScheme.error : colorScheme.primary, width: 2),
                ),
                child: TextField(
                  controller: _currentBgController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: GoogleFonts.iceland(fontSize: 20, color: colorScheme.onSurface),
                  decoration: const InputDecoration(
                     hintText: "0",
                     suffixText: "mg/dL",
                     contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                     border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PixelInputField(
            label: "TARGET BG",
            controller: _targetBgController,
            hint: "100",
            suffix: "mg/dL",
            onChanged: (val) {},
          ),
        ),
      ],
    );
  }

  Widget _buildFactorsSection(ColorScheme colorScheme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: PixelInputField(
                label: "ICR (Ratio)",
                controller: _icrController,
                hint: "1:10",
                suffix: "g/u",
                onChanged: (val) {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PixelInputField(
                label: "ISF (Sens.)",
                controller: _isfController,
                hint: "1:50",
                suffix: "mg/u",
                onChanged: (val) {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        PixelInputField(
          label: "INSULIN ON BOARD (IOB)",
          controller: _iobController,
          hint: "0",
          suffix: "units",
          onChanged: (val) {},
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 56,
            child: OutlinedButton(
              onPressed: () {
                _currentBgController.clear();
                _iobController.text = "0";
                _loadDailyCarbs();
                _calculateInsulin();
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colorScheme.error),
                shape: const BeveledRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              child: Text(
                "REFRESH",
                style: GoogleFonts.iceland(
                  fontSize: 20,
                  color: colorScheme.error,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "BOLUS LOGGED: ${_calculatedBolus.toStringAsFixed(1)}U",
                      style: GoogleFonts.vt323(fontSize: 20, color: Colors.white),
                    ),
                    backgroundColor: colorScheme.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: const BeveledRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary.withOpacity(0.8),
                shape: const BeveledRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              child: Text(
                "LOG BOLUS",
                style: GoogleFonts.iceland(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}