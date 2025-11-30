import 'package:flutter/material.dart';

class Meal {
  final String name;
  final int calories;
  final String macros;

  Meal(this.name, this.calories, this.macros);
}

class DietScreen extends StatefulWidget {
  const DietScreen({super.key});

  @override
  State<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  final int dailyCalorieGoal = 2500;
  int caloriesConsumed = 1850;
  final int proteinGoal = 150;
  int proteinConsumed = 110;
  final int fatGoal = 80;
  int fatConsumed = 65;
  final int carbGoal = 250;
  int carbConsumed = 180;

  final List<Meal> meals = [
    Meal('Breakfast: Oatmeal', 450, 'P: 15g, F: 10g, C: 65g'),
    Meal('Lunch: Chicken Salad', 650, 'P: 45g, F: 30g, C: 40g'),
    Meal('Dinner: Pasta with Meatballs', 750, 'P: 50g, F: 25g, C: 75g'),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final int remainingCalories = dailyCalorieGoal - caloriesConsumed;
    final double calorieProgress = caloriesConsumed / dailyCalorieGoal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Diet', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Go to settings...')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          _buildSummaryCard(colorScheme, remainingCalories, calorieProgress),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Meals',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onBackground,
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Meal'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Open Add Meal screen...')),
                  );
                },
              ),
            ],
          ),
          const Divider(),

          ...meals.map((meal) => _buildMealListItem(colorScheme, meal)).toList(),

          const SizedBox(height: 100),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Quick Add Food...')),
          );
        },
        backgroundColor: colorScheme.primary,
        child: const Icon(Icons.fastfood, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryCard(ColorScheme colorScheme, int remainingCalories, double calorieProgress) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Remaining',
                      style: TextStyle(fontSize: 16, color: colorScheme.onSurface.withOpacity(0.7)),
                    ),
                    Text(
                      '$remainingCalories kcal',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Goal: $dailyCalorieGoal kcal',
                  style: TextStyle(fontSize: 14, color: colorScheme.onSurface.withOpacity(0.7)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: calorieProgress,
              backgroundColor: colorScheme.primary.withOpacity(0.2),
              color: colorScheme.primary,
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMacroItem(colorScheme, 'Protein', proteinConsumed, proteinGoal),
                _buildMacroItem(colorScheme, 'Fat', fatConsumed, fatGoal),
                _buildMacroItem(colorScheme, 'Carbs', carbConsumed, carbGoal),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroItem(ColorScheme colorScheme, String label, int consumed, int goal) {
    double progress = consumed / goal;
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
        ),
        const SizedBox(height: 5),
        SizedBox(
          width: 60,
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: colorScheme.onSurface.withOpacity(0.1),
            color: colorScheme.secondary,
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '$consumed / ${goal}g',
          style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.7)),
        ),
      ],
    );
  }

  Widget _buildMealListItem(ColorScheme colorScheme, Meal meal) {
    return ListTile(
      leading: Icon(
        Icons.circle,
        size: 10,
        color: colorScheme.primary,
      ),
      title: Text(
        meal.name,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(meal.macros),
      trailing: Text(
        '${meal.calories} kcal',
        style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary),
      ),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Viewing details for ${meal.name}')),
        );
      },
    );
  }
}