// Lokasi: lib/features/keuangan/screens/keuangan_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'salary_settings_screen.dart';
import '../widgets/teacher_payroll_dashboard.dart'; // FIX: Lokasi file benar di folder widgets

class KeuanganScreen extends ConsumerWidget {
  const KeuanganScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // FIX: Menggunakan Hub Menu untuk navigasi fitur keuangan yang sudah dibuat
    const Color slate = Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Manajemen Keuangan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: slate,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildMenuTile(
            context,
            title: "Pengaturan Gaji",
            subtitle: "Atur gaji pokok, bonus siswa, dan delegasi",
            icon: Icons.settings_suggest_outlined,
            color: Colors.blue,
            // FIX: Menggunakan block syntax untuk menghindari use_of_void_result
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SalarySettingsScreen()));
            },
          ),
          const SizedBox(height: 16),
          _buildMenuTile(
            context,
            title: "Slip Gaji Guru",
            subtitle: "Lihat rincian pendapatan bulanan",
            icon: Icons.payments_outlined,
            color: const Color(0xFF10B981),
            // FIX: Menggunakan block syntax untuk menghindari use_of_void_result
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const TeacherPayrollDashboard()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}