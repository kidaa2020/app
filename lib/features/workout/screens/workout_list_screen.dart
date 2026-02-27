import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthbuddy/features/workout/providers/workout_provider.dart';
import 'package:healthbuddy/core/theme/app_colors.dart';
import 'package:healthbuddy/core/theme/app_text_styles.dart';
import 'package:healthbuddy/data/models/routine.dart';
import 'package:healthbuddy/features/workout/screens/routine_editor_screen.dart';
import 'package:healthbuddy/features/workout/screens/active_workout_screen.dart';

class WorkoutListScreen extends ConsumerWidget {
  const WorkoutListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routines = ref.watch(routinesProvider);
    final streak = ref.watch(streakProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.background,
            title: Text('Entreno', style: AppTextStyles.h1),
            toolbarHeight: 64,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$streak días de racha',
                          style: AppTextStyles.bodyBold.copyWith(color: AppColors.darkText),
                        ),
                        Text(
                          streak >= 3
                              ? '¡Bonus de XP activo!'
                              : 'Entrena ${3 - streak} días más para bonus',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.mintGreen.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Mis rutinas', style: AppTextStyles.h3),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          if (routines.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      const Text('🏋️', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 12),
                      Text('Crea tu primera rutina', style: AppTextStyles.subtitle),
                      Text('Toca + para comenzar', style: AppTextStyles.caption),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final routine = routines[index];
                  return _buildRoutineCard(context, ref, routine);
                },
                childCount: routines.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const RoutineEditorScreen()));
        },
        backgroundColor: AppColors.mintGreen,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRoutineCard(BuildContext context, WidgetRef ref, Routine routine) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.darkText.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.fitness_center, color: AppColors.skyBlueDark, size: 24),
        ),
        title: Text(routine.name, style: AppTextStyles.bodyBold),
        subtitle: Text('${routine.exercises.length} ejercicios', style: AppTextStyles.caption),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.subtleText, size: 20),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => RoutineEditorScreen(routine: routine)));
              },
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ActiveWorkoutScreen(routine: routine)));
              },
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
              child: const Text('Iniciar'),
            ),
          ],
        ),
      ),
    );
  }
}
