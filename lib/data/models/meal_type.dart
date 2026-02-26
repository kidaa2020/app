import 'package:hive/hive.dart';

part 'meal_type.g.dart';

@HiveType(typeId: 10)
enum MealType {
  @HiveField(0)
  breakfast,

  @HiveField(1)
  lunch,

  @HiveField(2)
  meal,

  @HiveField(3)
  snack,

  @HiveField(4)
  dinner;

  String get label {
    switch (this) {
      case MealType.breakfast:
        return 'Desayuno';
      case MealType.lunch:
        return 'Almuerzo';
      case MealType.meal:
        return 'Comida';
      case MealType.snack:
        return 'Merienda';
      case MealType.dinner:
        return 'Cena';
    }
  }

  String get icon {
    switch (this) {
      case MealType.breakfast:
        return '🌅';
      case MealType.lunch:
        return '☀️';
      case MealType.meal:
        return '🍽️';
      case MealType.snack:
        return '🍎';
      case MealType.dinner:
        return '🌙';
    }
  }
}
