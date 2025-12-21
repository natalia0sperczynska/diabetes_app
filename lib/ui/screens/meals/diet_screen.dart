import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'models/meal.dart';
import 'widgets/meal_details_dialog.dart';
import 'food_search_screen.dart';

class DietScreen extends StatefulWidget {
  const DietScreen({super.key});

  @override
  State<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  DateTime _selectedDate = DateTime.now();

  bool get _isToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  void _changeDate(int days) {
    setState(() {
      final newDate = _selectedDate.add(Duration(days: days));
      if (newDate.isAfter(DateTime.now())) return;
      _selectedDate = newDate;
    });
  }

  String _getFormattedDate() {
    if (_isToday) return 'Today';
    return DateFormat('EEE, d MMM').format(_selectedDate);
  }

  final int dailyCalorieGoal = 2500;
  final int proteinGoal = 150;
  final int fatGoal = 80;
  final int carbGoal = 250;

  final Color carbsColor = Colors.purpleAccent;
  final Color proteinColor = Colors.blueAccent;
  final Color fatColor = Colors.amber;
  final Color primaryBlue = const Color(0xFF1565C0);

  final Map<String, List<Meal>> dailyMeals = {
    'Breakfast': [],
    'Lunch': [],
    'Dinner': [],
    'Snacks': [],
  };

  int get caloriesConsumed => dailyMeals.values
      .expand((l) => l)
      .fold(0, (sum, meal) => sum + meal.calories);

  double get proteinConsumed => dailyMeals.values
      .expand((l) => l)
      .fold(0.0, (sum, meal) => sum + meal.protein);

  double get fatConsumed => dailyMeals.values
      .expand((l) => l)
      .fold(0.0, (sum, meal) => sum + meal.fat);

  double get carbConsumed => dailyMeals.values
      .expand((l) => l)
      .fold(0.0, (sum, meal) => sum + meal.carbs);


  Future<void> _onAddMealTap(String sectionKey) async {
    final Meal? newMeal = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FoodSearchScreen(mealType: sectionKey),
      ),
    );

    if (newMeal != null) {
      setState(() {
        dailyMeals[sectionKey]?.add(newMeal);
      });
      _showSnack('${newMeal.name} added to $sectionKey');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _onMealTap(String sectionKey, int index) async {
    final meal = dailyMeals[sectionKey]![index];

    final result = await showDialog(
      context: context,
      builder: (_) => MealDetailsDialog(meal: meal),
    );

    if (result == null) return;

    setState(() {
      if (result == 'delete') {
        dailyMeals[sectionKey]!.removeAt(index);
        _showSnack('Meal removed');
      } else if (result is num) {
        final newGrams = result.toInt();

        final oldFactor = meal.grams > 0 ? (meal.grams / 100.0) : 1.0;
        final newFactor = newGrams / 100.0;
        double scale(double val) => (val / oldFactor) * newFactor;

        final newMeal = Meal(
          name: meal.name,
          calories: scale(meal.calories.toDouble()).round(),
          protein: scale(meal.protein),
          fat: scale(meal.fat),
          carbs: scale(meal.carbs),
          fiber: scale(meal.fiber),
          sugars: scale(meal.sugars),
          salt: scale(meal.salt),
          grams: newGrams,
        );

        dailyMeals[sectionKey]![index] = newMeal;
        _showSnack('Meal updated');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final remaining = dailyCalorieGoal - caloriesConsumed;
    final backgroundColor = const Color(0xFFE3F2FD);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios, size: 18, color: primaryBlue),
              onPressed: () => _changeDate(-1),
            ),
            const SizedBox(width: 8),
            Text(
              _getFormattedDate(),
              style: TextStyle(
                color: primaryBlue,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.arrow_forward_ios, size: 18, color: _isToday ? Colors.grey.withOpacity(0.3) : primaryBlue),
              onPressed: _isToday ? null : () => _changeDate(1),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSummaryCard(remaining),
            const SizedBox(height: 16),
            ...dailyMeals.keys.map((key) => _buildMealSection(key)),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(int remaining) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCalorieColumn('Goal', dailyCalorieGoal, primaryBlue),
              _buildCalorieCircle(remaining, primaryBlue),
              _buildCalorieColumn('Burned', 0, Colors.orange),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMacroBar(
                    'Carbs', carbConsumed, carbGoal, carbsColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMacroBar(
                    'Protein', proteinConsumed, proteinGoal, proteinColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMacroBar(
                    'Fat', fatConsumed, fatGoal, fatColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieCircle(int remaining, Color color) {
    double progress = 0.0;
    if (dailyCalorieGoal > 0) {
      progress = (caloriesConsumed / dailyCalorieGoal).clamp(0.0, 1.0);
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 130,
          height: 130,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 10,
            color: color,
            backgroundColor: const Color(0xFFEEEEEE),
            strokeCap: StrokeCap.round,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$caloriesConsumed',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const Text(
              'kcal',
              style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                  fontSize: 14
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$remaining left',
              style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                  fontSize: 12
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCalorieColumn(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.bold,
              fontSize: 13
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMacroBar(
      String label, double value, int goal, Color color) {
    final progress = (value / goal).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87
                )),
            Text('${value.toInt()}/${goal}g',
                style: const TextStyle(fontSize: 11, color: Colors.black54)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: color.withOpacity(0.15),
          color: color,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildMealSection(String sectionKey) {
    final meals = dailyMeals[sectionKey]!;
    final int sectionCalories = meals.fold(0, (sum, m) => sum + m.calories);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    sectionKey,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$sectionCalories kcal',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        fontSize: 14
                    ),
                  ),
                ],
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _onAddMealTap(sectionKey),
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Icon(Icons.add_circle, color: primaryBlue, size: 28),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (meals.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'Add food',
              style: TextStyle(color: primaryBlue.withOpacity(0.4), fontSize: 13, fontStyle: FontStyle.italic),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: meals.length,
            itemBuilder: (context, index) {
              final meal = meals[index];
              return _buildMealTile(sectionKey, meal, index);
            },
          ),
        const Divider(height: 24, indent: 20, endIndent: 20),
      ],
    );
  }

  Widget _buildMealTile(String sectionKey, Meal meal, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        onTap: () => _onMealTap(sectionKey, index),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryBlue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.restaurant, color: primaryBlue, size: 18),
        ),
        title: Text(
          meal.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: carbsColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${meal.grams} g • P:${meal.protein.toInt()} F:${meal.fat.toInt()} C:${meal.carbs.toInt()}',
          style: const TextStyle(color: Colors.black54, fontSize: 12),
        ),
        trailing: Text(
          '${meal.calories}',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: primaryBlue,
          ),
        ),
      ),
    );
  }
}