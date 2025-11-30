import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/app_assets/app_assets.dart';
import '../../themes/colors/app_colors.dart';
import '../../themes/buttons/meal_tracker_buttons.dart';
import '../../view_models/meal_view_model.dart';
import '../../widgets/pixel_input_field.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MealViewModel>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            "MEAL TRACKER",
            style: GoogleFonts.iceland(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 24),

          isWideScreen
              ? _buildWideLayout(viewModel, context)
              : _buildNarrowLayout(viewModel, context),

          const SizedBox(height: 32),

          _buildDigestibleCarbsDisplay(viewModel, context),


          const SizedBox(height: 24),

          _buildActionButtons(context, viewModel),
        ],
      ),
    );
  }

  Widget _buildWideLayout(MealViewModel viewModel, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 1, child: _buildLogoSection(context)),
        const SizedBox(width: 32),
        Expanded(flex: 1, child: _buildInputSection(viewModel)),
      ],
    );
  }

  Widget _buildNarrowLayout(MealViewModel viewModel, BuildContext context) {
    return Column(
      children: [
        _buildLogoSection(context),
        const SizedBox(height: 24),
        _buildInputSection(viewModel),
      ],
    );
  }

  Widget _buildLogoSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: GestureDetector(
        onTap: () {
          // Logo is already on the meal screen, show a visual feedback
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "You're already on the Meal Tracker!",
                style: GoogleFonts.iceland(fontSize: 18, letterSpacing: 1.2),
              ),
              backgroundColor: colorScheme.primary,
              behavior: SnackBarBehavior.floating,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border.all(color: colorScheme.primary, width: 3),
            borderRadius: BorderRadius.zero,
          ),
          child: Image.asset(
            AppAssets.logo,
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildInputSection(MealViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PixelInputField(
          label: "CARBOHYDRATES",
          hint: "0.0",
          controller: viewModel.carbsPer100gController,
          onChanged: viewModel.updateCarbsPer100g,
          suffix: "g/100g",
        ),
        const SizedBox(height: 20),
        PixelInputField(
          label: "FIBER",
          hint: "0.0",
          controller: viewModel.fiberPer100gController,
          onChanged: viewModel.updateFiberPer100g,
          suffix: "g/100g",
        ),
        const SizedBox(height: 20),
        PixelInputField(
          label: "AMOUNT EATEN",
          hint: "0.0",
          controller: viewModel.gramsEatenController,
          onChanged: viewModel.updateGramsEaten,
          suffix: "grams",
        ),
      ],
    );
  }

  Widget _buildDigestibleCarbsDisplay(MealViewModel viewModel, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.primary, width: 3),
        borderRadius: BorderRadius.zero,
      ),
      child: Column(
        children: [
          Text(
            "DIGESTIBLE CARBOHYDRATES",
            style: GoogleFonts.iceland(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "${viewModel.digestibleCarbohydrates.toStringAsFixed(1)} g",
            style: GoogleFonts.iceland(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Net Carbs = (${viewModel.carbsPer100g.toStringAsFixed(1)} - ${viewModel.fiberPer100g.toStringAsFixed(1)}) × ${viewModel.gramsEaten.toStringAsFixed(0)}g / 100",
            style: GoogleFonts.iceland(
              fontSize: 14,
              color: colorScheme.onSurface.withOpacity(0.7),
              letterSpacing: 1.0,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, MealViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: viewModel.resetFields,
            style: resetButtonStyle(context),
            child: Text(
              "RESET",
              style: GoogleFonts.iceland(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              viewModel.saveMeal();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Meal saved!",
                    style: GoogleFonts.iceland(
                      fontSize: 18,
                      letterSpacing: 1.2,
                    ),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
              );
            },
            style: saveButtonStyle(context),
            child: Text(
              "SAVE MEAL",
              style: GoogleFonts.iceland(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
