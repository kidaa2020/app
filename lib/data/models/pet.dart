import 'package:hive/hive.dart';
import 'pet_type.dart';

part 'pet.g.dart';

@HiveType(typeId: 2)
class Pet extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  PetType type;

  @HiveField(2)
  String name;

  @HiveField(3)
  int xp;

  @HiveField(4)
  DateTime? lastFedAt;

  @HiveField(5)
  DateTime createdAt;

  Pet({
    required this.id,
    required this.type,
    required this.name,
    this.xp = 0,
    this.lastFedAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  int get level {
    if (xp >= 1000) return 5;
    if (xp >= 600) return 4;
    if (xp >= 300) return 3;
    if (xp >= 100) return 2;
    return 1;
  }
}
