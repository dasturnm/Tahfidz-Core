// Lokasi: lib/features/keuangan/screens/teacher_payroll_dashboard.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/app_context_provider.dart';
import '../providers/keuangan_provider.dart'; // FIX: Menambahkan import provider

class TeacherPayrollDashboard extends ConsumerStatefulWidget {
  const TeacherPayrollDashboard({super.key});

  @override
  ConsumerState<TeacherPayrollDashboard> createState() => _TeacherPayrollDashboardState();
}

class _TeacherPayrollDashboardState extends ConsumerState<TeacherPayrollDashboard> {
  final DateTime _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(appContextProvider).profile;
    if (profile == null) return const Scaffold(body: Center(child: Text("Profil tidak ditemukan")));

    final payrollAsync = ref.watch(monthlyPayrollProvider(
      guruId: profile.id,
      month: _selectedMonth,
    ));

    const Color emerald = Color(0xFF10B981);
    const Color slate = Color(0xFF1E293B);
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Slip Gaji Digital", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: slate,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () => _selectMonth(context),
          ),
        ],
      ),
      body: payrollAsync.when(
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMonthHeader(_selectedMonth),
              const SizedBox(height: 24),

              // TOTAL ESTIMASI CARD
              _buildTotalCard(data['grand_total'], currencyFormat, emerald),

              const SizedBox(height: 32),
              _buildSectionTitle("RINCIAN PENDAPATAN"),

              _buildDetailItem(
                label: "Gaji Pokok",
                value: data['base_salary'],
                icon: Icons.account_balance_wallet_outlined,
                format: currencyFormat,
              ),
              _buildDetailItem(
                label: "Bonus Bimbingan Reguler",
                subLabel: "${data['count_reguler_students']} Santri ditangani",
                value: data['bonus_reguler'],
                icon: Icons.people_outline,
                format: currencyFormat,
              ),
              _buildDetailItem(
                label: "Bonus Guru Pengganti (Delegasi)",
                subLabel: "Kontribusi di kelas lain",
                value: data['bonus_delegasi'],
                icon: Icons.assignment_ind_outlined, // FIX: Typo nama icon (lowercase)
                format: currencyFormat,
                isBonus: true,
              ),

              if (data['potongan'] > 0) ...[
                const SizedBox(height: 16),
                _buildSectionTitle("POTONGAN"),
                _buildDetailItem(
                  label: "Potongan Delegasi Keluar",
                  subLabel: "Kelas Anda diisi guru lain",
                  value: data['potongan'],
                  icon: Icons.money_off_rounded,
                  format: currencyFormat,
                  isDeduction: true,
                ),
              ],

              const SizedBox(height: 40),
              _buildInfoNote(),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error memuat data: $err")),
      ),
    );
  }

  Widget _buildMonthHeader(DateTime date) {
    return Row(
      children: [
        const Icon(Icons.date_range, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          DateFormat('MMMM yyyy', 'id_ID').format(date).toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.grey, letterSpacing: 1.2),
        ),
      ],
    );
  }

  Widget _buildTotalCard(double total, NumberFormat format, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10)), // FIX: Deprecated withOpacity
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Estimasi Gaji Diterima", style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          Text(
            format.format(total),
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
            child: const Text("Status: Draft Otomatis", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required String label,
    String? subLabel,
    required double value,
    required IconData icon,
    required NumberFormat format,
    bool isBonus = false,
    bool isDeduction = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDeduction ? Colors.red.withValues(alpha: 0.05) : const Color(0xFFF8FAFC), // FIX: Deprecated withOpacity
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: isDeduction ? Colors.red : (isBonus ? Colors.blue : const Color(0xFF1E293B))), // FIX: slate undefined, gunakan hex
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                if (subLabel != null) Text(subLabel, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Text(
            "${isDeduction ? '-' : ''}${format.format(value)}",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 14,
              color: isDeduction ? Colors.red : (isBonus ? Colors.blue : const Color(0xFF1E293B)), // FIX: slate undefined, gunakan hex
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 16),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.grey, letterSpacing: 1.1)),
    );
  }

  Widget _buildInfoNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05), // FIX: Deprecated withOpacity
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.1)), // FIX: Deprecated withOpacity
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: Colors.blue),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Nominal ini adalah estimasi sementara berdasarkan input mutabaah Anda. Angka final ditentukan saat penutupan buku oleh Admin.",
              style: TextStyle(fontSize: 11, color: Colors.blue, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectMonth(BuildContext context) async {
    // Logika pemilihan bulan (Bisa menggunakan package month_picker_dialog atau custom)
    // Sederhananya, kita bisa menampilkan dialog pilihan bulan di sini.
  }
}