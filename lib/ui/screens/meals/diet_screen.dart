import 'package:flutter/material.dart';

import 'models/meal.dart';
import 'services/open_food_facts_service.dart';
import 'utils/nutrition_parser.dart';
import 'widgets/barcode_scanner_dialog.dart';
import 'widgets/macro_column.dart';
import 'widgets/meal_details_dialog.dart';
import 'product_details_screen.dart';

class DietScreen extends StatefulWidget {
  const DietScreen({super.key});

  @override
  State<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  final int dailyCalorieGoal = 2500;
  final int proteinGoal = 150;
  final int fatGoal = 80;
  final int carbGoal = 250;

  int caloriesConsumed = 0;
  double proteinConsumed = 0;
  double fatConsumed = 0;
  double carbConsumed = 0;

  final List<Meal> meals = [];

  Future<void> _openBarcodeScanner() async {
    final barcode = await showDialog<String>(
      context: context,
      builder: (_) => const BarcodeScannerDialog(),
    );

    if (barcode != null) {
      _onBarcodeFound(barcode);
    }
  }

  Future<void> _onBarcodeFound(String code) async {
    final product = await OpenFoodFactsService.fetchProduct(code);

    if (product == null) {
      _showSnack('Product not found');
      return;
    }

    if (!mounted) return;
    _showAddWithGramsDialog(product);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _addMealToTotals(Meal meal) {
    caloriesConsumed += meal.calories;
    proteinConsumed += meal.protein;
    fatConsumed += meal.fat;
    carbConsumed += meal.carbs;
  }

  void _removeMealFromTotals(Meal meal) {
    caloriesConsumed -= meal.calories;
    proteinConsumed -= meal.protein;
    fatConsumed -= meal.fat;
    carbConsumed -= meal.carbs;
  }

  Future<void> _onMealTap(int index) async {
    final meal = meals[index];

    final result = await showDialog(
      context: context,
      builder: (_) => MealDetailsDialog(meal: meal),
    );

    if (result == null) return;

    setState(() {
      if (result == 'delete') {
        _removeMealFromTotals(meal);
        meals.removeAt(index);
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

        _removeMealFromTotals(meal);
        _addMealToTotals(newMeal);
        meals[index] = newMeal;

        _showSnack('Meal updated');
      }
    });
  }

  Future<void> _showAddWithGramsDialog(Map<String, dynamic> product) async {
    final grams = await showDialog<double>(
      context: context,
      builder: (_) => AddProductDialog(product: product),
    );

    if (grams == null || grams <= 0) return;

    final nutriments = (product['nutriments'] as Map<String, dynamic>?) ?? {};
    final name = product['product_name'] ??
        product['generic_name'] ??
        'Unknown product';

    final kcal100 = toDoubleSafe(nutriments['energy-kcal_100g']);
    final protein100 = toDoubleSafe(nutriments['proteins_100g']);
    final fat100 = toDoubleSafe(nutriments['fat_100g']);
    final carbs100 = toDoubleSafe(nutriments['carbohydrates_100g']);
    final fiber100 = toDoubleSafe(nutriments['fiber_100g']);
    final sugars100 = toDoubleSafe(nutriments['sugars_100g']);
    final salt100 = toDoubleSafe(nutriments['salt_100g']);

    final factor = grams / 100.0;

    final newMeal = Meal(
      name: name,
      calories: (kcal100 * factor).round(),
      protein: protein100 * factor,
      fat: fat100 * factor,
      carbs: carbs100 * factor,
      fiber: fiber100 * factor,
      sugars: sugars100 * factor,
      salt: salt100 * factor,
      grams: grams.round(),
    );

    setState(() {
      _addMealToTotals(newMeal);
      meals.add(newMeal);
    });
  }

  @override
  Widget build(BuildContext context) {
    final remaining = dailyCalorieGoal - caloriesConsumed;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diet Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _openBarcodeScanner,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text(
                      'Remaining: $remaining kcal',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        MacroColumn(
                            label: 'Protein',
                            consumed: proteinConsumed,
                            goal: proteinGoal),
                        MacroColumn(
                            label: 'Fat', consumed: fatConsumed, goal: fatGoal),
                        MacroColumn(
                            label: 'Carbs',
                            consumed: carbConsumed,
                            goal: carbGoal),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: meals.isEmpty
                ? const Center(child: Text('No meals added yet'))
                : ListView.separated(
              itemCount: meals.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (_, i) {
                final index = meals.length - 1 - i;
                final meal = meals[index];

                return ListTile(
                  leading: const Icon(Icons.restaurant),
                  title: Text(meal.name),
                  subtitle: Text('${meal.grams} g'),
                  trailing: Text('${meal.calories} kcal'),
                  onTap: () => _onMealTap(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AddProductDialog extends StatefulWidget {
  final Map<String, dynamic> product;

  const AddProductDialog({required this.product, super.key});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _gramsController = TextEditingController(text: '100');

  @override
  void dispose() {
    _gramsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.product['product_name'] ??
        widget.product['generic_name'] ??
        'Unknown product';

    return AlertDialog(
      title: Text('Add "$name"'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _gramsController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Grams',
                prefixIcon: Icon(Icons.scale),
                hintText: '100',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Enter grams';
                final n = double.tryParse(value.replaceAll(',', '.'));
                if (n == null) return 'Invalid number';
                if (n <= 0) return 'Must be positive';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ProductDetailsScreen(product: widget.product),
                  ),
                );
              },
              child: const Text('View full nutrition info'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final grams =
              double.parse(_gramsController.text.replaceAll(',', '.'));
              Navigator.pop(context, grams);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}