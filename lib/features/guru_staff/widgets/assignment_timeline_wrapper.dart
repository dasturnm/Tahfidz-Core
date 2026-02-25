import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/staff_provider.dart';
import '../models/staff_model.dart';
import 'assignment_timeline.dart';

class AssignmentTimelineWrapper extends ConsumerStatefulWidget {
  const AssignmentTimelineWrapper({super.key});

  @override
  ConsumerState<AssignmentTimelineWrapper> createState() => _AssignmentTimelineWrapperState();
}

class _AssignmentTimelineWrapperState extends ConsumerState<AssignmentTimelineWrapper> {
  StaffModel? _selectedStaff;
  List<Map<String, dynamic>>? _history;
  bool _isFetching = false;

  // FUNGSI: Menampilkan modal pencarian staf (Tetap dipertahankan namun tidak lagi digunakan di build utama)
  void _showSearchStaff() {
    final allStaff = ref.read(staffListProvider).value ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => StatefulBuilder(
          builder: (context, setModalState) {
            final query = ref.watch(staffSearchProvider).toLowerCase();
            final filteredStaff = allStaff.where((s) =>
            s.nama.toLowerCase().contains(query) ||
                (s.id?.toLowerCase().contains(query) ?? false)
            ).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 24),
                  const Text("Pilih Staf untuk Riwayat", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                  const SizedBox(height: 16),
                  // Pencarian Terintegrasi
                  TextField(
                    onChanged: (v) => setModalState(() => ref.read(staffSearchProvider.notifier).updateQuery(v)),
                    decoration: InputDecoration(
                      hintText: "Cari nama atau NIP...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: filteredStaff.isEmpty
                        ? const Center(child: Text("Staf tidak ditemukan", style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                      itemCount: filteredStaff.length,
                      itemBuilder: (context, index) {
                        final s = filteredStaff[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.1),
                            child: Text(s.nama[0], style: const TextStyle(color: Color(0xFF10B981))),
                          ),
                          title: Text(s.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(s.namaJabatan ?? 'Staf'),
                          onTap: () {
                            Navigator.pop(context);
                            _loadHistory(s);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
      ),
    );
  }

  // FUNGSI: Memanggil fetchHistory dari provider
  Future<void> _loadHistory(StaffModel staff) async {
    setState(() {
      _selectedStaff = staff;
      _isFetching = true;
    });

    try {
      final data = await ref.read(staffListProvider.notifier).fetchHistory(staff.id!);
      if (mounted) {
        setState(() {
          _history = data;
          _isFetching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isFetching = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal memuat riwayat: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Ambil Query Pencarian dari Hub Utama
    final searchQuery = ref.watch(staffSearchProvider).toLowerCase();
    final staffAsync = ref.watch(staffListProvider);

    // 2. Jika staf sudah dipilih, tampilkan Timeline
    if (_selectedStaff != null) {
      return Column(
        children: [
          _buildSelectedHeader(),
          Expanded(
            child: _isFetching
                ? const Center(child: CircularProgressIndicator())
                : AssignmentTimeline(history: _history ?? []),
          ),
        ],
      );
    }

    // 3. Jika belum dipilih, tampilkan Daftar Staf yang bisa dicari langsung
    return staffAsync.when(
      data: (allStaff) {
        final filteredStaff = allStaff.where((s) =>
        s.nama.toLowerCase().contains(searchQuery) ||
            (s.id?.toLowerCase().contains(searchQuery) ?? false)
        ).toList();

        if (filteredStaff.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredStaff.length,
          itemBuilder: (context, index) {
            final s = filteredStaff[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.1),
                  child: Text(s.nama[0], style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                ),
                title: Text(s.nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text(s.namaJabatan ?? 'Staf', style: const TextStyle(fontSize: 11)),
                trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                onTap: () => _loadHistory(s),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("Error: $e")),
    );
  }

  // Fungsi Pembantu: Header saat staf terpilih
  Widget _buildSelectedHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
              backgroundColor: Colors.white24,
              child: Text(_selectedStaff!.nama[0], style: const TextStyle(color: Colors.white))
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_selectedStaff!.nama, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const Text("Menampilkan Riwayat Penugasan", style: TextStyle(color: Colors.white60, fontSize: 10)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => setState(() { _selectedStaff = null; _history = null; }),
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
          Icon(Icons.history_edu, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text(
            "Pilih staf di atas untuk melihat\njejak karier dan penugasan.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[400], fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}