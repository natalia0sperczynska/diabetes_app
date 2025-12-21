import 'package:flutter/material.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailsScreen({
    required this.product,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final nutriments =
        (product['nutriments'] as Map<String, dynamic>?) ?? {};
    final name =
        product['product_name'] ?? product['generic_name'] ?? 'Unknown product';

    Widget row(String label, dynamic value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value?.toString() ?? '-',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            row('Calories (kcal / 100g)',
                nutriments['energy-kcal_100g'] ?? '-'),
            row('Proteins (g / 100g)', nutriments['proteins_100g']),
            row('Fat (g / 100g)', nutriments['fat_100g']),
            row('Carbohydrates (g / 100g)',
                nutriments['carbohydrates_100g']),
            row('Sugars (g / 100g)', nutriments['sugars_100g']),
            row('Fiber (g / 100g)', nutriments['fiber_100g']),
            row('Salt (g / 100g)', nutriments['salt_100g']),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}