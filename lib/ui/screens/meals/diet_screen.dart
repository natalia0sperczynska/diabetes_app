import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:diabetes_app/ui/widgets/vibe/glitch.dart';
import '../../themes/colors/app_colors.dart';

import 'models/meal.dart';
import 'services/meal_repository.dart';

import 'widgets/meal_details_dialog.dart';
import 'food_search_screen.dart';

class DietScreen extends StatefulWidget {
  const DietScreen({super.key});

  @override
  State<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  DateTime _selectedDate = DateTime.now();
  final MealRepository _repository = MealRepository();
  List<Meal> _dailyMeals = [];

  final int dailyCalorieGoal = 2500;
  final int proteinGoal = 150;
  final int fatGoal = 80;
  final int carbGoal = 250;

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  void _loadMeals() {
    setState(() {
      _dailyMeals = _repository.getMealsForDate(_selectedDate);
    });
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
      _loadMeals();
    });
  }

  double get _totalCalories => _dailyMeals.fold(0, (sum, m) => sum + m.calories);
  double get _totalProtein => _dailyMeals.fold(0.0, (sum, m) => sum + m.protein);
  double get _totalFat => _dailyMeals.fold(0.0, (sum, m) => sum + m.fat);
  double get _totalCarbs => _dailyMeals.fold(0.0, (sum, m) => sum + m.carbs);
  double get _totalCarbUnits => _dailyMeals.fold(0.0, (sum, m) => sum + m.carbUnits);
  double get _dailyGlycemicLoad => _dailyMeals.fold(0.0, (sum, m) => sum + m.glycemicLoad);

  List<Meal> _getMealsByType(String type) {
    return _dailyMeals.where((m) => m.mealType == type).toList();
  }

  Future<void> _addMeal(String mealType) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FoodSearchScreen(mealType: mealType),
      ),
    );

    if (result != null && result is Meal) {
      final finalMeal = result.copyWith(mealType: mealType);
      await _repository.addMeal(_selectedDate, finalMeal);
      _loadMeals();
    }
  }

  Future<void> _showMealDetails(Meal meal) async {
    final result = await showDialog(
      context: context,
      builder: (_) => MealDetailsDialog(meal: meal),
    );

    if (result == 'delete') {
      await _repository.deleteMeal(_selectedDate, meal);
      _loadMeals();
    } else if (result is int && result != meal.grams) {
      double ratio = result / meal.grams;
      Meal updatedMeal = meal.copyWith(
        grams: result,
        calories: (meal.calories * ratio).round(),
        protein: meal.protein * ratio,
        fat: meal.fat * ratio,
        carbs: meal.carbs * ratio,
        fiber: meal.fiber * ratio,
        sugars: meal.sugars * ratio,
        salt: meal.salt * ratio,
      );
      await _repository.updateMeal(_selectedDate, meal, updatedMeal);
      _loadMeals();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
              errorBuilder: (c, e, s) => Container(),
            ),
          ),
        ),

        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: const BackButton(),
            title: CyberGlitchText(
              'NUTRITION LOG',
              style: GoogleFonts.vt323(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
                letterSpacing: 2.0,
              ),
            ),
          ),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildDateSelector(context)),

              SliverToBoxAdapter(child: _buildSummaryCard(context)),

              _buildSectionList('Breakfast', context),
              _buildSectionList('Lunch', context),
              _buildSectionList('Dinner', context),
              _buildSectionList('Snack', context),

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCyberContainer({
    required BuildContext context,
    required Widget child,
    required Color borderColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: ShapeDecoration(
        color: colorScheme.surface.withOpacity(0.85),
        shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderColor, width: 1.5),
        ),
        shadows: [
          BoxShadow(
            color: borderColor.withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: -2,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios, size: 18, color: colorScheme.primary),
            onPressed: () => _changeDate(-1),
          ),
          CyberGlitchText(
            DateFormat('EEEE, d MMM').format(_selectedDate).toUpperCase(),
            style: GoogleFonts.vt323(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onBackground,
            ),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios, size: 18, color: colorScheme.primary),
            onPressed: () => _changeDate(1),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final calorieColor = _totalCalories > dailyCalorieGoal ? colorScheme.error : AppColors.mainBlue;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: _buildCyberContainer(
        context: context,
        borderColor: AppColors.mainBlue,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CyberGlitchText(
                        'ENERGY INTAKE',
                        style: GoogleFonts.iceland(fontSize: 14, color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          CyberGlitchText(
                            '${_totalCalories.toInt()}',
                            style: GoogleFonts.vt323(fontSize: 42, fontWeight: FontWeight.bold, color: calorieColor),
                          ),
                          const SizedBox(width: 8),
                          CyberGlitchText(
                            '/ $dailyCalorieGoal kcal',
                            style: GoogleFonts.vt323(fontSize: 20, color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 60,
                    width: 60,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: (_totalCalories / dailyCalorieGoal).clamp(0.0, 1.0),
                          backgroundColor: colorScheme.surfaceVariant.withOpacity(0.3),
                          color: calorieColor,
                          strokeWidth: 6,
                        ),
                        CyberGlitchText(
                          '${((_totalCalories / dailyCalorieGoal) * 100).toInt()}%',
                          style: GoogleFonts.vt323(fontSize: 16, color: colorScheme.onSurface),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: _buildMacroItem(context, 'PROTEIN', _totalProtein, proteinGoal, AppColors.green)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildMacroItem(context, 'CARBS', _totalCarbs, carbGoal, AppColors.mainBlue)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildMacroItem(context, 'FAT', _totalFat, fatGoal, Colors.redAccent)),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Divider(color: Colors.white24, height: 1),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDiabetesStat(context, 'CARB UNITS', '${_totalCarbUnits.toStringAsFixed(1)} BE', Colors.orange),
                  Container(width: 1, height: 30, color: Colors.white24),
                  _buildDiabetesStat(context, 'GLYCEMIC LOAD', _dailyGlycemicLoad.toStringAsFixed(1), AppColors.pixelBorder),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiabetesStat(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        CyberGlitchText(label, style: GoogleFonts.iceland(fontSize: 12, color: color.withOpacity(0.8))),
        const SizedBox(height: 2),
        CyberGlitchText(value, style: GoogleFonts.vt323(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildMacroItem(BuildContext context, String label, double value, int goal, Color color) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CyberGlitchText(label, style: GoogleFonts.iceland(fontSize: 12, color: colorScheme.onSurfaceVariant)),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${value.toInt()}g', style: GoogleFonts.vt323(fontWeight: FontWeight.bold, fontSize: 18, color: colorScheme.onSurface)),
            Text('/$goal', style: GoogleFonts.vt323(fontSize: 14, color: colorScheme.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.zero,
          child: LinearProgressIndicator(
            value: (value / goal).clamp(0.0, 1.0),
            backgroundColor: colorScheme.surfaceVariant.withOpacity(0.2),
            color: color,
            minHeight: 6,
          ),
        )
      ],
    );
  }

  Widget _buildSectionList(String title, BuildContext context) {
    final meals = _getMealsByType(title);
    final colorScheme = Theme.of(context).colorScheme;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(width: 4, height: 20, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      CyberGlitchText(
                          title.toUpperCase(),
                          style: GoogleFonts.vt323(fontSize: 24, fontWeight: FontWeight.bold, color: colorScheme.onBackground)
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => _addMeal(title),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: colorScheme.primary.withOpacity(0.5)),
                        color: colorScheme.primary.withOpacity(0.1),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.add, size: 16, color: colorScheme.primary),
                          const SizedBox(width: 4),
                          Text('ADD ITEM', style: GoogleFonts.iceland(fontSize: 14, fontWeight: FontWeight.bold, color: colorScheme.primary)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final meal = meals[index - 1];
          return _buildMealTile(meal, context);
        },
        childCount: meals.length + 1,
      ),
    );
  }

  Widget _buildMealTile(Meal meal, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: colorScheme.error.withOpacity(0.2),
        child: Icon(Icons.delete_outline, color: colorScheme.error),
      ),
      confirmDismiss: (direction) async {
        await _repository.deleteMeal(_selectedDate, meal);
        _loadMeals();
        return true;
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: InkWell(
          onTap: () => _showMealDetails(meal),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface.withOpacity(0.4),
              border: Border(left: BorderSide(color: AppColors.mainBlue.withOpacity(0.5), width: 3)),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    border: Border.all(color: Colors.white10),
                  ),
                  child: meal.imageUrl != null && meal.imageUrl!.isNotEmpty
                      ? Image.network(meal.imageUrl!, fit: BoxFit.cover, errorBuilder: (c, e, s) => Icon(Icons.fastfood, color: Colors.white30))
                      : Icon(Icons.restaurant, color: AppColors.mainBlue.withOpacity(0.8)),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          meal.name.toUpperCase(),
                          style: GoogleFonts.vt323(fontWeight: FontWeight.bold, fontSize: 20, color: colorScheme.onSurface),
                          maxLines: 1, overflow: TextOverflow.ellipsis
                      ),
                      Text(
                          '${meal.grams}g  //  P:${meal.protein.round()}  C:${meal.carbs.round()}  F:${meal.fat.round()}',
                          style: GoogleFonts.iceland(fontSize: 14, color: colorScheme.onSurfaceVariant)
                      ),
                    ],
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${meal.calories}', style: GoogleFonts.vt323(fontWeight: FontWeight.bold, fontSize: 24, color: AppColors.mainBlue)),
                    Text('KCAL', style: GoogleFonts.iceland(fontSize: 10, color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}