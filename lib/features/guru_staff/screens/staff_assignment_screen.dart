import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/staff_provider.dart';
import '../providers/penugasan_staf_provider.dart';
import 'package:tahfidz_core/features/management_lembaga/providers/app_context_provider.dart';
import 'package:tahfidz_core/features/management_lembaga/providers/lembaga_provider.dart';

class StaffAssignmentScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> staff;
  const StaffAssignmentScreen({super.key, required this.staff});

  @override
  ConsumerState<StaffAssignmentScreen> createState() => _StaffAssignmentScreenState();
}

class _StaffAssignmentScreenState extends ConsumerState<StaffAssignmentScreen> {
  String? _selectedCabangId;
  String? _selectedJabatanId;
  bool _isUtama = false;
  bool _isMutation = true; // True = Ganti Jabatan, False = Tambah Jabatan (Hybrid)

  @override
  void initState() {
    super.initState();
    // Mengambil data penugasan aktif (jika ada) sebagai nilai default untuk form
    if (widget.staff['assignments'] != null && widget.staff['assignments'].isNotEmpty) {
      final activeAssignment = (widget.staff['assignments'] as List).firstWhere(
              (a) => a['status'] == 'aktif',
          orElse: () => null
      );

      if (activeAssignment != null) {
        _selectedCabangId = activeAssignment['cabang_id']?.toString();
        _selectedJabatanId = activeAssignment['jabatan_id']?.toString();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lembagaId = ref.watch(appContextProvider).lembaga?.id ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Kelola Penugasan")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // INFO STAFF
            // FIX: Menggunakan key 'nama' sesuai mapping dari StaffModel.toJson()
            Text(widget.staff['nama'] ?? 'Tanpa Nama', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),

            // OPSI MODE
            _buildLabel("Jenis Penugasan Baru"),
            Row(
              children: [
                Expanded(child: _buildModeOption(true, "Mutasi/Promosi", "Mengganti jabatan lama")),
                const SizedBox(width: 12),
                Expanded(child: _buildModeOption(false, "Hybrid/Rangkap", "Menambah tugas baru")),
              ],
            ),
            const SizedBox(height: 24),

            _buildDropdownCabang(lembagaId),
            const SizedBox(height: 16),
            _buildDropdownJabatan(lembagaId),

            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text("Jadikan Jabatan Utama", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              subtitle: const Text("Gaji dan absensi akan merujuk ke cabang ini"),
              value: _isUtama,
              activeThumbColor: const Color(0xFF10B981),
              onChanged: (val) => setState(() => _isUtama = val),
            ),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A)),
                onPressed: _prosesSimpan,
                child: const Text("UPDATE PENUGASAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- LOGIKA SIMPAN ---
  void _prosesSimpan() async {
    if (_selectedJabatanId == null) return;

    final lembagaId = ref.read(appContextProvider).lembaga?.id ?? '';

    // 1. Jalankan proses penugasan (Mutasi/Hybrid)
    await ref.read(penugasanStafProvider.notifier).tambahPenugasan(
      stafId: widget.staff['id'],
      cabangId: _selectedCabangId,
      jabatanId: _selectedJabatanId!,
      isUtama: _isUtama,
      deactivatePrevious: _isMutation,
    );

    // 2. DETEKSI ROLE OTOMATIS: Update Role di Profile berdasarkan Jabatan baru
    final jabatans = ref.read(jabatanListProvider(lembagaId)).value ?? [];
    final selectedJabatan = jabatans.firstWhere((j) => j.id.toString() == _selectedJabatanId);

    // Jika nama jabatan mengandung kata 'guru' atau 'pengajar', set role 'guru'
    // Selain itu (Admin, Sekretaris, Bendahara, dll), set role 'admin_lembaga'
    final String namaLower = selectedJabatan.namaJabatan.toLowerCase();
    final String newRole = (namaLower.contains('guru') || namaLower.contains('pengajar'))
        ? 'guru'
        : 'admin_lembaga';

    await ref.read(staffListProvider.notifier).updateRole(widget.staff['id'], newRole);

    if (mounted) Navigator.pop(context);
  }

  Widget _buildModeOption(bool val, String title, String sub) {
    bool isSelected = _isMutation == val;
    return InkWell(
      onTap: () => setState(() => _isMutation = val),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF10B981).withValues(alpha: 0.1) : Colors.white,
          border: Border.all(color: isSelected ? const Color(0xFF10B981) : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFF10B981) : Colors.black)),
            Text(sub, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  // (Dropdown Cabang & Jabatan sama seperti di Form sebelumnya...)
  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)));

  Widget _buildDropdownCabang(String lembagaId) {
    final cabangs = ref.watch(cabangListProvider(lembagaId)).value ?? [];
    return DropdownButtonFormField<String?>(
      decoration: _inputDecor("Pilih Cabang", Icons.business),
      initialValue: _selectedCabangId,
      items: [
        const DropdownMenuItem(value: null, child: Text("Kantor Pusat")),
        ...cabangs.map((c) => DropdownMenuItem(value: c.id, child: Text(c.namaCabang)))
      ],
      onChanged: (v) => setState(() => _selectedCabangId = v),
    );
  }

  Widget _buildDropdownJabatan(String lembagaId) {
    final jabatans = ref.watch(jabatanListProvider(lembagaId)).value ?? [];
    return DropdownButtonFormField<String>(
      decoration: _inputDecor("Pilih Jabatan Baru", Icons.work),
      items: jabatans.map((j) => DropdownMenuItem(value: j.id, child: Text(j.namaJabatan))).toList(),
      onChanged: (v) => setState(() => _selectedJabatanId = v),
    );
  }

  InputDecoration _inputDecor(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: const Color(0xFF10B981)),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  );
}