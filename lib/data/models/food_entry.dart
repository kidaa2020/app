import 'package:hive/hive.dart';
import 'meal_type.dart';

part 'food_entry.g.dart';

@HiveType(typeId: 1)
class FoodEntry extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String productName;

  @HiveField(2)
  String? barcode;

  @HiveField(3)
  double calories;

  @HiveField(4)
  double proteins;

  @HiveField(5)
  double carbs;

  @HiveField(6)
  double fats;

  @HiveField(7)
  double quantity; // grams

  @HiveField(8)
  MealType mealType;

  @HiveField(9)
  DateTime date;

  FoodEntry({
    required this.id,
    required this.productName,
    this.barcode,
    required this.calories,
    required this.proteins,
    required this.carbs,
    required this.fats,
    required this.quantity,
    required this.mealType,
    required this.date,
  });

  /// Scaled values based on quantity (from per-100g values)
  double get scaledCalories => (calories * quantity) / 100;
  double get scaledProteins => (proteins * quantity) / 100;
  double get scaledCarbs => (carbs * quantity) / 100;
  double get scaledFats => (fats * quantity) / 100;
}
