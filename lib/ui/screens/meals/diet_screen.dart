import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'models/meal.dart';
import 'widgets/barcode_scanner_dialog.dart';
import 'widgets/macro_column.dart';
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
    final product = await _fetchProductFromOpenFoodFacts(code);
    if (product == null) {
      _showSnack('Product not found');
      return;
    }
    _showAddWithGramsDialog(product);
  }

  Future<Map<String, dynamic>?> _fetchProductFromOpenFoodFacts(String barcode) async {
    try {
      final url = Uri.parse(
        'https://world.openfoodfacts.org/api/v0/product/$barcode.json',
      );
      final res = await http.get(url);
      if (res.statusCode != 200) return null;

      final data = json.decode(res.body);
      if (data['status'] != 1) return null;

      return data['product'];
    } catch (_) {
      return null;
    }
  }

  double _toDoubleSafe(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    if (v is String) {
      return double.tryParse(v.replaceAll(',', '.')) ?? 0.0;
    }
    return 0.0;
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
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
      } else if (result is int) {
        final newGrams = result;

        final oldFactor = meal.grams > 0 ? (meal.grams / 100.0) : 1.0;

        final baseKcal = meal.calories / oldFactor;
        final baseProtein = meal.protein / oldFactor;
        final baseFat = meal.fat / oldFactor;
        final baseCarbs = meal.carbs / oldFactor;
        final baseFiber = meal.fiber / oldFactor;
        final baseSugars = meal.sugars / oldFactor;
        final baseSalt = meal.salt / oldFactor;

        final newFactor = newGrams / 100.0;

        final newMeal = Meal(
          name: meal.name,
          calories: (baseKcal * newFactor).round(),
          protein: baseProtein * newFactor,
          fat: baseFat * newFactor,
          carbs: baseCarbs * newFactor,
          fiber: baseFiber * newFactor,
          sugars: baseSugars * newFactor,
          salt: baseSalt * newFactor,
          grams: newGrams,
        );

        _removeMealFromTotals(meal);
        _addMealToTotals(newMeal);
        meals[index] = newMeal;

        _showSnack('Meal updated');
      }
    });
  }

  void _showAddWithGramsDialog(Map<String, dynamic> product) {
    final nutriments =
        (product['nutriments'] as Map<String, dynamic>?) ?? {};

    final name = product['product_name'] ??
        product['generic_name'] ??
        'Unknown product';

    final kcal100 = _toDoubleSafe(nutriments['energy-kcal_100g']);
    final protein100 = _toDoubleSafe(nutriments['proteins_100g']);
    final fat100 = _toDoubleSafe(nutriments['fat_100g']);
    final carbs100 = _toDoubleSafe(nutriments['carbohydrates_100g']);
    final fiber100 = _toDoubleSafe(nutriments['fiber_100g']);
    final sugars100 = _toDoubleSafe(nutriments['sugars_100g']);
    final salt100 = _toDoubleSafe(nutriments['salt_100g']);

    final gramsCtrl = TextEditingController(text: '100');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Add "$name"'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: gramsCtrl,
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Grams',
                prefixIcon: Icon(Icons.scale),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ProductDetailsScreen(product: product),
                  ),
                );
              },
              child: const Text('View full nutrition info'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final grams =
                  double.tryParse(gramsCtrl.text.replaceAll(',', '.')) ?? 0;
              if (grams <= 0) return;

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

              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
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
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge,
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
                            label: 'Fat',
                            consumed: fatConsumed,
                            goal: fatGoal),
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
                // invert index to show newest at top, but keep correct index for logic
                final index = meals.length - 1 - i;
                final meal = meals[index];

                return ListTile(
                  leading: const Icon(Icons.restaurant),
                  title: Text(meal.name),
                  subtitle: Text('${meal.grams} g'),
                  trailing: Text('${meal.calories} kcal'),
                  onTap: () => _onMealTap(index), // Enable click
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MealDetailsDialog extends StatefulWidget {
  final Meal meal;

  const MealDetailsDialog({required this.meal, super.key});

  @override
  State<MealDetailsDialog> createState() => _MealDetailsDialogState();
}

class _MealDetailsDialogState extends State<MealDetailsDialog> {
  late TextEditingController _gramsController;

  late double _baseKcal;
  late double _baseProtein;
  late double _baseFat;
  late double _baseCarbs;
  late double _baseFiber;
  late double _baseSugars;
  late double _baseSalt;

  @override
  void initState() {
    super.initState();
    _gramsController = TextEditingController(text: widget.meal.grams.toString());

    final factor = widget.meal.grams > 0 ? (widget.meal.grams / 100.0) : 1.0;

    _baseKcal = widget.meal.calories / factor;
    _baseProtein = widget.meal.protein / factor;
    _baseFat = widget.meal.fat / factor;
    _baseCarbs = widget.meal.carbs / factor;
    _baseFiber = widget.meal.fiber / factor;
    _baseSugars = widget.meal.sugars / factor;
    _baseSalt = widget.meal.salt / factor;
  }

  @override
  void dispose() {
    _gramsController.dispose();
    super.dispose();
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentGrams = int.tryParse(_gramsController.text) ?? 0;
    final factor = currentGrams / 100.0;

    return AlertDialog(
      title: Text(widget.meal.name),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _gramsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Grams',
                suffixText: 'g',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),
            const Text('Nutritional Values:', style: TextStyle(fontWeight: FontWeight.bold)),
            const Divider(),
            _buildRow('Calories', '${(_baseKcal * factor).round()} kcal'),
            _buildRow('Protein', '${(_baseProtein * factor).toStringAsFixed(1)} g'),
            _buildRow('Fat', '${(_baseFat * factor).toStringAsFixed(1)} g'),
            _buildRow('Carbs', '${(_baseCarbs * factor).toStringAsFixed(1)} g'),
            _buildRow('Fiber', '${(_baseFiber * factor).toStringAsFixed(1)} g'),
            _buildRow('Sugars', '${(_baseSugars * factor).toStringAsFixed(1)} g'),
            _buildRow('Salt', '${(_baseSalt * factor).toStringAsFixed(1)} g'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, 'delete'),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Delete'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final newGrams = int.tryParse(_gramsController.text);
            if (newGrams != null && newGrams > 0) {
              Navigator.pop(context, newGrams);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}