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

  Widget _buildRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(
              color: isHighlight ? Colors.black87 : Colors.grey[700],
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal
          )),
          Text(value, style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isHighlight ? Colors.black : Colors.black87,
              fontSize: isHighlight ? 15 : 14
          )),
        ],
      ),
    );
  }

  String? _validateGrams(String? value) {
    if (value == null || value.isEmpty) return 'Enter amount';
    final normalized = value.replaceAll(',', '.');
    final number = double.tryParse(normalized);
    if (number == null || number <= 0) return 'Invalid';
    return null;
  }

  Color _getGLColor(double gl) {
    if (gl <= 10) return Colors.green;
    if (gl <= 19) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final currentText = _gramsController.text.replaceAll(',', '.');
    final currentGrams = double.tryParse(currentText) ?? 0;
    final factor = currentGrams / 100.0;

    final currentCarbs = _baseCarbs * factor;
    final currentUnits = currentCarbs / 10.0;

    double? currentGL;
    if (widget.meal.glycemicIndex != null) {
      currentGL = (widget.meal.glycemicIndex! * currentCarbs) / 100.0;
    }

    return AlertDialog(
      title: Text(widget.meal.name),
      backgroundColor: Colors.white,
      contentPadding: EdgeInsets.zero,
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.meal.imageUrl != null)
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  image: DecorationImage(
                    image: NetworkImage(widget.meal.imageUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(20.0),
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
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 20),

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
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: _getGLColor(currentGL)
                                  ),
                                )
                              else
                                const Text('-', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text('Nutritional Values:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const Divider(),
                    _buildRow('Calories', '${(_baseKcal * factor).round()} kcal'),
                    _buildRow('Protein', '${(_baseProtein * factor).toStringAsFixed(1)} g'),
                    _buildRow('Fat', '${(_baseFat * factor).toStringAsFixed(1)} g'),
                    _buildRow('Carbs', '${(_baseCarbs * factor).toStringAsFixed(1)} g'),
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
            if (_formKey.currentState!.validate()) {
              final text = _gramsController.text.replaceAll(',', '.');
              final newGrams = int.tryParse(text) ?? double.parse(text).round();
              Navigator.pop(context, newGrams);
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0), foregroundColor: Colors.white),
          child: const Text('Save'),
        ),
      ],
    );
  }
}