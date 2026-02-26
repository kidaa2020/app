import 'package:hive/hive.dart';

part 'exercise_set.g.dart';

@HiveType(typeId: 5)
class ExerciseSet extends HiveObject {
  @HiveField(0)
  int reps;

  @HiveField(1)
  double weight;

  @HiveField(2)
  bool completed;

  ExerciseSet({
    required this.reps,
    required this.weight,
    this.completed = false,
  });

  ExerciseSet copyWith({int? reps, double? weight, bool? completed}) {
    return ExerciseSet(
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      completed: completed ?? this.completed,
    );
  }
}
