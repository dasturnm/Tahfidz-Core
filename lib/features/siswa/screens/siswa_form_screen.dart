import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tahfidz_core/features/guru_staff/providers/staff_provider.dart';
import 'package:tahfidz_core/features/siswa/providers/siswa_provider.dart';
// [BARU] Import provider kelas
import 'package:tahfidz_core/features/kelas/providers/kelas_provider.dart';

class SiswaFormScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? siswa;
  const SiswaFormScreen({super.key, this.siswa});

  @override
  ConsumerState<SiswaFormScreen> createState() => _SiswaFormScreenState();
}

class _SiswaFormScreenState extends ConsumerState<SiswaFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _namaController = TextEditingController();
  final _nisnController = TextEditingController();
  final _alamatController = TextEditingController();

  // State Variables
  String _selectedGender = 'L';
  String? _selectedGuruId;
  String? _selectedClassId; // [BARU] State untuk menyimpan ID Kelas
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.siswa != null) {
      _namaController.text = widget.siswa!['nama_lengkap'] ?? '';
      _nisnController.text = widget.siswa!['nisn'] ?? '';
      _alamatController.text = widget.siswa!['alamat'] ?? '';
      _selectedGender = widget.siswa!['jenis_kelamin'] ?? 'L';
      _selectedGuruId = widget.siswa!['guru_id'];
      _selectedClassId = widget.siswa!['class_id']; // [BARU] Ambil data kelas lama jika ada
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nisnController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (widget.siswa == null) {
        // --- TAMBAH SISWA ---
        await ref.read(siswaListProvider.notifier).tambahSiswa(
          nama: _namaController.text,
          jenisKelamin: _selectedGender,
          guruId: _selectedGuruId,
          classId: _selectedClassId, // [BARU] Kirim ID Kelas
          nisn: _nisnController.text.isEmpty ? null : _nisnController.text,
          alamat: _alamatController.text.isEmpty ? null : _alamatController.text,
        );

        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Siswa berhasil ditambahkan!')),
        );
      } else {
        // --- EDIT SISWA ---
        await Supabase.instance.client.from('siswa').update({
          'nama_lengkap': _namaController.text,
          'jenis_kelamin': _selectedGender,
          'guru_id': _selectedGuruId,
          'class_id': _selectedClassId, // [BARU] Update ID Kelas
          'nisn': _nisnController.text.isEmpty ? null : _nisnController.text,
          'alamat': _alamatController.text.isEmpty ? null : _alamatController.text,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', widget.siswa!['id']);

        ref.invalidate(siswaListProvider);

        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data berhasil diperbarui!')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final guruListAsync = ref.watch(staffListProvider);
    final kelasAsync = ref.watch(kelasNotifierProvider); // [BARU] Monitor data kelas

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.siswa == null ? "Tambah Siswa" : "Edit Siswa"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("Nama Lengkap"),
              TextFormField(
                controller: _namaController,
                decoration: _inputDecor("Nama Siswa", Icons.person),
                validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 20),

              _buildLabel("Jenis Kelamin"),
              Row(
                children: [
                  Expanded(
                    child: _buildGenderSelector(
                      value: "L",
                      label: "Laki-laki",
                      icon: Icons.male,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildGenderSelector(
                      value: "P",
                      label: "Perempuan",
                      icon: Icons.female,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // [BARU] --- INPUT PILIH KELAS ---
              _buildLabel("Pilih Kelas"),
              kelasAsync.when(
                data: (listKelas) => DropdownButtonFormField<String>(
                  initialValue: _selectedClassId,
                  decoration: _inputDecor("Pilih Kelas", Icons.meeting_room),
                  items: listKelas.map((k) => DropdownMenuItem(
                    value: k.id,
                    child: Text(k.name),
                  )).toList(),
                  onChanged: (val) => setState(() => _selectedClassId = val),
                  validator: (val) => val == null ? "Kelas wajib dipilih" : null,
                ),
                loading: () => const LinearProgressIndicator(color: Color(0xFF10B981)),
                error: (err, _) => Text("Gagal memuat kelas: $err"),
              ),
              const SizedBox(height: 20),

              _buildLabel("Wali Kelas (Opsional)"),
              guruListAsync.when(
                data: (guruList) {
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedGuruId,
                    decoration: _inputDecor("Pilih Guru", Icons.school),
                    items: guruList.map((guru) {
                      return DropdownMenuItem<String>(
                        value: guru.id,
                        child: Text(
                          guru.nama,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedGuruId = val),
                  );
                },
                loading: () => const LinearProgressIndicator(color: Color(0xFF10B981)),
                error: (err, _) => Text("Error: $err"),
              ),
              const SizedBox(height: 20),

              _buildLabel("NISN"),
              TextFormField(
                controller: _nisnController,
                keyboardType: TextInputType.number,
                decoration: _inputDecor("Nomor Induk", Icons.badge),
              ),
              const SizedBox(height: 20),

              _buildLabel("Alamat"),
              TextFormField(
                controller: _alamatController,
                maxLines: 3,
                decoration: _inputDecor("Alamat lengkap...", Icons.home),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Simpan Data", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderSelector({required String value, required String label, required IconData icon}) {
    final bool isSelected = _selectedGender == value;

    return InkWell(
      onTap: () => setState(() => _selectedGender = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF10B981).withValues(alpha: 0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF10B981) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? const Color(0xFF10B981) : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF10B981) : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
  );

  InputDecoration _inputDecor(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, color: Colors.grey),
    filled: true,
    fillColor: Colors.grey[50],
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF10B981), width: 2)),
  );
}