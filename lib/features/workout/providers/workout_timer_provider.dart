import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthbuddy/core/services/notification_service.dart';
import 'package:healthbuddy/core/constants/app_constants.dart';

class WorkoutTimerState {
  final DateTime startTime;
  final Duration elapsed;
  final int projectedXp;
  final int projectedCoins;
  final bool isEligibleForRewards;

  WorkoutTimerState({
    required this.startTime,
    this.elapsed = Duration.zero,
    this.projectedXp = 0,
    this.projectedCoins = 0,
    this.isEligibleForRewards = false,
  });

  WorkoutTimerState copyWith({
    DateTime? startTime,
    Duration? elapsed,
    int? projectedXp,
    int? projectedCoins,
    bool? isEligibleForRewards,
  }) {
    return WorkoutTimerState(
      startTime: startTime ?? this.startTime,
      elapsed: elapsed ?? this.elapsed,
      projectedXp: projectedXp ?? this.projectedXp,
      projectedCoins: projectedCoins ?? this.projectedCoins,
      isEligibleForRewards: isEligibleForRewards ?? this.isEligibleForRewards,
    );
  }
}

class WorkoutTimerNotifier extends StateNotifier<WorkoutTimerState?> {
  Timer? _ticker;
  Timer? _notificationTicker;

  WorkoutTimerNotifier() : super(null);

  void startWorkout() {
    state = WorkoutTimerState(startTime: DateTime.now());
    
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state == null) return;
      
      final newElapsed = DateTime.now().difference(state!.startTime);
      final minutes = newElapsed.inMinutes;
      final isEligible = minutes >= AppConstants.minWorkoutMinutesForRewards;
      
      state = state!.copyWith(
        elapsed: newElapsed,
        isEligibleForRewards: isEligible,
        projectedXp: isEligible ? AppConstants.xpPerWorkoutCompleted : 0,
        projectedCoins: isEligible ? AppConstants.coinsPerWorkout : 0,
      );
    });

    // Actualizar la notificación cada minuto para no saturar pero mantenerla fresca
    _updateNotification();
    _notificationTicker = Timer.periodic(const Duration(minutes: 1), (_) {
      _updateNotification();
    });
  }

  void _updateNotification() {
    if (state == null) return;
    
    final xp = state!.projectedXp;
    final coins = state!.projectedCoins;
    final status = state!.isEligibleForRewards 
        ? "Recompensas activas: ⭐$xp 🪙$coins"
        : "Faltan ${AppConstants.minWorkoutMinutesForRewards - state!.elapsed.inMinutes} min para ganar XP";

    NotificationService.showWorkoutNotification(
      title: "Entrenamiento en curso",
      body: status,
    );
  }

  void stopWorkout() {
    _ticker?.cancel();
    _notificationTicker?.cancel();
    NotificationService.cancelWorkoutNotification();
    state = null;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _notificationTicker?.cancel();
    super.dispose();
  }
}

final workoutTimerProvider = StateNotifierProvider<WorkoutTimerNotifier, WorkoutTimerState?>((ref) {
  return WorkoutTimerNotifier();
});
