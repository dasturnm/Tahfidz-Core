import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tahfidz_core/features/auth/screens/login_screen.dart';
import 'package:tahfidz_core/features/dashboard/screens/main_layout_screen.dart';
import 'package:tahfidz_core/providers/auth_provider.dart';
import 'package:tahfidz_core/features/management_lembaga/providers/app_context_provider.dart'; // Ditambahkan
import 'package:tahfidz_core/features/management_lembaga/screens/lembaga_profile_screen.dart'; // Ditambahkan: Layar Setup

// Import halaman update password
import 'package:tahfidz_core/features/auth/screens/update_password_screen.dart';
import 'package:device_preview/device_preview.dart';

// Navigator key diperlukan untuk pindah halaman dari listener auth
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mrxtnwmyqfmfdncdvssh.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1yeHRud215cWZtZmRuY2R2c3NoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAyMTY3NjUsImV4cCI6MjA4NTc5Mjc2NX0.r_sJKRw0aGasBVgn9BlbGVQ_VAJ4I3EBUrxg_Poju-w',
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce, // Penting untuk Deep Linking / Reset Password
    ),
  );

  runApp(
    DevicePreview(
      enabled: false,
      builder: (context) => const ProviderScope(child: MyApp()),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();

    // MENDENGARKAN EVENT AUTH (Termasuk Password Recovery)
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.passwordRecovery) {
        // Jika link reset diklik, arahkan ke halaman Update Password
        // Gunakan navigatorKey karena kita berada di luar BuildContext utama
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => const UpdatePasswordScreen(), // Sudah menggunakan const
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      navigatorKey: navigatorKey, // Navigator key wajib dipasang di sini
      title: 'Tahfidz Core',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF10B981)),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  bool _hasInitialized = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final appContext = ref.watch(appContextProvider);

    // Menampilkan loading saat mengecek status auth
    if (authState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Jika sudah login, cek status lembaga
    if (authState.isAuthenticated) {
      if (!_hasInitialized) {
        _hasInitialized = true;
        // PENTING: Gunakan Future.microtask agar initContext dipicu segera
        Future.microtask(() => ref.read(appContextProvider.notifier).initContext());

        // Segera tampilkan loading agar tidak terjadi 'flicker' ke layar profil
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      if (appContext.isLoading) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      // OTOMATISASI REDIRECT: Jika belum punya lembaga, arahkan ke Setup Profil
      if (appContext.lembaga == null) {
        return const Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: LembagaProfileScreen(),
          ),
        );
      }

      // Jika sudah punya lembaga, masuk ke Dashboard
      return const MainLayoutScreen();
    }

    // Reset status inisialisasi jika user logout
    _hasInitialized = false;

    // Jika belum login, tampilkan layar Login
    return const LoginScreen();
  }
}