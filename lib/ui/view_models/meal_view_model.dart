import 'package:flutter/material.dart';

class MealViewModel extends ChangeNotifier {
  // Controllers for text inputs
  final TextEditingController carbsPer100gController = TextEditingController();
  final TextEditingController fiberPer100gController = TextEditingController();
  final TextEditingController gramsEatenController = TextEditingController();

  // Parsed values
  double _carbsPer100g = 0.0;
  double _fiberPer100g = 0.0;
  double _gramsEaten = 0.0;

  // Getters
  double get carbsPer100g => _carbsPer100g;
  double get fiberPer100g => _fiberPer100g;
  double get gramsEaten => _gramsEaten;

  /// Calculates digestible carbohydrates
  /// Formula: ((carbs - fiber) / 100) * grams eaten
  double get digestibleCarbohydrates {
    if (_carbsPer100g == 0 && _fiberPer100g == 0 && _gramsEaten == 0) {
      return 0.0;
    }

    double netCarbsPer100g = (_carbsPer100g - _fiberPer100g).clamp(
      0.0,
      double.infinity,
    );
    return (netCarbsPer100g / 100) * _gramsEaten;
  }

  /// Update carbohydrates per 100g
  void updateCarbsPer100g(String value) {
    _carbsPer100g = double.tryParse(value) ?? 0.0;
    notifyListeners();
  }

  /// Update fiber per 100g
  void updateFiberPer100g(String value) {
    _fiberPer100g = double.tryParse(value) ?? 0.0;
    notifyListeners();
  }

  /// Update grams eaten
  void updateGramsEaten(String value) {
    _gramsEaten = double.tryParse(value) ?? 0.0;
    notifyListeners();
  }

  /// Reset all fields
  void resetFields() {
    carbsPer100gController.clear();
    fiberPer100gController.clear();
    gramsEatenController.clear();
    _carbsPer100g = 0.0;
    _fiberPer100g = 0.0;
    _gramsEaten = 0.0;
    notifyListeners();
  }

  /// Save meal entry (placeholder for future database integration)
  void saveMeal() {
    // TODO: Implement Firebase/local storage integration
    // For now, just reset the fields
    resetFields();
  }

  @override
  void dispose() {
    carbsPer100gController.dispose();
    fiberPer100gController.dispose();
    gramsEatenController.dispose();
    super.dispose();
  }
}
