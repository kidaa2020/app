import '../constants/app_constants.dart';

class XpCalculator {
  XpCalculator._();

  /// Get the pet level for a given XP amount
  static int getLevelForXp(int xp) {
    int level = 1;
    for (final entry in AppConstants.petLevelThresholds.entries) {
      if (xp >= entry.value) {
        level = entry.key;
      }
    }
    return level;
  }

  /// Get the XP needed for the next level
  static int xpForNextLevel(int currentXp) {
    final currentLevel = getLevelForXp(currentXp);
    if (currentLevel >= 5) return 0; // Max level
    return AppConstants.petLevelThresholds[currentLevel + 1]! - currentXp;
  }

  /// Get progress towards next level (0.0 to 1.0)
  static double progressToNextLevel(int currentXp) {
    final currentLevel = getLevelForXp(currentXp);
    if (currentLevel >= 5) return 1.0;

    final currentLevelXp = AppConstants.petLevelThresholds[currentLevel]!;
    final nextLevelXp = AppConstants.petLevelThresholds[currentLevel + 1]!;
    final range = nextLevelXp - currentLevelXp;
    final progress = currentXp - currentLevelXp;

    return progress / range;
  }

  /// Get the level name
  static String getLevelName(int level) {
    if (level < 1 || level > 5) return 'Desconocido';
    return AppConstants.petLevelNames[level - 1];
  }
}
