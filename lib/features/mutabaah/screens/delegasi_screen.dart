// Lokasi: lib/features/mutabaah/screens/delegasi_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tahfidz_core/core/providers/app_context_provider.dart';
import '../models/delegasi_model.dart';
import '../providers/delegasi_provider.dart';

class DelegasiScreen extends ConsumerStatefulWidget {
  const DelegasiScreen({super.key});

  @override
  ConsumerState<DelegasiScreen> createState() => _DelegasiScreenState();
}

class _DelegasiScreenState extends ConsumerState<DelegasiScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Color emerald = const Color(0xFF10B981);
  final Color slate = const Color(0xFF1E293B);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddDelegasiModal() {
    // Controller untuk form (Di dunia nyata, gunakan Dropdown daftar guru & kelas)
    final kelasController = TextEditingController();
    final guruPenggantiController = TextEditingController();
    final catatanController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
            builder: (context, setModalState) {
              return Container(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 24, left: 24, right: 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Minta Bantuan Mengajar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: slate)),
                          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // FORM INPUT
                      _buildFormLabel("Pilih Kelas Anda"),
                      TextField(
                        controller: kelasController,
                        decoration: _inputDeco("ID Kelas (Contoh: Kelas 7A)"),
                      ),
                      const SizedBox(height: 16),

                      _buildFormLabel("Pilih Guru Pengganti"),
                      TextField(
                        controller: guruPenggantiController,
                        decoration: _inputDeco("ID Guru Pengganti"),
                      ),
                      const SizedBox(height: 16),

                      _buildFormLabel("Tanggal Izin"),
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 30)),
                          );
                          if (date != null) setModalState(() => selectedDate = date);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(DateFormat('dd MMMM yyyy', 'id_ID').format(selectedDate), style: const TextStyle(fontSize: 14)),
                              const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildFormLabel("Catatan / Amanah Tambahan"),
                      TextField(
                        controller: catatanController,
                        maxLines: 2,
                        decoration: _inputDeco("Contoh: Tolong fokus ke Murojaah anak-anak..."),
                      ),
                      const SizedBox(height: 24),

                      // SUBMIT BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: emerald,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            if (kelasController.text.isEmpty || guruPenggantiController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Harap isi kelas dan guru pengganti!")));
                              return;
                            }

                            final myId = ref.read(appContextProvider).profile?.id ?? '';
                            final lembagaId = ref.read(appContextProvider).lembaga?.id ?? '';

                            final newDelegasi = DelegasiModel(
                              lembagaId: lembagaId,
                              pemberiIzinId: myId,
                              penerimaIzinId: guruPenggantiController.text.trim(),
                              kelasId: kelasController.text.trim(),
                              tanggalIzin: selectedDate,
                              catatan: catatanController.text,
                              createdAt: DateTime.now(),
                            );

                            Navigator.pop(context); // Tutup modal
                            await ref.read(delegasiActionProvider.notifier).createDelegasi(newDelegasi);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Permintaan delegasi berhasil dikirim!"), backgroundColor: Color(0xFF10B981)));
                          },
                          child: const Text("KIRIM PERMINTAAN", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              );
            }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text("Bantuan Mengajar", style: TextStyle(fontWeight: FontWeight.bold, color: slate)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: slate),
        bottom: TabBar(
          controller: _tabController,
          labelColor: emerald,
          unselectedLabelColor: Colors.grey,
          indicatorColor: emerald,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.move_to_inbox), text: "Tugas Pengganti"),
            Tab(icon: Icon(Icons.outbox), text: "Permintaan Saya"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildIncomingTab(),
          _buildOutgoingTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDelegasiModal,
        backgroundColor: slate,
        icon: const Icon(Icons.add_moderator, color: Colors.white),
        label: const Text("Minta Bantuan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // --- TAB 1: INCOMING (Tugas yang diamanahkan kepada saya) ---
  Widget _buildIncomingTab() {
    final incomingAsync = ref.watch(incomingDelegationsProvider);

    return incomingAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text("Terjadi kesalahan: $e")),
      data: (delegations) {
        if (delegations.isEmpty) {
          return _buildEmptyState("Tidak ada tugas pengganti hari ini.", Icons.coffee);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: delegations.length,
          itemBuilder: (context, index) {
            final data = delegations[index];
            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey[200]!)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: emerald.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text("HARI INI", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: emerald)),
                        ),
                        Text(DateFormat('dd MMM yyyy').format(data.tanggalIzin), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text("Menggantikan Kelas: ${data.kelasId}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: slate)),
                    const SizedBox(height: 4),
                    Text("Amanah dari: ${data.pemberiIzinId}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    if (data.catatan != null && data.catatan!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.amber[50], borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline, size: 16, color: Colors.amber),
                            const SizedBox(width: 8),
                            Expanded(child: Text(data.catatan!, style: TextStyle(fontSize: 11, color: Colors.amber[900]))),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: emerald,
                          side: BorderSide(color: emerald),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          // TODO: Navigasi ke Layar Daftar Siswa kelas ini
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Membuka Kelas ${data.kelasId}...")));
                        },
                        child: const Text("MULAI MUTABAAH"),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- TAB 2: OUTGOING (Permintaan saya ke orang lain) ---
  Widget _buildOutgoingTab() {
    final outgoingAsync = ref.watch(outgoingDelegationsProvider);

    return outgoingAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text("Terjadi kesalahan: $e")),
      data: (delegations) {
        if (delegations.isEmpty) {
          return _buildEmptyState("Belum ada riwayat permintaan delegasi.", Icons.history);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: delegations.length,
          itemBuilder: (context, index) {
            final data = delegations[index];
            final bool isPast = data.tanggalIzin.isBefore(DateTime.now().subtract(const Duration(days: 1)));
            final bool canRevoke = data.isActive && !isPast;

            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey[200]!)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text("Kelas: ${data.kelasId}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: slate)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text("Pengganti: ${data.penerimaIzinId}", style: const TextStyle(fontSize: 12)),
                    Text(DateFormat('dd MMM yyyy').format(data.tanggalIzin), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: data.isActive ? Colors.blue[50] : Colors.red[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        data.isActive ? "AKTIF" : "DIBATALKAN",
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: data.isActive ? Colors.blue : Colors.red),
                      ),
                    ),
                  ],
                ),
                trailing: canRevoke
                    ? IconButton(
                  icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                  tooltip: "Batalkan Delegasi",
                  onPressed: () async {
                    await ref.read(delegasiActionProvider.notifier).revokeDelegasi(data.id!);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Delegasi berhasil dibatalkan")));
                  },
                )
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  // --- HELPERS ---
  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildFormLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}