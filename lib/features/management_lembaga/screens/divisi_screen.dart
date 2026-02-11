import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/app_context_provider.dart';
import '../models/divisi_model.dart';

class DivisiListScreen extends ConsumerStatefulWidget {
  const DivisiListScreen({super.key});

  @override
  ConsumerState<DivisiListScreen> createState() => _DivisiListScreenState();
}

class _DivisiListScreenState extends ConsumerState<DivisiListScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<DivisiModel> _divisiList = [];

  @override
  void initState() {
    super.initState();
    _fetchDivisi();
  }

  Future<void> _fetchDivisi() async {
    final lembagaId = ref.read(appContextProvider).lembaga?.id;
    if (lembagaId == null) return;

    try {
      final data = await _supabase
          .from('divisi')
          .select()
          .eq('lembaga_id', lembagaId)
          .order('nama_divisi');

      if (mounted) {
        setState(() {
          _divisiList = (data as List).map((e) => DivisiModel.fromJson(e)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddDivisiDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tambah Divisi Baru", style: TextStyle(fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Nama Divisi",
                  hintText: "cth: Akademik, Tahfidz, SDM",
                ),
                validator: (val) => val!.isEmpty ? "Nama divisi wajib diisi" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: "Deskripsi",
                  hintText: "Jelaskan fungsi divisi ini",
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              final lembagaId = ref.read(appContextProvider).lembaga?.id;
              try {
                await _supabase.from('divisi').insert({
                  'lembaga_id': lembagaId,
                  'nama_divisi': nameController.text.trim(),
                  'deskripsi': descController.text.trim(),
                  'status': 'aktif',
                });

                if (mounted) {
                  Navigator.pop(context);
                  _fetchDivisi();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Gagal menyimpan: $e")),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            child: const Text("Simpan", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _divisiList.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: _divisiList.length,
        itemBuilder: (context, index) {
          final d = _divisiList[index];
          return _buildDivisiCard(d);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDivisiDialog,
        backgroundColor: const Color(0xFF10B981),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Tambah Divisi", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildDivisiCard(DivisiModel d) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.account_tree_outlined, color: Color(0xFF10B981)),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                d.namaDivisi,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            _buildStatusChip(d.status ?? 'aktif'),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            d.deskripsi ?? "Tidak ada deskripsi",
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ),
        trailing: const Icon(Icons.more_vert, color: Colors.grey),
        onTap: () {
          // Aksi untuk mengelola staff di divisi ini nanti
        },
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final bool isActive = status == 'aktif';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF10B981).withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? "AKTIF" : "NONAKTIF",
        style: TextStyle(
          color: isActive ? const Color(0xFF10B981) : Colors.grey,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_tree_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("Belum ada divisi terdaftar",
              style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}