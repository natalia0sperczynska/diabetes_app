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

              setState(() {
                caloriesConsumed += (kcal100 * factor).round();
                proteinConsumed += protein100 * factor;
                fatConsumed += fat100 * factor;
                carbConsumed += carbs100 * factor;

                meals.add(Meal(
                  name: '$name (${grams.round()} g)',
                  calories: (kcal100 * factor).round(),
                  protein: protein100 * factor,
                  fat: fat100 * factor,
                  carbs: carbs100 * factor,
                  fiber: fiber100 * factor,
                  sugars: sugars100 * factor,
                  salt: salt100 * factor,
                  grams: grams.round(),
                ));
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
            child: ListView.separated(
              itemCount: meals.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (_, i) {
                final meal = meals[meals.length - 1 - i];
                return ListTile(
                  leading: const Icon(Icons.restaurant),
                  title: Text(meal.name),
                  trailing: Text('${meal.calories} kcal'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}