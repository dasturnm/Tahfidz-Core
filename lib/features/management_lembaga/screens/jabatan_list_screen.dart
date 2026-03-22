import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_context_provider.dart';
import '../providers/lembaga_provider.dart'; // Ditambahkan: Import provider baru
import '../models/jabatan_model.dart';
import '../models/divisi_model.dart';

class JabatanListScreen extends ConsumerStatefulWidget {
  const JabatanListScreen({super.key});

  @override
  ConsumerState<JabatanListScreen> createState() => _JabatanListScreenState();
}

class _JabatanListScreenState extends ConsumerState<JabatanListScreen> {
  // FIX: _isLoading, _jabatanList, dan _divisiList dihapus karena sudah dikelola Provider

  void _showJabatanDialog(String lembagaId, {JabatanModel? jabatan}) {
    // Ambil data divisi secara sinkron dari provider
    final divisiList = ref.read(divisiListProvider(lembagaId)).value ?? [];

    if (divisiList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Buat divisi terlebih dahulu sebelum menambah jabatan.")),
      );
      return;
    }

    final isEdit = jabatan != null;
    final nameController = TextEditingController(text: jabatan?.namaJabatan ?? '');
    final levelController = TextEditingController(text: jabatan?.levelJabatan?.toString() ?? '1');
    final catatanController = TextEditingController(text: jabatan?.catatanJabatan ?? '');
    String? selectedDivisiId = jabatan?.divisiId ?? divisiList.first.id;
    String selectedRole = jabatan?.defaultRole ?? 'GURU';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? "Edit Jabatan" : "Tambah Jabatan Baru", style: const TextStyle(fontWeight: FontWeight.bold)),
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
                    initialValue: selectedDivisiId,
                    decoration: const InputDecoration(labelText: "Pilih Divisi"),
                    items: divisiList.map((d) => DropdownMenuItem(
                      value: d.id,
                      child: Text(d.namaDivisi),
                    )).toList(),
                    onChanged: (val) => setDialogState(() => selectedDivisiId = val),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
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
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: levelController,
                    decoration: const InputDecoration(labelText: "Level Jabatan (Angka)", hintText: "cth: 1 untuk Guru, 2 untuk Koordinator"),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: catatanController,
                    decoration: const InputDecoration(labelText: "Catatan Jabatan", hintText: "Tugas utama atau wewenang..."),
                    maxLines: 2,
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

                final messenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);

                try {
                  // FIX: Menambahkan lembagaId, namaJabatan dan defaultRole ke constructor JabatanModel
                  final updatedJabatan = (jabatan ?? JabatanModel(
                    id: '',
                    lembagaId: lembagaId, // Ditambahkan: Sesuai perubahan model terbaru
                    divisiId: selectedDivisiId!,
                    namaJabatan: nameController.text.trim(),
                    defaultRole: selectedRole,
                  )).copyWith(
                    divisiId: selectedDivisiId!,
                    namaJabatan: nameController.text.trim(),
                    defaultRole: selectedRole,
                    levelJabatan: int.tryParse(levelController.text),
                    catatanJabatan: catatanController.text.trim(),
                    status: jabatan?.status ?? 'aktif',
                  );

                  await ref.read(jabatanListProvider(lembagaId).notifier).saveJabatan(updatedJabatan);

                  // Refresh data agar list jabatan langsung muncul
                  ref.invalidate(jabatanListProvider(lembagaId));

                  if (!mounted) return; // FIX: use_build_context_synchronously
                  navigator.pop();

                  messenger.showSnackBar(
                    SnackBar(content: Text(isEdit ? "Jabatan berhasil diupdate!" : "Jabatan berhasil ditambahkan!")),
                  );
                } catch (e) {
                  if (!mounted) return;
                  messenger.showSnackBar(
                    SnackBar(content: Text("Gagal menyimpan: $e")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
              child: Text(isEdit ? "Update" : "Simpan", style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lembaga = ref.watch(appContextProvider).lembaga;
    if (lembaga == null) return const Center(child: CircularProgressIndicator());

    // Memantau data secara reaktif dari Provider
    final jabatanAsync = ref.watch(jabatanListProvider(lembaga.id));
    final divisiAsync = ref.watch(divisiListProvider(lembaga.id));

    return Scaffold(
      backgroundColor: Colors.white,
      body: jabatanAsync.when(
        data: (jabatanList) => divisiAsync.when(
          data: (divisiList) => jabatanList.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: jabatanList.length,
            itemBuilder: (context, index) {
              final j = jabatanList[index];
              final namaDivisi = divisiList.firstWhere(
                      (d) => d.id == j.divisiId,
                  orElse: () => DivisiModel(id: '', lembagaId: '', namaDivisi: 'N/A')
              ).namaDivisi;

              return _buildJabatanCard(j, namaDivisi);
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text("Error Divisi: $err")),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error Jabatan: $err")),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 30.0),
        child: FloatingActionButton.extended(
          onPressed: () => _showJabatanDialog(lembaga.id),
          backgroundColor: const Color(0xFF10B981),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text("Tambah Jabatan", style: TextStyle(color: Colors.white)),
        ),
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
                color: Colors.blue.withValues(alpha:0.1),
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
                  if (j.catatanJabatan != null && j.catatanJabatan!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        j.catatanJabatan!,
                        style: TextStyle(color: Colors.grey[500], fontSize: 12, fontStyle: FontStyle.italic),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              onSelected: (value) async {
                final lembagaId = ref.read(appContextProvider).lembaga!.id;
                if (value == 'detail') {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(j.namaJabatan),
                      content: Text(j.catatanJabatan ?? "Tidak ada keterangan tambahan."),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Tutup")),
                      ],
                    ),
                  );
                } else if (value == 'edit') {
                  _showJabatanDialog(lembagaId, jabatan: j);
                } else if (value == 'delete') {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Hapus Jabatan?"),
                      content: Text("Anda yakin ingin menghapus jabatan ${j.namaJabatan}?"),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Batal")),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text("Hapus", style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await ref.read(jabatanListProvider(lembagaId).notifier).deleteJabatan(j.id);
                  }
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'detail',
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Text("Detail"),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, color: Colors.grey, size: 20),
                      SizedBox(width: 8),
                      Text("Edit"),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text("Hapus", style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
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