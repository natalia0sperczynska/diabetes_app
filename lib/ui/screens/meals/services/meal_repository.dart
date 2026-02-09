import 'package:hive_flutter/hive_flutter.dart';
import '../models/meal.dart';

class MealRepository {
  static const String boxName = 'meal_history';

  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MealAdapter());
    }
    await Hive.openBox<List>(boxName);
  }

  Box<List> get _box => Hive.box<List>(boxName);

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  List<Meal> getMealsForDate(DateTime date) {
    final key = _getDateKey(date);
    final dynamicList = _box.get(key, defaultValue: []);
    if (dynamicList == null) return [];
    return dynamicList.cast<Meal>().toList();
  }

  Future<void> addMeal(DateTime date, Meal meal) async {
    final key = _getDateKey(date);
    final currentMeals = getMealsForDate(date);
    currentMeals.add(meal);
    await _box.put(key, currentMeals);
  }

  Future<void> deleteMeal(DateTime date, Meal meal) async {
    final key = _getDateKey(date);
    final currentMeals = getMealsForDate(date);

    currentMeals.remove(meal);

    await _box.put(key, currentMeals);
  }

  Future<void> updateMeal(DateTime date, Meal oldMeal, Meal newMeal) async {
    final key = _getDateKey(date);
    final currentMeals = getMealsForDate(date);

    final index = currentMeals.indexOf(oldMeal);
    if (index != -1) {
      currentMeals[index] = newMeal;
      await _box.put(key, currentMeals);
    }
  }
}