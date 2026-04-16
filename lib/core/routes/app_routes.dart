// Lokasi: lib/core/routes/app_routes.dart

import 'package:flutter/material.dart'; // FIX: Agar Placeholder dikenali
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // TAMBAHKAN INI
import 'package:tahfidz_core/core/constants/app_routes.dart';
import 'package:tahfidz_core/core/layout/auth_layout.dart';
import 'package:tahfidz_core/features/auth/providers/auth_provider.dart';
import 'package:tahfidz_core/core/providers/app_context_provider.dart';
import 'package:tahfidz_core/features/management_lembaga/screens/management_hub_screen.dart'; // FIX: Hub untuk Tab
import 'package:tahfidz_core/features/akademik/screens/akademik_hub_screen.dart';

// Import Screens
import 'package:tahfidz_core/features/auth/screens/login_screen.dart';
import 'package:tahfidz_core/features/dashboard/screens/dashboard_admin_screen.dart';
import 'package:tahfidz_core/features/dashboard/screens/main_layout_screen.dart'; // MENGGUNAKAN MAIN LAYOUT
import 'package:tahfidz_core/features/mutabaah/screens/mutabaah_hub_screen.dart';
import 'package:tahfidz_core/features/mutabaah/screens/mutabaah_input_screen.dart';
import 'package:tahfidz_core/features/mutabaah/screens/mutabaah_monitoring_screen.dart';
import 'package:tahfidz_core/features/mutabaah/screens/ranking_screen.dart';
import 'package:tahfidz_core/features/siswa/screens/siswa_list_screen.dart'; // SAFE UPDATE: Perbaikan case sensitivity
import 'package:tahfidz_core/features/siswa/screens/siswa_hub_screen.dart'; // SAFE UPDATE: Hub Kelas
import 'package:tahfidz_core/features/program/screens/program_list_screen.dart'; // SAFE UPDATE: Hub Program
// FIX: Tambahkan import untuk fitur yang belum terdaftar di router
import 'package:tahfidz_core/features/guru_staff/screens/staff_hub_screen.dart';
// import 'package:tahfidz_core/features/kelas/screens/kelas_hub_screen.dart'; // REMOVED: File tidak ada
import 'package:tahfidz_core/features/mushaf/screens/mushaf_index_screen.dart';
import 'package:tahfidz_core/features/mushaf/screens/mushaf_screen.dart';
import 'package:tahfidz_core/features/siswa/models/siswa_model.dart';
import 'package:tahfidz_core/features/akademik/kurikulum/models/kurikulum_model.dart';
// FIX: Tambahkan import ModulModel
import 'package:tahfidz_core/features/keuangan/screens/keuangan_screen.dart';
import 'package:tahfidz_core/features/keuangan/screens/salary_settings_screen.dart';
import 'package:tahfidz_core/features/keuangan/widgets/teacher_payroll_dashboard.dart';

// SAFE UPDATE: Nama part harus identik dengan nama file fisik agar generator berfungsi
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
          // FIX: Daftarkan Route Staf (SDM) agar bisa diklik
          GoRoute(
            path: '/staf',
            builder: (context, state) => const StaffHubScreen(),
          ),
          // FIX: Daftarkan Route Mutabaah (Entry Point) untuk memperbaiki GoException
          GoRoute(
            path: AppRouteNames.mutabaahHub,
            builder: (context, state) => const MutabaahHubScreen(),
          ),
          GoRoute(
            path: AppRouteNames.mutabaahMonitoring,
            builder: (context, state) => const MutabaahMonitoringScreen(),
          ),
          GoRoute(
            path: AppRouteNames.mutabaahRanking,
            builder: (context, state) => const RankingScreen(),
          ),
          GoRoute(
            path: AppRouteNames.mutabaahInput,
            builder: (context, state) {
              // SAFE UPDATE: Mencegah crash jika data extra kosong
              final extra = state.extra as Map<String, dynamic>?;
              if (extra == null || extra['siswa'] == null) {
                return const Scaffold(body: Center(child: Text('Data tidak lengkap, silakan pilih siswa kembali')));
              }
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
          // FIX: Daftarkan Route Kelas di dalam Shell agar Sidebar TIDAK ganda
          GoRoute(
            path: '/kelas',
            builder: (context, state) => const SiswaHubScreen(), // SAFE UPDATE: Diarahkan ke SiswaHub sesuai struktur Hub Anda
          ),
          GoRoute(
            path: '/mushaf-index',
            builder: (context, state) => const MushafIndexScreen(),
          ),
          // Tetap di dalam Shell agar Sidebar tetap muncul saat setup profil
          GoRoute(
            path: '/setup-lembaga',
            builder: (context, state) => const ManagementHubScreen(),
          ),
          // Tambahkan rute akademik jika diperlukan untuk navigasi sidebar
          GoRoute(
            path: '/akademik/program',
            builder: (context, state) => const ProgramListScreen(),
          ),
          GoRoute(
            path: AppRouteNames.kurikulum,
            builder: (context, state) {
              // Ambil lembagaId dari context provider (v2026.03.22)
              final lembagaId = ref.read(appContextProvider).lembaga?.id ?? '';
              return AkademikHubScreen(lembagaId: lembagaId);
            },
          ),
          GoRoute(
            path: AppRouteNames.keuanganHub,
            builder: (context, state) => const KeuanganScreen(),
          ),
          GoRoute(
            path: AppRouteNames.salarySettings,
            builder: (context, state) => const SalarySettingsScreen(),
          ),
          GoRoute(
            path: AppRouteNames.teacherPayroll,
            builder: (context, state) => const TeacherPayrollDashboard(),
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