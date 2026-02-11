import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tahfidz_core/features/auth/screens/login_screen.dart';
import 'package:tahfidz_core/features/dashboard/screens/main_layout_screen.dart';
import 'package:tahfidz_core/providers/auth_provider.dart';

// Import halaman update password
import 'package:tahfidz_core/features/auth/screens/update_password_screen.dart';

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

  runApp(const ProviderScope(child: MyApp()));
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

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Menampilkan loading saat mengecek status auth
    if (authState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Jika sudah login, masuk ke Dashboard (Melalui MainLayout untuk Sidebar)
    if (authState.isAuthenticated) {
      return const MainLayoutScreen();
    }

    // Jika belum login, tampilkan layar Login
    return const LoginScreen();
  }
}