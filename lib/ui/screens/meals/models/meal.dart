class Meal {
  final String name;
  final int calories;
  final double protein;
  final double fat;
  final double carbs;
  final double fiber;
  final double sugars;
  final double salt;
  final int grams;
  final double? glycemicIndex;

  Meal({
    required this.name,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.fiber,
    required this.sugars,
    required this.salt,
    required this.grams,
    this.glycemicIndex,
  });

  double get carbUnits => carbs / 10.0;
}