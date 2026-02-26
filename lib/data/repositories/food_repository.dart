import 'package:hive/hive.dart';
import 'package:healthbuddy/data/models/food_entry.dart';
import 'package:healthbuddy/data/datasources/local/hive_database.dart';

class FoodRepository {
  Box<FoodEntry> get _box => Hive.box<FoodEntry>(HiveDatabase.foodEntryBox);

  List<FoodEntry> getEntriesForDate(DateTime date) {
    return _box.values.where((entry) {
      return entry.date.year == date.year &&
          entry.date.month == date.month &&
          entry.date.day == date.day;
    }).toList();
  }

  int mealsLoggedToday() {
    final today = DateTime.now();
    return getEntriesForDate(today).length;
  }

  Future<void> addEntry(FoodEntry entry) async {
    await _box.put(entry.id, entry);
  }

  Future<void> deleteEntry(String id) async {
    await _box.delete(id);
  }

  Map<String, double> getDailyTotals(DateTime date) {
    final entries = getEntriesForDate(date);
    double totalCalories = 0;
    double totalProteins = 0;
    double totalCarbs = 0;
    double totalFats = 0;

    for (final entry in entries) {
      totalCalories += entry.scaledCalories;
      totalProteins += entry.scaledProteins;
      totalCarbs += entry.scaledCarbs;
      totalFats += entry.scaledFats;
    }

    return {
      'calories': totalCalories,
      'proteins': totalProteins,
      'carbs': totalCarbs,
      'fats': totalFats,
    };
  }
}
