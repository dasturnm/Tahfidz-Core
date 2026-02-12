import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/program_model.dart';
import '../screens/program_detail_screen.dart';
import '../providers/agenda_provider.dart';
import '../services/effective_day_service.dart';

class ProgramCard extends ConsumerWidget {
  final ProgramModel program;
  final VoidCallback? onTap;

  const ProgramCard({super.key, required this.program, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // --- LOGIKA HITUNG HARI EFEKTIF (Dummy Semester 180 Hari) ---
    final now = DateTime.now();
    final dummyEnd = now.add(const Duration(days: 180));
    final agendaAsync = ref.watch(agendaNotifierProvider);
    int effectiveDays = 0;

    agendaAsync.whenData((agendas) {
      effectiveDays = EffectiveDayService.calculateEffectiveDays(
        startDate: now,
        endDate: dummyEnd,
        hariAktifProgram: program.hariAktif,
        allAgendas: agendas,
        targetProgramId: program.id,
      );
    });

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, effectiveDays),
          const SizedBox(height: 12),
          Text(
            program.deskripsi ?? '',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildInvestasiSection()),
              const SizedBox(width: 16),
              Expanded(child: _buildJadwalSection()),
            ],
          ),
          const Spacer(), // Dorong footer ke paling bawah
          _buildFooterAction(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int effectiveDays) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.auto_stories_outlined, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(program.namaProgram, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              if (program.tagKurikulum != null)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text(program.tagKurikulum!.toUpperCase(), style: const TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  const Icon(Icons.flash_on, size: 14, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text("$effectiveDays HARI EFEKTIF", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.edit_outlined, color: Colors.grey, size: 20),
            const SizedBox(width: 4),
            InkWell(
              onTap: () => _showDeleteConfirmation(context),
              child: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
            ),
          ],
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Program?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Anda yakin ingin menghapus program '${program.namaProgram}'? Data yang sudah dihapus tidak dapat dikembalikan."),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, elevation: 0),
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestasiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("INVESTASI", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
        const SizedBox(height: 12),
        _buildPriceRow("Pendaftaran", program.biayaPendaftaran),
        _buildPriceRow("SPP / Bulan", program.biayaSpp),
      ],
    );
  }

  Widget _buildPriceRow(String label, double price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          Text("Rp ${price.toInt()}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
        ],
      ),
    );
  }

  Widget _buildJadwalSection() {
    final listHari = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];
    final mappingHari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("TEMPLATE JADWAL", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: List.generate(listHari.length, (i) {
            bool isActive = program.hariAktif.contains(mappingHari[i]);
            return Container(
              width: 28, height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF10B981) : Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(listHari[i], style: TextStyle(color: isActive ? Colors.white : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFooterAction(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProgramDetailScreen(program: program),
          ),
        );
      },
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text("Detail Program", style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 13)),
          SizedBox(width: 4),
          Icon(Icons.arrow_forward, color: Color(0xFF10B981), size: 16),
        ],
      ),
    );
  }
}