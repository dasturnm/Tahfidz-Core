import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/guru_provider.dart';
import 'guru_form_screen.dart';

class GuruListScreen extends ConsumerWidget {
  const GuruListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Memantau data guru dari provider
    final guruAsync = ref.watch(guruListProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Guru & Staff"),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: guruAsync.when(
        data: (listGuru) => listGuru.isEmpty
            ? const Center(child: Text("Belum ada data Guru & Staff"))
            : RefreshIndicator(
          onRefresh: () => ref.refresh(guruListProvider.future),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: listGuru.length,
            itemBuilder: (context, index) {
              final guru = listGuru[index];
              final bool isAktif = guru.isActive;

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: isAktif
                        ? const Color(0xFF10B981).withValues(alpha:0.1)
                        : Colors.grey[200],
                    child: Icon(
                        Icons.person,
                        color: isAktif ? const Color(0xFF10B981) : Colors.grey
                    ),
                  ),
                  title: Text(
                      guru.nama,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guru.kontak ?? '-',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      // Tampilkan Penugasan (Jabatan & Cabang)
                      if (guru.toJson()['namaCabang'] != null)
                        Text(
                          "${guru.toJson()['namaJabatan'] ?? ''} @ ${guru.toJson()['namaCabang']}",
                          style: const TextStyle(color: Colors.blueGrey, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      // Tampilkan Divisi jika tersedia di model guru
                      // Ini menghubungkan Master Data Divisi yang kita buat tadi
                      if (guru.toJson()['nama_divisi'] != null)
                        Text(
                          guru.toJson()['nama_divisi'].toString(),
                          style: const TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                    ],
                  ),
                  trailing: Switch(
                    value: isAktif,
                    activeThumbColor: const Color(0xFF10B981),
                    activeTrackColor: const Color(0xFF10B981).withValues(alpha:0.3),
                    onChanged: (val) {
                      if (guru.id != null) {
                        // FIX: Menggunakan 'val' (nilai baru) bukan 'isAktif' (nilai lama)
                        ref.read(guruListProvider.notifier).toggleStatus(
                            guru.id!,
                            val ? 'aktif' : 'nonaktif'
                        );
                      }
                    },
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => GuruFormScreen(guru: guru.toJson()),
                    ));
                  },
                ),
              );
            },
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text("Error: $e")),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF10B981),
        elevation: 4,
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GuruFormScreen())
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}