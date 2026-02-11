import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/app_context_provider.dart';
import '../models/tahun_ajaran_model.dart';

class TahunAjaranScreen extends ConsumerStatefulWidget {
  const TahunAjaranScreen({super.key});

  @override
  ConsumerState<TahunAjaranScreen> createState() => _TahunAjaranScreenState();
}

class _TahunAjaranScreenState extends ConsumerState<TahunAjaranScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<TahunAjaranModel> _tahunAjaranList = [];

  @override
  void initState() {
    super.initState();
    _fetchTahunAjaran();
  }

  Future<void> _fetchTahunAjaran() async {
    final lembagaId = ref.read(appContextProvider).lembaga?.id;
    if (lembagaId == null) return;

    try {
      final data = await _supabase
          .from('tahun_ajaran')
          .select()
          .eq('lembaga_id', lembagaId)
          .order('label_tahun', ascending: false);

      final currentActiveId = ref.read(appContextProvider).lembaga?.tahunAjaranAktifId;

      if (mounted) {
        setState(() {
          _tahunAjaranList = (data as List).map((e) {
            return TahunAjaranModel(
              id: e['id'],
              lembagaId: e['lembaga_id'],
              labelTahun: e['label_tahun'],
              semester: e['semester'],
              isAktif: e['id'] == currentActiveId,
            );
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _setActiveYear(String taId) async {
    final lembagaId = ref.read(appContextProvider).lembaga?.id;
    try {
      // 1. Update di Database
      await _supabase
          .from('lembaga')
          .update({'tahun_ajaran_aktif_id': taId})
          .eq('id', lembagaId!);

      // 2. Refresh Context Global agar seluruh App tahu tahun sudah berubah
      await ref.read(appContextProvider.notifier).initContext();

      // 3. Refresh UI Lokal
      _fetchTahunAjaran();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tahun ajaran aktif berhasil diperbarui!")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memperbarui: $e")),
      );
    }
  }

  void _showAddTADialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tambah Tahun Ajaran"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Contoh: 2025/2026",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isEmpty) return;
              final lembagaId = ref.read(appContextProvider).lembaga?.id;
              await _supabase.from('tahun_ajaran').insert({
                'lembaga_id': lembagaId,
                'label_tahun': controller.text.trim(),
                'semester': 'Ganjil',
              });
              if (!mounted) return;
              Navigator.pop(context);
              _fetchTahunAjaran();
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tahun Ajaran")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _tahunAjaranList.length,
        itemBuilder: (context, index) {
          final ta = _tahunAjaranList[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: ta.isAktif ? const Color(0xFF10B981) : Colors.grey.shade200,
                width: ta.isAktif ? 2 : 1,
              ),
            ),
            child: ListTile(
              title: Text(ta.labelTahun, style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: ta.isAktif
                  ? const Chip(
                label: Text("AKTIF", style: TextStyle(color: Colors.white, fontSize: 10)),
                backgroundColor: Color(0xFF10B981),
              )
                  : TextButton(
                onPressed: () => _setActiveYear(ta.id),
                child: const Text("Set Aktif"),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTADialog,
        backgroundColor: const Color(0xFF10B981),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}