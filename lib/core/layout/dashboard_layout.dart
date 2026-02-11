import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tahfidz_core/core/layout/sidebar.dart';
import 'package:tahfidz_core/core/constants/app_colors.dart';

class DashboardLayout extends ConsumerWidget {
  final Widget child;
  const DashboardLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tahfidz Core'),
        leading: isDesktop ? const SizedBox.shrink() : null,
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      drawer: isDesktop ? null : const Sidebar(),
      body: Row(
        children: [
          if (isDesktop)
            const SizedBox(
              width: 280,
              child: Sidebar(),
            ),
          Expanded(
            child: Container(
              color: AppColors.background,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}