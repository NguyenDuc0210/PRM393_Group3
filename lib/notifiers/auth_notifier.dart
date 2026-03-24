
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';
import '../models/user_role.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());

class AuthNotifier extends StateNotifier<UserRole> {
  final AuthRepository _authRepo;

  AuthNotifier(this._authRepo) : super(UserRole.guest) {
    // Gọi refreshRole nhưng không await trong constructor để tránh block UI
    refreshRole();
  }

  Future<void> refreshRole() async {
    try {
      final role = await _authRepo.getUserRole();
      state = role;
    } catch (e) {
      state = UserRole.guest;
    }
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, UserRole>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
