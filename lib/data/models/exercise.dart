import 'package:hive/hive.dart';
import 'exercise_set.dart';

part 'exercise.g.dart';

@HiveType(typeId: 4)
class Exercise extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<ExerciseSet> sets;

  Exercise({
    required this.id,
    required this.name,
    List<ExerciseSet>? sets,
  }) : sets = sets ?? [];

  Exercise copyWith({String? id, String? name, List<ExerciseSet>? sets}) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      sets: sets ?? this.sets.map((s) => s.copyWith()).toList(),
    );
  }
}
