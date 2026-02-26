import 'package:hive_flutter/hive_flutter.dart';
import 'package:healthbuddy/data/models/user.dart';
import 'package:healthbuddy/data/models/food_entry.dart';
import 'package:healthbuddy/data/models/pet.dart';
import 'package:healthbuddy/data/models/routine.dart';
import 'package:healthbuddy/data/models/exercise.dart';
import 'package:healthbuddy/data/models/exercise_set.dart';
import 'package:healthbuddy/data/models/workout_session.dart';
import 'package:healthbuddy/data/models/meal_type.dart';
import 'package:healthbuddy/data/models/pet_type.dart';

class HiveDatabase {
  static const String userBox = 'users';
  static const String foodEntryBox = 'food_entries';
  static const String petBox = 'pets';
  static const String routineBox = 'routines';
  static const String workoutSessionBox = 'workout_sessions';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(FoodEntryAdapter());
    Hive.registerAdapter(PetAdapter());
    Hive.registerAdapter(RoutineAdapter());
    Hive.registerAdapter(ExerciseAdapter());
    Hive.registerAdapter(ExerciseSetAdapter());
    Hive.registerAdapter(WorkoutSessionAdapter());
    Hive.registerAdapter(MealTypeAdapter());
    Hive.registerAdapter(PetTypeAdapter());

    // Open boxes
    await Hive.openBox<User>(userBox);
    await Hive.openBox<FoodEntry>(foodEntryBox);
    await Hive.openBox<Pet>(petBox);
    await Hive.openBox<Routine>(routineBox);
    await Hive.openBox<WorkoutSession>(workoutSessionBox);
  }
}
