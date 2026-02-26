import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthbuddy/data/repositories/food_repository.dart';
import 'package:healthbuddy/data/models/food_entry.dart';
import 'package:healthbuddy/data/models/meal_type.dart';

final foodRepositoryProvider = Provider<FoodRepository>((ref) {
  return FoodRepository();
});

final todayEntriesProvider = StateNotifierProvider<TodayEntriesNotifier, List<FoodEntry>>((ref) {
  return TodayEntriesNotifier(ref.read(foodRepositoryProvider));
});

final dailyTotalsProvider = Provider<Map<String, double>>((ref) {
  ref.watch(todayEntriesProvider);
  return ref.read(foodRepositoryProvider).getDailyTotals(DateTime.now());
});

class TodayEntriesNotifier extends StateNotifier<List<FoodEntry>> {
  final FoodRepository _repository;

  TodayEntriesNotifier(this._repository)
      : super(_repository.getEntriesForDate(DateTime.now()));

  void refresh() {
    state = _repository.getEntriesForDate(DateTime.now());
  }

  Future<void> addEntry(FoodEntry entry) async {
    await _repository.addEntry(entry);
    refresh();
  }

  Future<void> deleteEntry(String id) async {
    await _repository.deleteEntry(id);
    refresh();
  }

  List<FoodEntry> getByMealType(MealType type) {
    return state.where((e) => e.mealType == type).toList();
  }
}
