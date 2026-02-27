import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthbuddy/features/profile/providers/profile_provider.dart';
import 'package:healthbuddy/features/pet/providers/pet_provider.dart';
import 'package:healthbuddy/features/workout/providers/workout_provider.dart';
import 'package:healthbuddy/core/theme/app_colors.dart';
import 'package:healthbuddy/core/theme/app_text_styles.dart';
import 'package:healthbuddy/core/utils/xp_calculator.dart';


class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final pet = ref.watch(petProvider);
    final streak = ref.watch(streakProvider);
    final sessions = ref.watch(workoutSessionsProvider);

    final completedSessions = sessions.where((s) => s.completed).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Container(
                width: 80, height: 80,
                decoration: const BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
                    style: AppTextStyles.h1.copyWith(color: AppColors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(user?.name ?? 'Usuario', style: AppTextStyles.h2),
              const SizedBox(height: 4),
              Text('Desde ${_formatDate(user?.createdAt ?? DateTime.now())}', style: AppTextStyles.caption),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildStatCard('🔥', '$streak', 'Racha\n(días)', AppColors.calorieColor)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('🏋️', '${completedSessions.length}', 'Entrenos\ntotales', AppColors.skyBlueDark)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('🪙', '${user?.totalCoins ?? 0}', 'Monedas', AppColors.carbColor)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildStatCard('⭐', '${pet?.xp ?? 0}', 'XP\ntotal', AppColors.mintGreenDark)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard(pet?.type.emoji ?? '🐾', 'Nv ${pet?.level ?? 0}', XpCalculator.getLevelName(pet?.level ?? 1), AppColors.proteinColor)),
                ],
              ),
              const SizedBox(height: 24),
              Align(alignment: Alignment.centerLeft, child: Text('Entrenos recientes', style: AppTextStyles.h3)),
              const SizedBox(height: 12),
              if (completedSessions.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Aún no has completado ningún entreno', style: AppTextStyles.caption),
                )
              else
                ...completedSessions.take(5).map((session) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: AppColors.mintGreen.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.check_circle, color: AppColors.mintGreenDark, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(session.routineName, style: AppTextStyles.bodyBold),
                                Text(_formatDate(session.date), style: AppTextStyles.caption),
                              ],
                            ),
                          ),
                          Text('${session.exercises.length} ejercicios', style: AppTextStyles.caption),
                        ],
                      ),
                    )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String emoji, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.number.copyWith(color: color)),
          Text(label, style: AppTextStyles.caption, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}
