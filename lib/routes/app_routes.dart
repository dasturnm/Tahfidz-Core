
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // TAMBAHKAN INI
import 'package:tahfidz_core/core/constants/app_routes.dart';
import 'package:tahfidz_core/core/layout/dashboard_layout.dart';
import 'package:tahfidz_core/core/layout/auth_layout.dart';
import 'package:tahfidz_core/providers/auth_provider.dart';

// Import Screens
import 'package:tahfidz_core/features/auth/screens/login_screen.dart';
import 'package:tahfidz_core/features/dashboard/screens/dashboard_admin_screen.dart';
import 'package:tahfidz_core/features/mutabaah/screens/input_mutabaah_screen.dart';
import 'package:tahfidz_core/features/siswa/screens/siswa_list_screen.dart';

// Baris ini sangat penting untuk Riverpod Generator
part 'app_routes.g.dart';

@riverpod
GoRouter router(Ref ref) { // Ganti RouterRef jadi Ref
  // Watch authProvider untuk memantau perubahan status logi
  final authState = ref.watch(authProvider);


  return GoRouter(
    initialLocation: AppRouteNames.dashboard,

    // Logika Redirect Otomatis
    redirect: (context, state) {
      final bool isLoggingIn = state.matchedLocation == AppRouteNames.login;

      // Jika belum login dan tidak di halaman login -> tendang ke login
      if (!authState.isAuthenticated) {
        return isLoggingIn ? null : AppRouteNames.login;
      }

      // Jika sudah login tapi masih di halaman login -> masukkan ke dashboard
      if (isLoggingIn) {
        return AppRouteNames.dashboard;
      }

      return null;
    },

    routes: [
      // 1. Route Luar (Autentikasi)
      GoRoute(
        path: AppRouteNames.login,
        builder: (context, state) => const AuthLayout(child: LoginScreen()),
      ),

      // 2. ShellRoute (Membungkus halaman dengan Sidebar/DashboardLayout)
      ShellRoute(
        builder: (context, state, child) => DashboardLayout(child: child),
        routes: [
          GoRoute(
            path: AppRouteNames.dashboard,
            builder: (context, state) => const DashboardAdminScreen(),
          ),
          GoRoute(
            path: AppRouteNames.mutabaahInput,
            builder: (context, state) => const InputMutabaahScreen(),
          ),
          GoRoute(
            path: AppRouteNames.siswa,
            builder: (context, state) => const SiswaListScreen(),
          ),
          // Tambahkan route fitur lainnya di sini sesuai Sidebar
        ],
      ),
    ],
  );
}