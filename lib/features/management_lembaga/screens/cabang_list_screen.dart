import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/app_context_provider.dart';
import '../models/cabang_model.dart';

class CabangListScreen extends ConsumerStatefulWidget {
  const CabangListScreen({super.key});

  @override
  ConsumerState<CabangListScreen> createState() => _CabangListScreenState();
}

class _CabangListScreenState extends ConsumerState<CabangListScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<CabangModel> _branches = [];

  @override
  void initState() {
    super.initState();
    _fetchBranches();
  }

  Future<void> _fetchBranches() async {
    final lembagaId = ref.read(appContextProvider).lembaga?.id;
    if (lembagaId == null) return;

    try {
      final data = await _supabase
          .from('cabang')
          .select()
          .eq('lembaga_id', lembagaId)
          .order('nama_cabang');

      if (mounted) {
        setState(() {
          _branches = (data as List).map((e) => CabangModel.fromJson(e)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal mengambil data: $e")),
        );
      }
    }
  }

  void _showAddBranchDialog() {
    final nameController = TextEditingController();
    final kodeController = TextEditingController();
    final addressController = TextEditingController();
    final waController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tambah Cabang Baru", style: TextStyle(fontWeight: FontWeight.bold)),
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
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: waController,
                  decoration: const InputDecoration(labelText: "WhatsApp Cabang", hintText: "0812..."),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: "Alamat", hintText: "Alamat lengkap cabang"),
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

              final lembagaId = ref.read(appContextProvider).lembaga?.id;
              try {
                await _supabase.from('cabang').insert({
                  'lembaga_id': lembagaId,
                  'nama_cabang': nameController.text.trim(),
                  'kode_cabang': kodeController.text.trim().toUpperCase(),
                  'alamat': addressController.text.trim(),
                  'wa_cabang': waController.text.trim(),
                  'status': 'aktif',
                });

                if (mounted) {
                  Navigator.pop(context);
                  _fetchBranches(); // Refresh list setelah simpan
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Cabang berhasil ditambahkan!")),
                  );
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
          : _branches.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: _branches.length,
        itemBuilder: (context, index) {
          final cabang = _branches[index];
          return _buildCabangCard(cabang);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddBranchDialog,
        backgroundColor: const Color(0xFF10B981),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Tambah Cabang", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildCabangCard(CabangModel cabang) {
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
                        ? const Color(0xFF10B981).withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
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
                  onPressed: () {
                    // Edit Cabang
                  },
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
          const Text("Belum ada cabang terdaftar",
              style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}