import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:healthbuddy/features/workout/providers/workout_provider.dart';
import 'package:healthbuddy/core/theme/app_colors.dart';
import 'package:healthbuddy/core/theme/app_text_styles.dart';
import 'package:healthbuddy/data/models/routine.dart';
import 'package:healthbuddy/data/models/exercise.dart';
import 'package:healthbuddy/data/models/exercise_set.dart';

class RoutineEditorScreen extends ConsumerStatefulWidget {
  final Routine? routine;
  const RoutineEditorScreen({super.key, this.routine});

  @override
  ConsumerState<RoutineEditorScreen> createState() => _RoutineEditorScreenState();
}

class _RoutineEditorScreenState extends ConsumerState<RoutineEditorScreen> {
  late TextEditingController _nameController;
  late List<Exercise> _exercises;
  bool get _isEditing => widget.routine != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.routine?.name ?? '');
    _exercises = widget.routine?.exercises.map((e) => e.copyWith()).toList() ?? [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar rutina' : 'Nueva rutina', style: AppTextStyles.h3),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text('Guardar', style: AppTextStyles.bodyBold.copyWith(color: AppColors.mintGreenDark)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nombre de la rutina',
              hintText: 'Ej: Push Day, Pierna...',
              prefixIcon: Icon(Icons.label),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ejercicios', style: AppTextStyles.h3),
              TextButton.icon(onPressed: _addExercise, icon: const Icon(Icons.add, size: 18), label: const Text('Añadir')),
            ],
          ),
          const SizedBox(height: 8),
          ..._exercises.asMap().entries.map((entry) => _buildExerciseCard(entry.value, entry.key)),
          if (_exercises.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(child: Text('Añade ejercicios a tu rutina', style: AppTextStyles.caption)),
            ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(Exercise exercise, int exerciseIndex) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.mintGreen.withOpacity(0.1), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(exercise.name, style: AppTextStyles.bodyBold)),
              IconButton(
                icon: const Icon(Icons.delete, color: AppColors.error, size: 20),
                onPressed: () => setState(() => _exercises.removeAt(exerciseIndex)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const SizedBox(width: 32),
              Expanded(child: Text('Reps', style: AppTextStyles.caption, textAlign: TextAlign.center)),
              Expanded(child: Text('Peso (kg)', style: AppTextStyles.caption, textAlign: TextAlign.center)),
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 4),
          ...exercise.sets.asMap().entries.map((setEntry) {
            final setIdx = setEntry.key;
            final set = setEntry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  SizedBox(width: 32, child: Text('${setIdx + 1}', style: AppTextStyles.caption, textAlign: TextAlign.center)),
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: TextField(
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(contentPadding: EdgeInsets.zero, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                        controller: TextEditingController(text: '${set.reps}'),
                        onChanged: (v) => exercise.sets[setIdx] = set.copyWith(reps: int.tryParse(v) ?? set.reps),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: TextField(
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(contentPadding: EdgeInsets.zero, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                        controller: TextEditingController(text: '${set.weight}'),
                        onChanged: (v) => exercise.sets[setIdx] = set.copyWith(weight: double.tryParse(v) ?? set.weight),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 18, color: AppColors.error),
                      onPressed: () => setState(() => exercise.sets.removeAt(setIdx)),
                    ),
                  ),
                ],
              ),
            );
          }),
          TextButton.icon(
            onPressed: () => setState(() => exercise.sets.add(ExerciseSet(reps: 10, weight: 0))),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Añadir serie'),
          ),
        ],
      ),
    );
  }

  void _addExercise() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo ejercicio'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nombre del ejercicio', prefixIcon: Icon(Icons.fitness_center)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() => _exercises.add(Exercise(id: const Uuid().v4(), name: controller.text, sets: [ExerciseSet(reps: 10, weight: 0)])));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Añadir'),
          ),
        ],
      ),
    );
  }

  void _save() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Escribe un nombre para la rutina')));
      return;
    }
    final routine = Routine(
      id: widget.routine?.id ?? const Uuid().v4(),
      name: _nameController.text,
      exercises: _exercises,
      createdAt: widget.routine?.createdAt ?? DateTime.now(),
    );
    if (_isEditing) {
      ref.read(routinesProvider.notifier).updateRoutine(routine);
    } else {
      ref.read(routinesProvider.notifier).addRoutine(routine);
    }
    Navigator.pop(context);
  }
}
