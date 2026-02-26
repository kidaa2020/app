import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:healthbuddy/data/models/user.dart';
import 'package:healthbuddy/data/datasources/local/hive_database.dart';

class UserRepository {
  Box<User> get _box => Hive.box<User>(HiveDatabase.userBox);

  User? getUser() {
    if (_box.isEmpty) return null;
    return _box.values.first;
  }

  Future<void> saveUser(User user) async {
    await _box.put(user.id, user);
  }

  Future<User> getOrCreateUser({String name = 'Usuario'}) async {
    final existing = getUser();
    if (existing != null) return existing;

    final user = User(
      id: const Uuid().v4(),
      name: name,
    );
    await saveUser(user);
    return user;
  }

  Future<void> updateStreak(int days) async {
    final user = getUser();
    if (user != null) {
      user.streakDays = days;
      await user.save();
    }
  }

  Future<void> addCoins(int amount) async {
    final user = getUser();
    if (user != null) {
      user.totalCoins += amount;
      await user.save();
    }
  }

  Future<bool> spendCoins(int amount) async {
    final user = getUser();
    if (user != null && user.totalCoins >= amount) {
      user.totalCoins -= amount;
      await user.save();
      return true;
    }
    return false;
  }

  Future<void> recordWorkout() async {
    final user = getUser();
    if (user != null) {
      user.lastWorkoutDate = DateTime.now();
      await user.save();
    }
  }

  bool hasUser() => _box.isNotEmpty;
}
