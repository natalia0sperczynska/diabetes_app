import 'dart:async';
import 'package:flutter/material.dart';

import 'models/meal.dart';
import 'services/open_food_facts_service.dart';
import 'services/local_food_service.dart';
import 'utils/nutrition_parser.dart';
import 'utils/glycemic_index_store.dart';
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

    final localResults = await LocalFoodService.search(query);

    final apiResults = await OpenFoodFactsService.searchProducts(query);

    if (!mounted) return;

    setState(() {
      _searchResults = [...localResults, ...apiResults];
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

    if (id.startsWith('local_')) {
      product = LocalFoodService.getProductByCode(id);
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

    double? gi;
    if (id.startsWith('local_')) {
      final nutriments = (product['nutriments'] as Map<String, dynamic>?) ?? {};
      if (nutriments.containsKey('glycemic-index')) {
        gi = toDoubleSafe(nutriments['glycemic-index']);
      }
    }

    if (gi == null) {
      final name = product['product_name'] ?? product['generic_name'];
      final categories = product['categories_tags'] as List<dynamic>?;
      gi = GlycemicIndexStore.estimateGI(name, categories);
    }

    String? imageUrl;
    if (product.containsKey('image_front_url')) {
      imageUrl = product['image_front_url'];
    } else if (product.containsKey('image_url')) {
      imageUrl = product['image_url'];
    }

    final result = await showDialog<Meal>(
      context: context,
      builder: (_) => AddProductDialog(
        product: product!,
        mealType: widget.mealType,
        initialGI: gi,
        imageUrl: imageUrl,
      ),
    );

    if (result == null) return;

    if (mounted) {
      Navigator.pop(context, result);
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

        String? thumbUrl = item['image_front_small_url'] ?? item['image_small_url'] ?? item['image_url'];

        final isLocal = code.toString().startsWith('local_');

        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              image: (thumbUrl != null && thumbUrl.isNotEmpty)
                  ? DecorationImage(image: NetworkImage(thumbUrl), fit: BoxFit.cover)
                  : null,
            ),
            child: (thumbUrl == null || thumbUrl.isEmpty)
                ? Icon(Icons.restaurant, color: isLocal ? const Color(0xFF1565C0) : Colors.grey)
                : null,
          ),
          title: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)
          ),
          subtitle: brand.isNotEmpty
              ? Text(brand, style: TextStyle(color: Colors.grey[600]))
              : (isLocal ? const Text('Basic Food', style: TextStyle(color: Colors.green)) : null),
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
  final double? initialGI;
  final String? imageUrl;

  const AddProductDialog({
    required this.product,
    required this.mealType,
    this.initialGI,
    this.imageUrl,
    super.key
  });

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _gramsController;

  double _currentGrams = 100.0;

  @override
  void initState() {
    super.initState();
    _gramsController = TextEditingController(text: '100');
    _gramsController.addListener(_updateCalculations);
  }

  @override
  void dispose() {
    _gramsController.removeListener(_updateCalculations);
    _gramsController.dispose();
    super.dispose();
  }

  void _updateCalculations() {
    final val = double.tryParse(_gramsController.text.replaceAll(',', '.'));
    setState(() {
      _currentGrams = val ?? 0.0;
    });
  }

  Color _getGLColor(double gl) {
    if (gl <= 10) return Colors.green;
    if (gl <= 19) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.product['product_name'] ??
        widget.product['generic_name'] ??
        'Unknown product';

    final nutriments = (widget.product['nutriments'] as Map<String, dynamic>?) ?? {};
    final carbs100 = toDoubleSafe(nutriments['carbohydrates_100g']);

    final factor = _currentGrams / 100.0;
    final currentCarbs = carbs100 * factor;
    final currentUnits = currentCarbs / 10.0;

    double? currentGL;
    if (widget.initialGI != null) {
      currentGL = (widget.initialGI! * currentCarbs) / 100.0;
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      contentPadding: EdgeInsets.zero,
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.imageUrl != null)
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  image: DecorationImage(
                    image: NetworkImage(widget.imageUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: const Icon(Icons.restaurant, size: 40, color: Colors.grey),
              ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Add to ${widget.mealType}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text('Carb Units', style: TextStyle(fontSize: 10, color: Colors.grey[700])),
                              Text(
                                currentUnits.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text('Glycemic Load', style: TextStyle(fontSize: 10, color: Colors.grey[700])),
                              if (currentGL != null)
                                Text(
                                  currentGL.toStringAsFixed(1),
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _getGLColor(currentGL)),
                                )
                              else
                                const Text('-', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
                            ],
                          ),
                          Column(
                            children: [
                              Text('GI Index', style: TextStyle(fontSize: 10, color: Colors.grey[700])),
                              Text(
                                widget.initialGI != null ? widget.initialGI!.toInt().toString() : '-',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _gramsController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      autofocus: true,
                      style: const TextStyle(color: Colors.black, fontSize: 18),
                      decoration: InputDecoration(
                        labelText: 'Portion Size',
                        suffixText: 'g',
                        prefixIcon: const Icon(Icons.scale, color: Colors.grey),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Enter grams';
                        final n = double.tryParse(value.replaceAll(',', '.'));
                        if (n == null || n <= 0) return 'Invalid';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
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
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final grams = double.parse(_gramsController.text.replaceAll(',', '.'));

              final nutriments = (widget.product['nutriments'] as Map<String, dynamic>?) ?? {};
              final kcal100 = toDoubleSafe(nutriments['energy-kcal_100g']);
              final protein100 = toDoubleSafe(nutriments['proteins_100g']);
              final fat100 = toDoubleSafe(nutriments['fat_100g']);
              final carbs100 = toDoubleSafe(nutriments['carbohydrates_100g']);
              final fiber100 = toDoubleSafe(nutriments['fiber_100g']);
              final sugars100 = toDoubleSafe(nutriments['sugars_100g']);
              final salt100 = toDoubleSafe(nutriments['salt_100g']);

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
                glycemicIndex: widget.initialGI,
                imageUrl: widget.imageUrl,
              );

              Navigator.pop(context, meal);
            }
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: const Color(0xFF1565C0),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('Add', style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}