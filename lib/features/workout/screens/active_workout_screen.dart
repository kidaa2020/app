import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthbuddy/features/workout/providers/workout_provider.dart';
import 'package:healthbuddy/core/theme/app_colors.dart';
import 'package:healthbuddy/core/theme/app_text_styles.dart';
import 'package:healthbuddy/data/models/routine.dart';
import 'package:healthbuddy/data/models/exercise.dart';
import 'package:healthbuddy/data/models/exercise_set.dart';
import 'package:healthbuddy/data/models/workout_session.dart';
import 'package:healthbuddy/features/workout/providers/workout_timer_provider.dart';
import 'package:healthbuddy/core/services/notification_service.dart';
import 'package:healthbuddy/core/constants/app_constants.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  final Routine routine;
  const ActiveWorkoutScreen({super.key, required this.routine});

  @override
  ConsumerState<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  late List<Exercise> _workingExercises;
  WorkoutSession? _previousSession;
  @override
  void initState() {
    super.initState();
    _workingExercises = widget.routine.exercises.map((e) => e.copyWith()).toList();
    _previousSession = ref.read(workoutSessionsProvider.notifier).getLastSessionForRoutine(widget.routine.id);
    
    // Iniciar el timer global y la notificación
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(workoutTimerProvider.notifier).startWorkout();
    });
  }

  @override
  void dispose() {
    // No detenemos el timer aquí por si el usuario sale de la pantalla por error
    // Se detiene explícitamente al finalizar o cancelar
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(workoutTimerProvider);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.routine.name, style: AppTextStyles.h3),
            if (timerState != null)
              Text(
                _formatDuration(timerState.elapsed),
                style: AppTextStyles.caption.copyWith(color: AppColors.mintGreenDark, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _showExitConfirmation(context),
            icon: const Icon(Icons.close, color: AppColors.error),
            label: Text('Cancelar', style: AppTextStyles.bodyBold.copyWith(color: AppColors.error)),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton(
              onPressed: _completeWorkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mintGreen,
                foregroundColor: AppColors.darkText,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text('Finalizar'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (timerState != null) _buildLiveStats(timerState),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _workingExercises.length,
              itemBuilder: (context, index) {
                final exercise = _workingExercises[index];
                final prevExercise = _findPreviousExercise(exercise.name);
                return _buildExerciseCard(exercise, prevExercise, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveStats(WorkoutTimerState state) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _statItem('⏱️', _formatDuration(state.elapsed), 'Tiempo'),
          _statItem('⭐', '${state.projectedXp}', 'XP'),
          _statItem('🪙', '${state.projectedCoins}', 'Monedas'),
          _statItem('📈', '${_calculateIntensity()}%', 'Intensidad'),
        ],
      ),
    );
  }

  Widget _statItem(String icon, String value, String label) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        Text(value, style: AppTextStyles.bodyBold),
        Text(label, style: AppTextStyles.caption.copyWith(fontSize: 10)),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "${d.inHours > 0 ? '${d.inHours}:' : ''}$m:$s";
  }

  int _calculateIntensity() {
    int completedSets = 0;
    int totalSets = 0;
    for (var ex in _workingExercises) {
      totalSets += ex.sets.length;
      completedSets += ex.sets.where((s) => s.completed).length;
    }
    if (totalSets == 0) return 0;
    return ((completedSets / totalSets) * 100).round();
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Cancelar entrenamiento?'),
        content: const Text('Perderás todo el progreso de esta sesión.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Continuar')),
          TextButton(
            onPressed: () {
              ref.read(workoutTimerProvider.notifier).stopWorkout();
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Cancelar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Exercise? _findPreviousExercise(String name) {
    if (_previousSession == null) return null;
    try {
      return _previousSession!.exercises.firstWhere((e) => e.name == name);
    } catch (_) {
      return null;
    }
  }

  Widget _buildExerciseCard(Exercise exercise, Exercise? prev, int exerciseIdx) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(exercise.name, style: AppTextStyles.bodyBold)),
              if (prev != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.mintGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.history, size: 14, color: AppColors.skyBlueDark),
                      const SizedBox(width: 4),
                      Text(
                        _formatPreviousPerformance(prev),
                        style: AppTextStyles.caption.copyWith(color: AppColors.skyBlueDark, fontSize: 11),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const SizedBox(width: 36),
              Expanded(child: Text('Reps', style: AppTextStyles.caption, textAlign: TextAlign.center)),
              Expanded(child: Text('Peso (kg)', style: AppTextStyles.caption, textAlign: TextAlign.center)),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 4),
          ...exercise.sets.asMap().entries.map((setEntry) => _buildSetRow(exerciseIdx, setEntry.key, setEntry.value)),
          Center(
            child: TextButton.icon(
              onPressed: () => setState(() => exercise.sets.add(ExerciseSet(reps: 10, weight: 0))),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Añadir serie'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetRow(int exerciseIdx, int setIdx, ExerciseSet set) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(width: 36, child: Text('${setIdx + 1}', style: AppTextStyles.caption, textAlign: TextAlign.center)),
          Expanded(
            child: SizedBox(
              height: 40,
              child: TextField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: '${set.reps}'),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onChanged: (v) => _workingExercises[exerciseIdx].sets[setIdx] = set.copyWith(reps: int.tryParse(v) ?? set.reps),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 40,
              child: TextField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: '${set.weight}'),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onChanged: (v) => _workingExercises[exerciseIdx].sets[setIdx] = set.copyWith(weight: double.tryParse(v) ?? set.weight),
              ),
            ),
          ),
          SizedBox(
            width: 48,
            child: Checkbox(
              value: set.completed,
              activeColor: AppColors.mintGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              onChanged: (v) => setState(() => _workingExercises[exerciseIdx].sets[setIdx] = set.copyWith(completed: v ?? false)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPreviousPerformance(Exercise prev) {
    if (prev.sets.isEmpty) return 'Sin datos anteriores';
    final bestSet = prev.sets.reduce((a, b) => a.weight >= b.weight ? a : b);
    return '${bestSet.weight}kg × ${bestSet.reps}';
  }

  void _completeWorkout() {
    final timerState = ref.read(workoutTimerProvider);
    if (timerState == null) return;
    
    final duration = timerState.elapsed;
    final isEligible = timerState.isEligibleForRewards;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Text(isEligible ? '🎉 ' : '⚠️ ', style: const TextStyle(fontSize: 28)),
            Text(isEligible ? '¡Buen trabajo!' : 'Sesión corta', style: AppTextStyles.h3),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Duración: ${_formatDuration(duration)}', style: AppTextStyles.subtitle),
            const SizedBox(height: 16),
            if (isEligible)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.mintGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text('+${AppConstants.xpPerWorkoutCompleted} XP', style: AppTextStyles.bodyBold),
                    const SizedBox(width: 16),
                    const Text('🪙', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text('+${AppConstants.coinsPerWorkout} monedas', style: AppTextStyles.bodyBold),
                  ],
                ),
              )
            else
              Text(
                'Los entrenamientos de menos de ${AppConstants.minWorkoutMinutesForRewards} minutos no otorgan XP ni monedas.',
                style: AppTextStyles.caption.copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Seguir entrenando'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(workoutSessionsProvider.notifier).completeWorkout(
                widget.routine.id, 
                widget.routine.name, 
                _workingExercises,
                duration,
              );
              ref.read(workoutTimerProvider.notifier).stopWorkout();
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Guardar y salir'),
          ),
        ],
      ),
    );
  }
}
