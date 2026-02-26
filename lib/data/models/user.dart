import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int streakDays;

  @HiveField(3)
  DateTime? lastWorkoutDate;

  @HiveField(4)
  int totalCoins;

  @HiveField(5)
  DateTime createdAt;

  User({
    required this.id,
    required this.name,
    this.streakDays = 0,
    this.lastWorkoutDate,
    this.totalCoins = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
