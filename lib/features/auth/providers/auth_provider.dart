import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tahfidz_core/features/auth/services/auth_service.dart';

part 'auth_provider.g.dart';

// State Class
class AuthState {
  final User? user;
  final Map<String, dynamic>? profile;
  final bool isLoading;
  final String? errorMessage;

  AuthState({
    this.user,
    this.profile,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isAuthenticated => user != null;
  String get userRole => profile?['role'] ?? 'guru';
}

@riverpod
class Auth extends _$Auth {
  @override
  AuthState build() {
    final service = ref.watch(authServiceProvider);
    return AuthState(user: service.currentUser);
  }

  Future<void> login(String identity, String password) async {
    state = AuthState(isLoading: true);

    try {
      final service = ref.read(authServiceProvider);

      // 1. Panggil fungsi signIn (Hybrid: Email atau No HP)
      final response = await service.signIn(identity, password);

      // 2. Ambil Profile (Role) dari tabel public.profiles
      Map<String, dynamic>? profile;
      if (response.user != null) {
        profile = await service.getUserProfile(response.user!.id);
      }

      state = AuthState(
        user: response.user,
        profile: profile,
        isLoading: false,
      );
    } catch (e) {
      state = AuthState(
          isLoading: false,
          errorMessage: e.toString().replaceAll('AuthException:', '').trim()
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    state = AuthState(isLoading: true);
    await ref.read(authServiceProvider).signOut();
    state = AuthState();
  }
}