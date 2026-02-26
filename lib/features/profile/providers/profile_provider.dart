import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthbuddy/data/repositories/user_repository.dart';
import 'package:healthbuddy/data/models/user.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  return UserNotifier(ref.read(userRepositoryProvider));
});

class UserNotifier extends StateNotifier<User?> {
  final UserRepository _repository;

  UserNotifier(this._repository) : super(null) {
    _load();
  }

  void _load() {
    state = _repository.getUser();
  }

  void refresh() {
    _load();
  }

  Future<void> ensureUser({String name = 'Usuario'}) async {
    await _repository.getOrCreateUser(name: name);
    _load();
  }
}
