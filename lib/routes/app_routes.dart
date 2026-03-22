import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // TAMBAHKAN INI
import 'package:tahfidz_core/core/constants/app_routes.dart';
import 'package:tahfidz_core/core/layout/auth_layout.dart';
import 'package:tahfidz_core/features/auth/providers/auth_provider.dart';
import 'package:tahfidz_core/core/providers/app_context_provider.dart';
import 'package:tahfidz_core/features/management_lembaga/screens/lembaga_profile_screen.dart';

// Import Screens
import 'package:tahfidz_core/features/auth/screens/login_screen.dart';
import 'package:tahfidz_core/features/dashboard/screens/dashboard_admin_screen.dart';
import 'package:tahfidz_core/features/dashboard/screens/main_layout_screen.dart'; // MENGGUNAKAN MAIN LAYOUT
import 'package:tahfidz_core/features/mutabaah/screens/mutabaah_input_screen.dart';
import 'package:tahfidz_core/features/siswa/screens/Siswa_list_screen.dart';
import 'package:tahfidz_core/features/mushaf/screens/mushaf_index_screen.dart';
import 'package:tahfidz_core/features/mushaf/screens/mushaf_screen.dart';
import 'package:tahfidz_core/features/siswa/models/siswa_model.dart';
import 'package:tahfidz_core/features/akademik/kurikulum/models/kurikulum_model.dart';

// Baris ini sangat penting untuk Riverpod Generator
part 'app_routes.g.dart';

@riverpod
GoRouter router(Ref ref) { // Ganti RouterRef jadi Ref
  // Watch authProvider untuk memantau perubahan status logi
  final authState = ref.watch(authProvider);
  final appContext = ref.watch(appContextProvider);


  return GoRouter(
    initialLocation: AppRouteNames.dashboard,

    // Logika Redirect Otomatis
    redirect: (context, state) {
      final bool isLoggingIn = state.matchedLocation == AppRouteNames.login;

      // 1. Jika belum login dan tidak di halaman login -> tendang ke login
      if (!authState.isAuthenticated) {
        return isLoggingIn ? null : AppRouteNames.login;
      }

      // 2. Jika sedang loading data konteks lembaga, jangan pindah dulu
      if (appContext.isLoading) return null;

      // 3. Jika sudah login tapi masih di halaman login -> masukkan ke dashboard
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

      // 2. ShellRoute (Membungkus halaman dengan Sidebar/MainLayoutScreen)
      ShellRoute(
        builder: (context, state, child) => MainLayoutScreen(child: child),
        routes: [
          GoRoute(
            path: AppRouteNames.dashboard,
            builder: (context, state) => const DashboardAdminScreen(),
          ),
          GoRoute(
            path: AppRouteNames.mutabaahInput,
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>;
              return MutabaahInputScreen(
                siswa: extra['siswa'] as SiswaModel,
                modul: extra['modul'] as ModulModel,
              );
            },
          ),
          GoRoute(
            path: AppRouteNames.siswa,
            builder: (context, state) => const SiswaListScreen(),
          ),
          GoRoute(
            path: '/mushaf-index',
            builder: (context, state) => const MushafIndexScreen(),
          ),
          // Tetap di dalam Shell agar Sidebar tetap muncul saat setup profil
          GoRoute(
            path: '/setup-lembaga',
            builder: (context, state) => const LembagaProfileScreen(),
          ),
        ],
      ),

      // 3. Route Full Screen (Tanpa Sidebar - Contoh: Mode baca Mushaf)
      GoRoute(
        path: '/mushaf',
        builder: (context, state) => const MushafScreen(),
      ),
    ],
  );
}