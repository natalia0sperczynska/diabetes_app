import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:diabetes_app/ui/widgets/vibe/glitch.dart';
import '../../themes/colors/app_colors.dart';

import 'utils/nutrition_parser.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailsScreen({
    required this.product,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final nutriments = (product['nutriments'] as Map<String, dynamic>?) ?? {};
    final name = product['product_name'] ?? product['generic_name'] ?? 'Unknown product';
    final brand = product['brands'] ?? 'Unknown Brand';
    final colorScheme = Theme.of(context).colorScheme;

    final double p = toDoubleSafe(nutriments['proteins_100g']);
    final double c = toDoubleSafe(nutriments['carbohydrates_100g']);
    final double f = toDoubleSafe(nutriments['fat_100g']);
    final double total = p + c + f;

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
            centerTitle: true,
            title: CyberGlitchText('DATA INSPECTOR', style: GoogleFonts.vt323(fontSize: 26, fontWeight: FontWeight.bold, color: colorScheme.primary)),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCyberContainer(
                  context: context,
                  borderColor: AppColors.mainBlue,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(border: Border.all(color: Colors.white24)),
                          child: product['image_url'] != null
                              ? Image.network(product['image_url'], fit: BoxFit.cover)
                              : const Icon(Icons.fastfood, size: 40, color: Colors.white24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name.toUpperCase(), style: GoogleFonts.vt323(fontSize: 28, height: 1.0, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                              const SizedBox(height: 4),
                              Text(brand.toUpperCase(), style: GoogleFonts.iceland(fontSize: 16, color: AppColors.mainBlue)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Text('MACRONUTRIENT RATIO (100g)', style: GoogleFonts.iceland(color: colorScheme.onSurfaceVariant)),
                const SizedBox(height: 8),
                Container(
                  height: 20,
                  width: double.infinity,
                  decoration: BoxDecoration(border: Border.all(color: Colors.white24)),
                  child: Row(
                    children: [
                      if(total > 0) ...[
                        Flexible(flex: (p * 10).toInt(), child: Container(color: AppColors.green)),
                        Flexible(flex: (c * 10).toInt(), child: Container(color: AppColors.mainBlue)),
                        Flexible(flex: (f * 10).toInt(), child: Container(color: Colors.redAccent)),
                      ] else
                        Expanded(child: Container(color: Colors.grey.withOpacity(0.2)))
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLegendDot(context, 'PROTEIN', AppColors.green),
                    _buildLegendDot(context, 'CARBS', AppColors.mainBlue),
                    _buildLegendDot(context, 'FAT', Colors.redAccent),
                  ],
                ),

                const SizedBox(height: 24),

                Text('NUTRITIONAL MATRIX / 100g', style: GoogleFonts.iceland(color: colorScheme.onSurfaceVariant)),
                const SizedBox(height: 12),

                _buildDataRow(context, 'ENERGY', '${nutriments['energy-kcal_100g'] ?? 0} kcal', highlight: true),
                const Divider(color: Colors.white10),
                _buildDataRow(context, 'PROTEIN', '${p}g'),
                _buildDataRow(context, 'CARBOHYDRATES', '${c}g'),
                _buildDataRow(context, ' • SUGARS', '${toDoubleSafe(nutriments['sugars_100g'])}g', isSub: true),
                _buildDataRow(context, 'FAT', '${f}g'),
                _buildDataRow(context, ' • SATURATED', '${toDoubleSafe(nutriments['saturated-fat_100g'])}g', isSub: true),
                const Divider(color: Colors.white10),
                _buildDataRow(context, 'FIBER', '${toDoubleSafe(nutriments['fiber_100g'])}g'),
                _buildDataRow(context, 'SALT', '${toDoubleSafe(nutriments['salt_100g'])}g'),
                _buildDataRow(context, 'GLYCEMIC INDEX', '${nutriments['glycemic-index'] ?? "?"}', color: AppColors.pixelBorder),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCyberContainer({required BuildContext context, required Widget child, required Color borderColor}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: ShapeDecoration(
        color: colorScheme.surface.withOpacity(0.8),
        shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderColor, width: 1.5),
        ),
        shadows: [BoxShadow(color: borderColor.withOpacity(0.2), blurRadius: 10)],
      ),
      child: child,
    );
  }

  Widget _buildLegendDot(BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, color: color),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.vt323(color: Theme.of(context).colorScheme.onSurface)),
      ],
    );
  }

  Widget _buildDataRow(BuildContext context, String label, String value, {bool highlight = false, bool isSub = false, Color? color}) {
    final colorScheme = Theme.of(context).colorScheme;
    final finalColor = color ?? (highlight ? AppColors.mainBlue : colorScheme.onSurface);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.only(left: isSub ? 16.0 : 0),
            child: Text(label, style: GoogleFonts.iceland(fontSize: 16, color: colorScheme.onSurfaceVariant)),
          ),
          Text(value, style: GoogleFonts.vt323(fontSize: 20, fontWeight: FontWeight.bold, color: finalColor)),
        ],
      ),
    );
  }
}