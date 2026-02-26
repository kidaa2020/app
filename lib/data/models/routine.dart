import 'package:hive/hive.dart';
import 'exercise.dart';

part 'routine.g.dart';

@HiveType(typeId: 3)
class Routine extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<Exercise> exercises;

  @HiveField(3)
  DateTime createdAt;

  Routine({
    required this.id,
    required this.name,
    List<Exercise>? exercises,
    DateTime? createdAt,
  })  : exercises = exercises ?? [],
        createdAt = createdAt ?? DateTime.now();
}
