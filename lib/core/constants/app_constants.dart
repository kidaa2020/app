class AppConstants {
  AppConstants._();

  // XP System
  static const int xpPerMealLogged = 10;
  static const int xpPerWorkoutCompleted = 20;
  static const int xpDailyBonusThreshold = 3; // meals needed for bonus
  static const int xpDailyBonus = 5;
  static const int xpStreakBonus = 15; // bonus at 3-day streak
  static const int streakBonusDays = 3;

  // Coins
  static const int coinsPerWorkout = 5;
  static const int feedPetCost = 3;

  // Pet Levels
  static const Map<int, int> petLevelThresholds = {
    1: 0,
    2: 100,
    3: 300,
    4: 600,
    5: 1000,
  };

  static const List<String> petLevelNames = [
    'Bebé',
    'Joven',
    'Adulto',
    'Épico',
    'Legendario',
  ];

  // Encouragement messages
  static const List<String> encouragementMessages = [
    '¡Sigue así, campeón! 💪',
    '¡Eres imparable! 🔥',
    '¡Tu esfuerzo vale la pena! ⭐',
    '¡Juntos somos más fuertes! 🤝',
    '¡Hoy es un gran día! ☀️',
    '¡No pares, sigue adelante! 🚀',
    '¡Estoy orgulloso de ti! 🎉',
    '¡Cada paso cuenta! 🏃',
    '¡Vamos a por todas! 💥',
    '¡Tú puedes con todo! 🌟',
  ];

  // Open Food Facts
  static const String openFoodFactsBaseUrl =
      'https://world.openfoodfacts.org/api/v2/product';

  // Meal types display
  static const Map<String, String> mealTypeLabels = {
    'breakfast': 'Desayuno',
    'lunch': 'Almuerzo',
    'meal': 'Comida',
    'snack': 'Merienda',
    'dinner': 'Cena',
  };
}
