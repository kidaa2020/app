import 'package:hive/hive.dart';
import 'package:healthbuddy/data/models/routine.dart';
import 'package:healthbuddy/data/models/workout_session.dart';
import 'package:healthbuddy/data/datasources/local/hive_database.dart';

class WorkoutRepository {
  Box<Routine> get _routineBox =>
      Hive.box<Routine>(HiveDatabase.routineBox);
  Box<WorkoutSession> get _sessionBox =>
      Hive.box<WorkoutSession>(HiveDatabase.workoutSessionBox);

  List<Routine> getAllRoutines() {
    return _routineBox.values.toList();
  }

  Routine? getRoutine(String id) {
    return _routineBox.get(id);
  }

  Future<void> saveRoutine(Routine routine) async {
    await _routineBox.put(routine.id, routine);
  }

  Future<void> deleteRoutine(String id) async {
    await _routineBox.delete(id);
  }

  List<WorkoutSession> getAllSessions() {
    return _sessionBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<WorkoutSession> getSessionsForDate(DateTime date) {
    return _sessionBox.values.where((s) {
      return s.date.year == date.year &&
          s.date.month == date.month &&
          s.date.day == date.day;
    }).toList();
  }

  WorkoutSession? getLastSessionForRoutine(String routineId) {
    final sessions = _sessionBox.values
        .where((s) => s.routineId == routineId && s.completed)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return sessions.isNotEmpty ? sessions.first : null;
  }

  Future<void> saveSession(WorkoutSession session) async {
    await _sessionBox.put(session.id, session);
  }

  bool hasWorkoutOnDate(DateTime date) {
    return _sessionBox.values.any((s) =>
        s.completed &&
        s.date.year == date.year &&
        s.date.month == date.month &&
        s.date.day == date.day);
  }

  int calculateStreak() {
    int streak = 0;
    DateTime checkDate = DateTime.now();

    if (!hasWorkoutOnDate(checkDate)) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    while (hasWorkoutOnDate(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }
}
