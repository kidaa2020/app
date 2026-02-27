import 'package:hive/hive.dart';
import 'exercise.dart';

part 'workout_session.g.dart';

@HiveType(typeId: 6)
class WorkoutSession extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String routineId;

  @HiveField(2)
  String routineName;

  @HiveField(3)
  List<Exercise> exercises;

  @HiveField(4)
  DateTime date;

  @HiveField(5)
  bool completed;

  @HiveField(6)
  Duration duration;

  WorkoutSession({
    required this.id,
    required this.routineId,
    required this.routineName,
    List<Exercise>? exercises,
    DateTime? date,
    this.completed = false,
    this.duration = Duration.zero,
  })  : exercises = exercises ?? [],
        date = date ?? DateTime.now();
}
