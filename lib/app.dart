import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tahfidz_core/core/theme/app_theme.dart';
import 'package:tahfidz_core/routes/app_routes.dart';

class TahfidzCoreApp extends ConsumerWidget {
  const TahfidzCoreApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Memanggil routerProvider yang dihasilkan oleh generator di app_routes.dart
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Tahfidz Core',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}