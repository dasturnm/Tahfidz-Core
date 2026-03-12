import 'package:flutter/material.dart';
import '../models/program_model.dart';

class ProgramDetailScreen extends StatelessWidget {
  final ProgramModel program;

  const ProgramDetailScreen({super.key, required this.program});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(program.namaProgram, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Hubungkan navigasi ke form edit program
            },
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF10B981)),
          ),
          IconButton(
            onPressed: () {
              // TODO: Hubungkan fungsi hapus ke provider
            },
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMainInfoCard(),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 1, child: _buildInvestmentDetail()),
                const SizedBox(width: 32),
                Expanded(flex: 1, child: _buildScheduleDetail()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainInfoCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.auto_stories_outlined, color: Color(0xFF10B981), size: 40),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // PERBAIKAN: Mengganti tagKurikulum yang sudah dihapus dengan status program
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    program.status.toUpperCase(), // Menggunakan field status dari model
                    style: const TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                Text(program.namaProgram, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(program.deskripsi ?? "Tidak ada deskripsi", style: TextStyle(color: Colors.grey[600], fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestmentDetail() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("RINCIAN INVESTASI", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12, letterSpacing: 1)),
          const Divider(height: 32),
          _buildInfoRow(Icons.account_balance_wallet_outlined, "Biaya Pendaftaran", "Rp ${program.biayaPendaftaran.toInt()}"),
          const SizedBox(height: 20),
          _buildInfoRow(Icons.payments_outlined, "SPP Per Bulan", "Rp ${program.biayaSpp.toInt()}"),
        ],
      ),
    );
  }

  Widget _buildScheduleDetail() {
    final listHari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("JADWAL OPERASIONAL", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12, letterSpacing: 1)),
          const Divider(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: listHari.map((day) {
              bool isActive = program.hariAktif.contains(day);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF10B981) : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isActive ? const Color(0xFF10B981) : Colors.grey.shade200),
                ),
                child: Text(
                  day,
                  style: TextStyle(color: isActive ? Colors.white : Colors.grey, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF10B981), size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }
}