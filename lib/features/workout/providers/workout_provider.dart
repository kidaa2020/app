import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:healthbuddy/data/repositories/workout_repository.dart';
import 'package:healthbuddy/data/repositories/user_repository.dart';
import 'package:healthbuddy/data/repositories/pet_repository.dart';
import 'package:healthbuddy/data/models/routine.dart';
import 'package:healthbuddy/data/models/workout_session.dart';
import 'package:healthbuddy/data/models/exercise.dart';
import 'package:healthbuddy/core/constants/app_constants.dart';

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return WorkoutRepository();
});

final routinesProvider =
    StateNotifierProvider<RoutinesNotifier, List<Routine>>((ref) {
  return RoutinesNotifier(ref.read(workoutRepositoryProvider));
});

final workoutSessionsProvider =
    StateNotifierProvider<WorkoutSessionsNotifier, List<WorkoutSession>>((ref) {
  return WorkoutSessionsNotifier(
    ref.read(workoutRepositoryProvider),
    UserRepository(),
    PetRepository(),
  );
});

final streakProvider = Provider<int>((ref) {
  ref.watch(workoutSessionsProvider);
  return ref.read(workoutRepositoryProvider).calculateStreak();
});

class RoutinesNotifier extends StateNotifier<List<Routine>> {
  final WorkoutRepository _repository;

  RoutinesNotifier(this._repository) : super(_repository.getAllRoutines());

  void refresh() {
    state = _repository.getAllRoutines();
  }

  Future<void> addRoutine(Routine routine) async {
    await _repository.saveRoutine(routine);
    refresh();
  }

  Future<void> updateRoutine(Routine routine) async {
    await _repository.saveRoutine(routine);
    refresh();
  }

  Future<void> deleteRoutine(String id) async {
    await _repository.deleteRoutine(id);
    refresh();
  }
}

class WorkoutSessionsNotifier extends StateNotifier<List<WorkoutSession>> {
  final WorkoutRepository _repository;
  final UserRepository _userRepo;
  final PetRepository _petRepo;

  WorkoutSessionsNotifier(this._repository, this._userRepo, this._petRepo)
      : super(_repository.getAllSessions());

  void refresh() {
    state = _repository.getAllSessions();
  }

  Future<void> completeWorkout(
      String routineId, String routineName, List<Exercise> exercises, Duration duration) async {
    final isEligible = duration.inMinutes >= AppConstants.minWorkoutMinutesForRewards;
    final session = WorkoutSession(
      id: const Uuid().v4(),
      routineId: routineId,
      routineName: routineName,
      exercises: exercises,
      completed: true,
      duration: duration,
    );
    await _repository.saveSession(session);
    await _userRepo.recordWorkout();

    // Award XP and coins only if eligible
    if (isEligible) {
      await _petRepo.addXp(AppConstants.xpPerWorkoutCompleted);
      await _userRepo.addCoins(AppConstants.coinsPerWorkout);
      
      // Check streak bonus
      final streak = _repository.calculateStreak();
      await _userRepo.updateStreak(streak);
      if (streak > 0 && streak % AppConstants.streakBonusDays == 0) {
        await _petRepo.addXp(AppConstants.xpStreakBonus);
      }
    }

    refresh();
  }

  WorkoutSession? getLastSessionForRoutine(String routineId) {
    return _repository.getLastSessionForRoutine(routineId);
  }
}
