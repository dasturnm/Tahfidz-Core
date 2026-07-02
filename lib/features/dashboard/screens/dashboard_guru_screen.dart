import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_context_provider.dart';
import '../../mutabaah/widgets/santri_belum_setoran_widget.dart';

class DashboardGuruScreen extends ConsumerWidget {
  const DashboardGuruScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ambil guruId dari context/auth agar dinamis
    final guruId = ref.watch(appContextProvider).profile?.id ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Guru')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (guruId.isNotEmpty)
              SantriBelumSetoranWidget(guruId: guruId),
            const Center(child: Text('Dashboard Guru Coming Soon')),
          ],
        ),
      ),
    );
  }
}