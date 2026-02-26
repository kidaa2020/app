import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthbuddy/data/repositories/pet_repository.dart';
import 'package:healthbuddy/data/repositories/user_repository.dart';
import 'package:healthbuddy/data/models/pet.dart';
import 'package:healthbuddy/core/constants/app_constants.dart';

final petRepositoryProvider = Provider<PetRepository>((ref) {
  return PetRepository();
});

final petProvider = StateNotifierProvider<PetNotifier, Pet?>((ref) {
  return PetNotifier(ref.read(petRepositoryProvider), UserRepository());
});

final encouragementProvider = Provider<String>((ref) {
  final random = Random();
  return AppConstants
      .encouragementMessages[random.nextInt(AppConstants.encouragementMessages.length)];
});

class PetNotifier extends StateNotifier<Pet?> {
  final PetRepository _repository;
  final UserRepository _userRepo;

  PetNotifier(this._repository, this._userRepo) : super(null) {
    _load();
  }

  void _load() {
    state = _repository.getPet();
  }

  void refresh() {
    _load();
  }

  Future<void> createPet(Pet pet) async {
    await _repository.savePet(pet);
    _load();
  }

  Future<void> addXp(int amount) async {
    await _repository.addXp(amount);
    _load();
  }

  Future<bool> feedPet() async {
    final canAfford = await _userRepo.spendCoins(AppConstants.feedPetCost);
    if (canAfford) {
      await _repository.feedPet();
      _load();
      return true;
    }
    return false;
  }

  bool hasPet() => _repository.hasPet();
}
