import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthbuddy/features/workout/providers/workout_provider.dart';
import 'package:healthbuddy/core/theme/app_colors.dart';
import 'package:healthbuddy/core/theme/app_text_styles.dart';
import 'package:healthbuddy/data/models/routine.dart';
import 'package:healthbuddy/data/models/exercise.dart';
import 'package:healthbuddy/data/models/exercise_set.dart';
import 'package:healthbuddy/data/models/workout_session.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  final Routine routine;
  const ActiveWorkoutScreen({super.key, required this.routine});

  @override
  ConsumerState<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  late List<Exercise> _workingExercises;
  WorkoutSession? _previousSession;
  final Stopwatch _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _workingExercises = widget.routine.exercises.map((e) => e.copyWith()).toList();
    _previousSession = ref.read(workoutSessionsProvider.notifier).getLastSessionForRoutine(widget.routine.id);
    _stopwatch.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.routine.name, style: AppTextStyles.h3),
        actions: [
          TextButton.icon(
            onPressed: _completeWorkout,
            icon: const Icon(Icons.check_circle, color: AppColors.mintGreenDark),
            label: Text('Finalizar', style: AppTextStyles.bodyBold.copyWith(color: AppColors.mintGreenDark)),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _workingExercises.length,
        itemBuilder: (context, index) {
          final exercise = _workingExercises[index];
          final prevExercise = _findPreviousExercise(exercise.name);
          return _buildExerciseCard(exercise, prevExercise, index);
        },
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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
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
                    color: AppColors.skyBlue.withValues(alpha: 0.15),
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
    _stopwatch.stop();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Text('🎉 ', style: TextStyle(fontSize: 28)),
            Text('¡Entreno completado!', style: AppTextStyles.h3),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Duración: ${_stopwatch.elapsed.inMinutes} min', style: AppTextStyles.subtitle),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.mintGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text('+20 XP', style: AppTextStyles.bodyBold),
                  const SizedBox(width: 16),
                  const Text('🪙', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text('+5 monedas', style: AppTextStyles.bodyBold),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              ref.read(workoutSessionsProvider.notifier).completeWorkout(widget.routine.id, widget.routine.name, _workingExercises);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('¡Genial!'),
          ),
        ],
      ),
    );
  }
}
