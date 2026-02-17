import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_context_provider.dart';
import '../providers/lembaga_provider.dart'; // Ditambahkan: Import provider baru
import '../models/cabang_model.dart';

class CabangListScreen extends ConsumerStatefulWidget {
  const CabangListScreen({super.key});

  @override
  ConsumerState<CabangListScreen> createState() => _CabangListScreenState();
}

class _CabangListScreenState extends ConsumerState<CabangListScreen> {
  // FIX: Status data dikelola secara reaktif oleh CabangListProvider

  void _showCabangDialog(String lembagaId, {CabangModel? cabang}) {
    final isEdit = cabang != null;
    final nameController = TextEditingController(text: cabang?.namaCabang ?? '');
    final kodeController = TextEditingController(text: cabang?.kodeCabang ?? '');
    final kepalaCabangController = TextEditingController(text: cabang?.kepalaCabang ?? '');
    final addressController = TextEditingController(text: cabang?.alamat ?? '');
    final waController = TextEditingController(text: cabang?.waCabang ?? '');
    final emailController = TextEditingController(text: cabang?.emailCabang ?? '');
    final jamOperasionalController = TextEditingController(text: cabang?.jamOperasional ?? '');
    final catatanController = TextEditingController(text: cabang?.catatan ?? '');
    final tanggalBerdiriController = TextEditingController(text: cabang?.tanggalBerdiri ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? "Edit Detail Cabang" : "Tambah Cabang Baru", style: const TextStyle(fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Nama Cabang", hintText: "Misal: Cabang Bekasi"),
                  validator: (val) => val!.isEmpty ? "Nama wajib diisi" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: kodeController,
                  decoration: const InputDecoration(labelText: "Kode Cabang", hintText: "Misal: BKS-01"),
                  validator: (val) => val!.isEmpty ? "Kode wajib diisi" : null,
                  enabled: !isEdit, // Kode cabang biasanya tidak diubah setelah dibuat
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: kepalaCabangController,
                  decoration: const InputDecoration(labelText: "Nama Kepala Cabang", hintText: "Nama lengkap"),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: waController,
                  decoration: const InputDecoration(labelText: "WhatsApp Cabang", hintText: "0812..."),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email Cabang", hintText: "cabang@lembaga.com"),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: jamOperasionalController,
                  decoration: const InputDecoration(labelText: "Jam Operasional", hintText: "Misal: 08:00 - 16:00"),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: tanggalBerdiriController,
                  decoration: const InputDecoration(labelText: "Tanggal Berdiri", hintText: "YYYY-MM-DD"),
                  keyboardType: TextInputType.datetime,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: "Alamat", hintText: "Alamat lengkap cabang"),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: catatanController,
                  decoration: const InputDecoration(labelText: "Catatan Tambahan", hintText: "Keterangan lain..."),
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
                // UPDATE: Menggunakan CabangModel dan Provider Notifier (Mendukung Edit)
                final updatedCabang = (cabang ?? CabangModel(
                    id: '',
                    lembagaId: lembagaId,
                    namaCabang: nameController.text.trim(),
                    kodeCabang: kodeController.text.trim().toUpperCase()
                )).copyWith(
                  namaCabang: nameController.text.trim(),
                  kodeCabang: kodeController.text.trim().toUpperCase(),
                  kepalaCabang: kepalaCabangController.text.trim(),
                  alamat: addressController.text.trim(),
                  waCabang: waController.text.trim(),
                  emailCabang: emailController.text.trim(),
                  jamOperasional: jamOperasionalController.text.trim(),
                  catatan: catatanController.text.trim(),
                  tanggalBerdiri: tanggalBerdiriController.text.trim(),
                  status: cabang?.status ?? 'aktif',
                );

                await ref.read(cabangListProvider(lembagaId).notifier).saveCabang(updatedCabang);

                if (!mounted) return; // FIX: use_build_context_synchronously
                navigator.pop();

                messenger.showSnackBar(
                  SnackBar(content: Text(isEdit ? "Perubahan berhasil disimpan!" : "Cabang berhasil ditambahkan!")),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final lembaga = ref.watch(appContextProvider).lembaga;
    if (lembaga == null) return const Center(child: CircularProgressIndicator());

    // Memantau data cabang secara reaktif dari Provider
    final cabangAsync = ref.watch(cabangListProvider(lembaga.id));

    return Scaffold(
      backgroundColor: Colors.white,
      body: cabangAsync.when(
        data: (branches) => branches.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: branches.length,
          itemBuilder: (context, index) {
            final cabang = branches[index];
            return _buildCabangCard(cabang, lembaga.id);
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Gagal mengambil data: $err")),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCabangDialog(lembaga.id),
        backgroundColor: const Color(0xFF10B981),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Tambah Cabang", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildCabangCard(CabangModel cabang, String lembagaId) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cabang.namaCabang,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        "Kode: ${cabang.kodeCabang}",
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (cabang.status == 'aktif')
                        ? const Color(0xFF10B981).withValues(alpha:0.1)
                        : Colors.red.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    cabang.status?.toUpperCase() ?? 'AKTIF',
                    style: TextStyle(
                      color: (cabang.status == 'aktif') ? const Color(0xFF10B981) : Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  "Kepala: ${cabang.kepalaCabang ?? '-'}",
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    cabang.alamat ?? "Alamat belum diatur",
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  cabang.waCabang ?? "-",
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _showCabangDialog(lembagaId, cabang: cabang),
                  child: const Text("Edit Detail", style: TextStyle(color: Color(0xFF10B981))),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("Belum ada Cabang Guru & Staff terdaftar",
              style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}