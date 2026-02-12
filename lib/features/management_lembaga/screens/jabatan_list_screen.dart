import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/app_context_provider.dart';
import '../models/jabatan_model.dart';
import '../models/divisi_model.dart';

class JabatanListScreen extends ConsumerStatefulWidget {
  const JabatanListScreen({super.key});

  @override
  ConsumerState<JabatanListScreen> createState() => _JabatanListScreenState();
}

class _JabatanListScreenState extends ConsumerState<JabatanListScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<JabatanModel> _jabatanList = [];
  List<DivisiModel> _divisiList = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final lembagaId = ref.read(appContextProvider).lembaga?.id;
    if (lembagaId == null) return;

    try {
      final divisiData = await _supabase
          .from('divisi')
          .select()
          .eq('lembaga_id', lembagaId)
          .order('nama_divisi');

      final divisiIds = (divisiData as List).map((e) => e['id']).toList();

      final jabatanData = await _supabase
          .from('jabatan')
          .select()
      // FIX: Menggunakan filter 'in' karena in_ sering bermasalah pada linter
          .filter('divisi_id', 'in', divisiIds)
          .order('nama_jabatan');

      if (mounted) {
        setState(() {
          _divisiList = divisiData.map((e) => DivisiModel.fromJson(e)).toList();
          _jabatanList = (jabatanData as List).map((e) => JabatanModel.fromJson(e)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (context.mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memuat data: $e")),
        );
      }
    }
  }

  void _showAddJabatanDialog() {
    if (_divisiList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Buat divisi terlebih dahulu sebelum menambah jabatan.")),
      );
      return;
    }

    final nameController = TextEditingController();
    String? selectedDivisiId = _divisiList.first.id;
    String selectedRole = 'GURU';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Tambah Jabatan Baru", style: TextStyle(fontWeight: FontWeight.bold)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Nama Jabatan", hintText: "cth: Musyrif Tahfidz"),
                    validator: (val) => val!.isEmpty ? "Nama jabatan wajib diisi" : null,
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    // FIX: Menggunakan initialValue untuk Flutter 3.33+
                    initialValue: selectedDivisiId,
                    decoration: const InputDecoration(labelText: "Pilih Divisi"),
                    items: _divisiList.map((d) => DropdownMenuItem(
                      value: d.id,
                      child: Text(d.namaDivisi),
                    )).toList(),
                    onChanged: (val) => setDialogState(() => selectedDivisiId = val),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    // FIX: Menggunakan initialValue untuk Flutter 3.33+
                    initialValue: selectedRole,
                    decoration: const InputDecoration(labelText: "Hak Akses Default (Role)"),
                    items: const [
                      DropdownMenuItem(value: 'ADMIN_PUSAT', child: Text("Admin Pusat")),
                      DropdownMenuItem(value: 'ADMIN_CABANG', child: Text("Admin Cabang")),
                      DropdownMenuItem(value: 'GURU', child: Text("Guru / Pengajar")),
                      DropdownMenuItem(value: 'STAFF', child: Text("Staff Administrasi")),
                    ],
                    onChanged: (val) => setDialogState(() => selectedRole = val!),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                try {
                  await _supabase.from('jabatan').insert({
                    'divisi_id': selectedDivisiId,
                    'nama_jabatan': nameController.text.trim(),
                    'default_role': selectedRole,
                    'status': 'aktif',
                  });

                  if (context.mounted) {
                    Navigator.pop(context);
                    _fetchData();
                  }
                } catch (e) {
                  if (context.mounted) {
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _jabatanList.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: _jabatanList.length,
        itemBuilder: (context, index) {
          final j = _jabatanList[index];
          final namaDivisi = _divisiList.firstWhere(
                  (d) => d.id == j.divisiId,
              orElse: () => DivisiModel(id: '', lembagaId: '', namaDivisi: 'N/A')
          ).namaDivisi;

          return _buildJabatanCard(j, namaDivisi);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddJabatanDialog,
        backgroundColor: const Color(0xFF10B981),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Tambah Jabatan", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildJabatanCard(JabatanModel j, String namaDivisi) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.work_outline, color: Colors.blue),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    j.namaJabatan,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        namaDivisi,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.circle, size: 4, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        j.defaultRole,
                        style: const TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.more_vert, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work_history_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text("Belum ada jabatan terdaftar",
              style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}