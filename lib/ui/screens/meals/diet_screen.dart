import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'models/meal.dart';
import 'services/open_food_facts_service.dart';
import 'utils/nutrition_parser.dart';
import 'widgets/barcode_scanner_dialog.dart';
import 'widgets/meal_details_dialog.dart';
import 'product_details_screen.dart';

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
    _showAddDialog(product);
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

  Future<void> _showAddDialog(Map<String, dynamic> product) async {
    final result = await showDialog<AddMealResult>(
      context: context,
      builder: (_) => AddProductDialog(product: product),
    );

    if (result == null) return;

    final grams = result.grams;
    final section = result.mealType;

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
      dailyMeals[section]?.add(newMeal);
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
      floatingActionButton: FloatingActionButton(
        onPressed: _openBarcodeScanner,
        backgroundColor: primaryBlue,
        child: const Icon(Icons.qr_code_scanner, color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSummaryCard(remaining),
            const SizedBox(height: 16),
            ...dailyMeals.keys.map((key) => _buildMealSection(key)),
            const SizedBox(height: 80),
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                sectionKey,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
              Text(
                '$sectionCalories kcal',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey
                ),
              ),
            ],
          ),
        ),
        if (meals.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'No food logged',
              style: TextStyle(color: primaryBlue.withOpacity(0.4), fontSize: 12),
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

class AddMealResult {
  final double grams;
  final String mealType;
  AddMealResult(this.grams, this.mealType);
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

  String _selectedType = 'Breakfast';
  final List<String> _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snacks'];

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Add "$name"', style: const TextStyle(fontSize: 18)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _gramsController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Grams',
                  prefixIcon: const Icon(Icons.scale),
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
              const SizedBox(height: 16),
              const Text('Meal Type', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: _mealTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedType = val);
                },
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
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
              ),
            ],
          ),
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
              final grams =
              double.parse(_gramsController.text.replaceAll(',', '.'));
              Navigator.pop(context, AddMealResult(grams, _selectedType));
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