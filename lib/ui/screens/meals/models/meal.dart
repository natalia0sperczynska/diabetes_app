import 'package:hive/hive.dart';

part 'meal.g.dart';

@HiveType(typeId: 0)
class Meal extends HiveObject {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final int calories;
  @HiveField(2)
  final double protein;
  @HiveField(3)
  final double fat;
  @HiveField(4)
  final double carbs;
  @HiveField(5)
  final double fiber;
  @HiveField(6)
  final double sugars;
  @HiveField(7)
  final double salt;
  @HiveField(8)
  final int grams;
  @HiveField(9)
  final double? glycemicIndex;
  @HiveField(10)
  final String? imageUrl;

  @HiveField(11, defaultValue: 'Snack')
  final String mealType;

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
    this.imageUrl,
    this.mealType = 'Snack',
  });

  // Carb Unit (WW/BE) = 10g Carbs
  double get carbUnits => carbs / 10.0;

  // Glycemic Load
  double get glycemicLoad {
    if (glycemicIndex == null) return 0.0;
    return (glycemicIndex! * carbs) / 100.0;
  }

  Meal copyWith({
    String? name,
    int? calories,
    double? protein,
    double? fat,
    double? carbs,
    double? fiber,
    double? sugars,
    double? salt,
    int? grams,
    double? glycemicIndex,
    String? imageUrl,
    String? mealType,
  }) {
    return Meal(
      name: name ?? this.name,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      carbs: carbs ?? this.carbs,
      fiber: fiber ?? this.fiber,
      sugars: sugars ?? this.sugars,
      salt: salt ?? this.salt,
      grams: grams ?? this.grams,
      glycemicIndex: glycemicIndex ?? this.glycemicIndex,
      imageUrl: imageUrl ?? this.imageUrl,
      mealType: mealType ?? this.mealType,
    );
  }
}