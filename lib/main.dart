import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tahfidz_core/features/auth/screens/login_screen.dart';
import 'package:tahfidz_core/features/dashboard/screens/main_layout_screen.dart';
import 'package:tahfidz_core/features/auth/providers/auth_provider.dart';
import 'package:tahfidz_core/core/providers/app_context_provider.dart';
import 'package:tahfidz_core/features/management_lembaga/screens/lembaga_profile_screen.dart';
import 'package:tahfidz_core/routes/app_routes.dart'; // TAMBAHKAN INI

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
      authFlowType: AuthFlowType.pkce,
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
        ref.read(routerProvider).push('/update-password');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch routerProvider agar mesin GoRouter tersambung ke UI
    final router = ref.watch(routerProvider);

    // Listener untuk memicu initContext saat login berhasil
    ref.listen(authProvider, (previous, next) {
      if (next.isAuthenticated && !(previous?.isAuthenticated ?? false)) {
        Future.microtask(() => ref.read(appContextProvider.notifier).initContext());
      }
    });

    return MaterialApp.router(
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      routerConfig: router, // Navigator key sekarang dikelola oleh GoRouter
      title: 'Tahfidz Core',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF10B981)),
        useMaterial3: true,
      ),
    );
  }
}