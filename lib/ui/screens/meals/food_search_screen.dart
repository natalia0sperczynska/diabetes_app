import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:diabetes_app/ui/widgets/vibe/glitch.dart';
import '../../themes/colors/app_colors.dart';

import 'models/meal.dart';
import 'services/open_food_facts_service.dart';
import 'services/local_food_service.dart';
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

    final localResults = LocalFoodService.searchLocal(query);

    final apiResults = await OpenFoodFactsService.searchProducts(query);

    if (!mounted) return;

    setState(() {
      _searchResults = [...localResults, ...apiResults];
      _isLoading = false;
    });
  }

  Future<void> _onScanBarcode() async {
    await showDialog(
      context: context,
      builder: (_) => const BarcodeScannerDialog(),
    ).then((val) async {
      if (val is String && val.isNotEmpty) {
        setState(() => _isLoading = true);
        final product = await OpenFoodFactsService.fetchProduct(val);
        setState(() => _isLoading = false);

        if (product != null && mounted) {
          _showQuantityDialog(product);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Theme.of(context).colorScheme.error,
              content: Text("Product not found", style: GoogleFonts.vt323(fontSize: 18)),
            ),
          );
        }
      }
    });
  }

  void _showQuantityDialog(Map<String, dynamic> product) {
    final name = product['product_name'] ?? 'Unknown';
    final nutriments = product['nutriments'] ?? {};
    final TextEditingController gramsController = TextEditingController(text: '100');
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: ShapeDecoration(
            color: colorScheme.surface.withOpacity(0.95),
            shape: BeveledRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppColors.mainBlue, width: 2),
            ),
            shadows: [
              BoxShadow(color: AppColors.mainBlue.withOpacity(0.4), blurRadius: 20)
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CyberGlitchText('ADD ENTRY', style: GoogleFonts.vt323(fontSize: 24, color: AppColors.mainBlue, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text(name, textAlign: TextAlign.center, style: GoogleFonts.iceland(fontSize: 18, color: colorScheme.onSurface)),
              const SizedBox(height: 24),

              TextField(
                controller: gramsController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.vt323(fontSize: 24, color: AppColors.green),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: 'QUANTITY (g)',
                  labelStyle: GoogleFonts.iceland(color: colorScheme.onSurfaceVariant),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.green, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('CANCEL', style: GoogleFonts.vt323(fontSize: 18, color: Colors.grey)),
                  ),

                  InkWell(
                    onTap: () {
                      final grams = double.tryParse(gramsController.text) ?? 100.0;

                      final kcal100 = toDoubleSafe(nutriments['energy-kcal_100g']);
                      final p100 = toDoubleSafe(nutriments['proteins_100g']);
                      final f100 = toDoubleSafe(nutriments['fat_100g']);
                      final c100 = toDoubleSafe(nutriments['carbohydrates_100g']);
                      final fiber100 = toDoubleSafe(nutriments['fiber_100g']);
                      final sugar100 = toDoubleSafe(nutriments['sugars_100g']);
                      final salt100 = toDoubleSafe(nutriments['salt_100g']);

                      double? gi = toDoubleSafe(nutriments['glycemic-index']);
                      if (gi == 0.0) gi = null;

                      final factor = grams / 100.0;

                      final meal = Meal(
                        name: name,
                        calories: (kcal100 * factor).round(),
                        protein: p100 * factor,
                        fat: f100 * factor,
                        carbs: c100 * factor,
                        fiber: fiber100 * factor,
                        sugars: sugar100 * factor,
                        salt: salt100 * factor,
                        grams: grams.round(),
                        glycemicIndex: gi,
                        imageUrl: product['image_url'],
                        mealType: widget.mealType,
                      );

                      Navigator.pop(ctx);
                      Navigator.pop(context, meal);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.mainBlue.withOpacity(0.2),
                        border: Border.all(color: AppColors.mainBlue),
                      ),
                      child: Text('CONFIRM', style: GoogleFonts.vt323(fontSize: 18, color: AppColors.mainBlue, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
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
            child: Image.asset('assets/images/grid.png', repeat: ImageRepeat.repeat, errorBuilder: (_,__,___) => Container()),
          ),
        ),

        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: const BackButton(),
            title: CyberGlitchText('DATABASE SEARCH', style: GoogleFonts.vt323(fontSize: 26, fontWeight: FontWeight.bold, color: colorScheme.primary)),
            centerTitle: true,
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: ShapeDecoration(
                    color: colorScheme.surface.withOpacity(0.8),
                    shape: BeveledRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: AppColors.mainBlue.withOpacity(0.6), width: 1),
                    ),
                    shadows: [BoxShadow(color: AppColors.mainBlue.withOpacity(0.1), blurRadius: 10)],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: GoogleFonts.vt323(fontSize: 20, color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: 'ENTER PRODUCT NAME...',
                      hintStyle: GoogleFonts.vt323(color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
                      prefixIcon: Icon(Icons.search, color: AppColors.mainBlue),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.qr_code_scanner, color: AppColors.green),
                        onPressed: _onScanBarcode,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator(color: AppColors.mainBlue))
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final product = _searchResults[index];
                    return _buildResultTile(product);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultTile(Map<String, dynamic> product) {
    final name = product['product_name'] ?? 'Unknown';
    final brand = product['brands'] ?? '';
    final nutriments = product['nutriments'] ?? {};
    final kcal = nutriments['energy-kcal_100g']?.toString() ?? '-';
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => _showQuantityDialog(product),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: colorScheme.surface.withOpacity(0.6),
          border: Border(left: BorderSide(color: AppColors.mainBlue.withOpacity(0.5), width: 4)),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                color: Colors.black12,
                border: Border.all(color: Colors.white10),
              ),
              child: product['image_url'] != null
                  ? Image.network(product['image_url'], fit: BoxFit.cover, errorBuilder: (_,__,___) => Icon(Icons.fastfood, color: Colors.white24))
                  : Icon(Icons.inventory_2, color: AppColors.mainBlue.withOpacity(0.7)),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      name.toUpperCase(),
                      style: GoogleFonts.vt323(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis
                  ),
                  if (brand.isNotEmpty)
                    Text(brand, style: GoogleFonts.iceland(fontSize: 14, color: colorScheme.onSurfaceVariant)),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  border: Border.all(color: AppColors.pixelBorder.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(4)
              ),
              child: Text(
                  '$kcal KCAL',
                  style: GoogleFonts.vt323(fontSize: 16, color: AppColors.pixelBorder, fontWeight: FontWeight.bold)
              ),
            ),

            const SizedBox(width: 12),
            Icon(Icons.add_circle_outline, color: AppColors.mainBlue),
          ],
        ),
      ),
    );
  }
}