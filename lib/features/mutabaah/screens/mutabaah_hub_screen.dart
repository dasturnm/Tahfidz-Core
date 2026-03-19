// Lokasi: lib/features/mutabaah/screens/mutabaah_hub_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/mutabaah_provider.dart';
import '../models/mutabaah_model.dart';
import '../../siswa/providers/siswa_provider.dart';

class MutabaahHubScreen extends ConsumerStatefulWidget {
  const MutabaahHubScreen({super.key});

  @override
  ConsumerState<MutabaahHubScreen> createState() => _MutabaahHubScreenState();
}

class _MutabaahHubScreenState extends ConsumerState<MutabaahHubScreen> {
  final Color _emerald = const Color(0xFF10B981);
  final Color _slate = const Color(0xFF1E293B);
  String _filterType = "SEMUA"; // SEMUA, HAFALAN, AKADEMIK

  @override
  Widget build(BuildContext context) {
    final allRecordsAsync = ref.watch(mutabaahAllHistoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildStatsOverview(allRecordsAsync),
            _buildSubMenuTabs(),
            _buildFilterTabs(),
            Expanded(
              child: allRecordsAsync.when(
                data: (records) {
                  final filtered = _filterType == "SEMUA"
                      ? records
                      : records.where((r) => r.tipeModul == _filterType).toList();

                  if (filtered.isEmpty) return _buildEmptyState();

                  return RefreshIndicator(
                    onRefresh: () => ref.refresh(mutabaahAllHistoryProvider.future),
                    color: _emerald,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) => _buildActivityTile(filtered[index]),
                    ),
                  );
                },
                loading: () => Center(child: CircularProgressIndicator(color: _emerald)),
                error: (e, _) => Center(child: Text("Error: $e")),
              ),
            ),
          ],
        ),
      ),
      // PERBAIKAN: Menambahkan Floating Action Button untuk akses Form melalui Modal Selector
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSiswaSelector(context),
        backgroundColor: _slate,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Tambah Setoran", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSubMenuTabs() => const SizedBox.shrink();

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Mutabaah Siswa",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _slate, letterSpacing: -0.5),
              ),
              const SizedBox(height: 4),
              Text("Ringkasan setoran harian seluruh unit", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            ],
          ),
          _iconActionButton(Icons.calendar_month_rounded, () {}),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(AsyncValue<List<MutabaahRecord>> asyncRecords) {
    return asyncRecords.maybeWhen(
      data: (records) {
        final today = DateTime.now();
        final todayRecords = records.where((r) =>
        r.createdAt.day == today.day && r.createdAt.month == today.month).toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            children: [
              _statCard("Setoran Hari Ini", "${todayRecords.length}", Icons.bolt_rounded, Colors.orange),
              const SizedBox(width: 16),
              _statCard("Total Record", "${records.length}", Icons.fact_check_rounded, _emerald),
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: _slate),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    label,
                    style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
      child: Row(
        children: [
          _filterChip("SEMUA"),
          const SizedBox(width: 8),
          _filterChip("HAFALAN"),
          const SizedBox(width: 8),
          _filterChip("AKADEMIK"),
        ],
      ),
    );
  }

  Widget _filterChip(String type) {
    bool isActive = _filterType == type;
    return InkWell(
      onTap: () => setState(() => _filterType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? _slate : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: isActive ? _slate : const Color(0xFFE2E8F0)),
        ),
        child: Text(
          type,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF64748B),
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildActivityTile(MutabaahRecord record) {
    final timeStr = DateFormat('HH:mm').format(record.createdAt);

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
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: (record.tipeModul == 'HAFALAN' ? _emerald : Colors.blue).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              record.tipeModul == 'HAFALAN' ? Icons.menu_book_rounded : Icons.psychology_rounded,
              color: record.tipeModul == 'HAFALAN' ? _emerald : Colors.blue,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Siswa ID: ${record.siswaId.substring(0, 8)}...", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(record.tipeModul, style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(timeStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off_rounded, size: 64, color: Colors.grey[200]),
          const SizedBox(height: 16),
          const Text("Belum ada aktivitas mutabaah.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // --- FUNGSI MODAL PEMILIH SISWA ---
  void _showSiswaSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text("Pilih Siswa untuk Mutabaah", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  // PERBAIKAN: Menggunakan siswaProvider & logika state yang konsisten
                  final state = ref.watch(siswaProvider);

                  if (state.isLoading && state.siswa.isEmpty) {
                    return Center(child: CircularProgressIndicator(color: _emerald));
                  }

                  final list = state.siswa;
                  if (list.isEmpty) {
                    return const Center(child: Text("Gagal memuat daftar siswa"));
                  }

                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final s = list[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _emerald.withValues(alpha: 0.1),
                          child: Text(s.namaLengkap[0], style: TextStyle(color: _emerald, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(s.namaLengkap, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Kelas: ${s.kelas?.name ?? '-'}"), // PERBAIKAN: levelId -> kelas.name
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                        onTap: () {
                          Navigator.pop(context);
                          // Logika navigasi ke form input dengan membawa data siswa
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconActionButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48, width: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Icon(icon, size: 20, color: _slate),
      ),
    );
  }
}