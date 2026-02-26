import 'package:hive/hive.dart';
import 'package:healthbuddy/data/models/pet.dart';
import 'package:healthbuddy/data/datasources/local/hive_database.dart';

class PetRepository {
  Box<Pet> get _box => Hive.box<Pet>(HiveDatabase.petBox);

  Pet? getPet() {
    if (_box.isEmpty) return null;
    return _box.values.first;
  }

  Future<void> savePet(Pet pet) async {
    await _box.put(pet.id, pet);
  }

  Future<void> addXp(int amount) async {
    final pet = getPet();
    if (pet != null) {
      pet.xp += amount;
      await pet.save();
    }
  }

  Future<void> feedPet() async {
    final pet = getPet();
    if (pet != null) {
      pet.lastFedAt = DateTime.now();
      await pet.save();
    }
  }

  bool hasPet() => _box.isNotEmpty;
}
