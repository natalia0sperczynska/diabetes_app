import 'package:flutter/material.dart';
import '../models/meal.dart';

class MealDetailsDialog extends StatefulWidget {
  final Meal meal;

  const MealDetailsDialog({required this.meal, super.key});

  @override
  State<MealDetailsDialog> createState() => _MealDetailsDialogState();
}

class _MealDetailsDialogState extends State<MealDetailsDialog> {
  final _formKey = GlobalKey<FormState>();
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

  String? _validateGrams(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an amount';
    }
    final normalized = value.replaceAll(',', '.');
    final number = double.tryParse(normalized);
    if (number == null) {
      return 'Invalid number';
    }
    if (number <= 0) {
      return 'Must be positive';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final currentText = _gramsController.text.replaceAll(',', '.');
    final currentGrams = double.tryParse(currentText) ?? 0;
    final factor = currentGrams / 100.0;

    return AlertDialog(
      title: Text(widget.meal.name),
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
                validator: _validateGrams,
                decoration: const InputDecoration(
                  labelText: 'Grams',
                  suffixText: 'g',
                  border: OutlineInputBorder(),
                  hintText: 'e.g. 100',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),
              const Text('Nutritional Values:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
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
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, 'delete');
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Delete'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final text = _gramsController.text.replaceAll(',', '.');
              final newGrams = int.tryParse(text) ?? double.parse(text).round();
              Navigator.pop(context, newGrams);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}