import 'dart:async';
import 'package:flutter/material.dart';

import 'models/meal.dart';
import 'services/open_food_facts_service.dart';
import 'utils/nutrition_parser.dart';
import 'widgets/barcode_scanner_dialog.dart';
import 'product_details_screen.dart';

class FoodSearchScreen extends StatefulWidget {
  final String mealType;

  const FoodSearchScreen({required this.mealType, super.key});

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isLoading = true);
    final results = await OpenFoodFactsService.searchProducts(query);
    if (!mounted) return;
    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  Future<void> _openBarcodeScanner() async {
    final barcode = await showDialog<String>(
      context: context,
      builder: (_) => const BarcodeScannerDialog(),
    );

    if (barcode != null) {
      _fetchAndShowAddDialog(barcode, isBarcode: true);
    }
  }

  Future<void> _fetchAndShowAddDialog(String id, {bool isBarcode = false}) async {
    Map<String, dynamic>? product;

    if (isBarcode) {
      product = await OpenFoodFactsService.fetchProduct(id);
    } else {
      product = await OpenFoodFactsService.fetchProduct(id);
    }

    if (product == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product details not found')),
        );
      }
      return;
    }

    if (!mounted) return;

    final grams = await showDialog<double>(
      context: context,
      builder: (_) => AddProductDialog(product: product!, mealType: widget.mealType),
    );

    if (grams == null || grams <= 0) return;

    final nutriments = (product['nutriments'] as Map<String, dynamic>?) ?? {};
    final name = product['product_name'] ?? product['generic_name'] ?? 'Unknown';

    final kcal100 = toDoubleSafe(nutriments['energy-kcal_100g']);
    final protein100 = toDoubleSafe(nutriments['proteins_100g']);
    final fat100 = toDoubleSafe(nutriments['fat_100g']);
    final carbs100 = toDoubleSafe(nutriments['carbohydrates_100g']);
    final fiber100 = toDoubleSafe(nutriments['fiber_100g']);
    final sugars100 = toDoubleSafe(nutriments['sugars_100g']);
    final salt100 = toDoubleSafe(nutriments['salt_100g']);

    double? gi;
    if (nutriments.containsKey('glycemic-index')) {
      gi = toDoubleSafe(nutriments['glycemic-index']);
    } else if (product.containsKey('glycemic_index')) {
      gi = toDoubleSafe(product['glycemic_index']);
    }

    final factor = grams / 100.0;

    final meal = Meal(
      name: name,
      calories: (kcal100 * factor).round(),
      protein: protein100 * factor,
      fat: fat100 * factor,
      carbs: carbs100 * factor,
      fiber: fiber100 * factor,
      sugars: sugars100 * factor,
      salt: salt100 * factor,
      grams: grams.round(),
      glycemicIndex: gi,
    );

    if (mounted) {
      Navigator.pop(context, meal);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        titleSpacing: 0,
        title: Container(
          height: 45,
          margin: const EdgeInsets.only(right: 8),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            autofocus: true,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              hintText: 'Search in ${widget.mealType}...',
              hintStyle: TextStyle(color: Colors.grey[500]),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
              suffixIcon: _isLoading
                  ? const Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.search, color: Colors.grey),
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.qr_code_scanner, color: Colors.black),
              onPressed: _openBarcodeScanner,
            ),
          )
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_searchController.text.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('Type to search or scan a barcode', style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty && !_isLoading) {
      return const Center(child: Text('No results found', style: TextStyle(color: Colors.black54)));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        final name = item['product_name'] ?? item['generic_name'] ?? 'Unknown';
        final brand = item['brands'] ?? '';
        final code = item['code'] ?? item['_id'] ?? '';

        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)
          ),
          subtitle: brand.isNotEmpty
              ? Text(brand, style: TextStyle(color: Colors.grey[600]))
              : null,
          trailing: const Icon(Icons.add_circle_outline, color: Color(0xFF1565C0)),
          onTap: () {
            if (code.isNotEmpty) {
              _fetchAndShowAddDialog(code);
            }
          },
        );
      },
    );
  }
}

class AddProductDialog extends StatefulWidget {
  final Map<String, dynamic> product;
  final String mealType;

  const AddProductDialog({
    required this.product,
    required this.mealType,
    super.key
  });

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

    // Extract quick carb info for preview
    final nutriments = (widget.product['nutriments'] as Map<String, dynamic>?) ?? {};
    final carbs100 = toDoubleSafe(nutriments['carbohydrates_100g']);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add to ${widget.mealType}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(name, style: const TextStyle(fontSize: 18, color: Colors.black)),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.5)),
                ),
                child: Text(
                  '${(carbs100/10).toStringAsFixed(1)} Units / 100g',
                  style: TextStyle(fontSize: 12, color: Colors.orange[800], fontWeight: FontWeight.bold),
                ),
              ),
            ],
          )
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _gramsController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: 'Grams',
                labelStyle: const TextStyle(color: Colors.grey),
                suffixText: 'g',
                prefixIcon: const Icon(Icons.scale, color: Colors.grey),
                hintText: '100',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                    builder: (_) => ProductDetailsScreen(product: widget.product),
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
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final grams = double.parse(_gramsController.text.replaceAll(',', '.'));
              Navigator.pop(context, grams);
            }
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: const Color(0xFF1565C0),
            foregroundColor: Colors.white,
          ),
          child: const Text('Add'),
        ),
      ],
    );
  }
}