// Lokasi: lib/features/kelas/screens/kelas_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/kelas_model.dart';
import '../providers/kelas_provider.dart';
import '../../program/providers/program_provider.dart'; // FIX: Gunakan programNotifierProvider
import '../../../core/providers/app_context_provider.dart';

class KelasFormScreen extends ConsumerStatefulWidget {
  final KelasModel? existingKelas; // PERBAIKAN: Label Kelas

  const KelasFormScreen({super.key, this.existingKelas});

  @override
  ConsumerState<KelasFormScreen> createState() => _KelasFormScreenState();
}

class _KelasFormScreenState extends ConsumerState<KelasFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _waktuController = TextEditingController();
  final _ruanganController = TextEditingController();
  final _kapasitasController = TextEditingController();

  // Variabel bantuan untuk jam
  String _startTime = "--:--";
  String _endTime = "--:--";

  String? _selectedProgramId;
  String? _selectedTeacherId;

  bool _isSaving = false;
  bool _isLoadingGuru = false;

  // List sementara untuk menampung data guru
  List<Map<String, dynamic>> _guru = [];

  @override
  void initState() {
    super.initState();

    // Data Program ditarik otomatis oleh programNotifierProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchGuru(); // Ambil daftar guru
    });

    // Jika mode edit, isi data awal
    if (widget.existingKelas != null) {
      final c = widget.existingKelas!;
      _nameController.text = c.namaKelas; // FIX: Menggunakan namaKelas
      _selectedProgramId = c.programId;
      _selectedTeacherId = c.guruId; // PERBAIKAN: Label Guru
      _waktuController.text = c.waktuBelajar ?? '';
      _ruanganController.text = c.ruangan ?? '';
      _kapasitasController.text = c.kapasitas?.toString() ?? '';

      // Pecah string waktu jika ada data
      if (c.waktuBelajar != null && c.waktuBelajar!.contains(" - ")) {
        final parts = c.waktuBelajar!.split(" - ");
        _startTime = parts[0];
        _endTime = parts[1]; // FIX: Menggunakan hasil split indeks ke-1
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _waktuController.dispose();
    _ruanganController.dispose();
    _kapasitasController.dispose();
    super.dispose();
  }

  // Fungsi Helper Time Picker
  Future<void> _selectTime(bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF3B82F6)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        final formatted = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
        if (isStart) {
          _startTime = formatted;
        } else {
          _endTime = formatted;
        }
        _waktuController.text = "$_startTime - $_endTime";
      });
    }
  }

  // Fungsi untuk mengambil daftar staff dengan role 'guru'
  Future<void> _fetchGuru() async {
    setState(() => _isLoadingGuru = true);
    try {
      // FIX: Ambil lembagaId dari context (Aturan 4 - Anti Data Leak)
      final lembagaId = ref.read(appContextProvider).lembaga?.id;
      if (lembagaId == null) return;

      // FIX: Query disesuaikan skema (Tabel 'profiles' kolom 'nama_lengkap') - Aturan 5.1
      final response = await Supabase.instance.client
          .from('profiles')
          .select('id, nama_lengkap')
          .eq('lembaga_id', lembagaId)
          .eq('role', 'guru');

      debugPrint('DEBUG GURU: $response');

      if (!mounted) return;
      setState(() {
        _guru = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint('ERROR AMBIL GURU: $e');
    } finally {
      if (mounted) setState(() => _isLoadingGuru = false);
    }
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    // Merakit data kelas (cabangId diabaikan karena redundan)
    final classData = KelasModel(
      id: widget.existingKelas?.id,
      namaKelas: _nameController.text.trim(), // FIX: Menggunakan namaKelas
      programId: _selectedProgramId,
      guruId: _selectedTeacherId, // PERBAIKAN: Label Guru
      waktuBelajar: _waktuController.text.trim(),
      ruangan: _ruanganController.text.trim(),
      kapasitas: int.tryParse(_kapasitasController.text),
    );

    bool success = false;
    try {
      if (widget.existingKelas == null) {
        // FIX: Menggunakan kelasListProvider.notifier
        await ref.read(kelasListProvider.notifier).addKelas(classData);
      } else {
        // FIX: Menggunakan kelasListProvider.notifier
        await ref.read(kelasListProvider.notifier).updateKelas(classData);
      }
      success = !ref.read(kelasListProvider).hasError;
    } catch (_) {
      success = false;
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.existingKelas == null ? 'Kelas berhasil dibuat!' : 'Kelas diperbarui!'),
          backgroundColor: const Color(0xFF3B82F6),
        ),
      );
      Navigator.pop(context); // Kembali ke halaman sebelumnya
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // FIX: Mengambil error dari AsyncValue state
          content: Text(ref.read(kelasListProvider).error?.toString() ?? 'Terjadi kesalahan'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingKelas != null;

    // FIX (Aturan 7): Menggunakan programNotifierProvider (AsyncValue)
    final programsAsync = ref.watch(programNotifierProvider);

    const academicColor = Color(0xFF3B82F6); // Biru Akademik (Aturan 8)

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        title: Text(
          isEditing ? 'Edit Kelas' : 'Buat Kelas Baru',
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Informasi Kelas'),

                // Nama Kelas
                _buildTextField(
                  controller: _nameController,
                  label: 'Nama Kelas',
                  hint: 'Contoh: Kelas B-1',
                  validator: (val) => val == null || val.isEmpty ? 'Nama Kelas wajib diisi' : null,
                ),
                const SizedBox(height: 24),

                // Program
                _buildDropdown(
                  label: 'Program Akademik',
                  value: _selectedProgramId,
                  isLoading: programsAsync.isLoading,
                  hint: programsAsync.isLoading ? 'Memuat program...' : 'Pilih Program (Opsional)',
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Tidak Terikat Program')),
                    ...programsAsync.maybeWhen(
                      data: (list) => list.map((p) => DropdownMenuItem(value: p.id, child: Text(p.namaProgram))).toList(),
                      orElse: () => [],
                    ),
                  ],
                  onChanged: (val) => setState(() => _selectedProgramId = val?.toString()),
                ),
                const SizedBox(height: 16),

                // Guru / Wali Kelas
                _buildDropdown(
                  label: 'Guru/Wali Kelas',
                  value: _selectedTeacherId,
                  isLoading: _isLoadingGuru,
                  hint: _isLoadingGuru ? 'Memuat data guru...' : 'Pilih Guru',
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Belum Ditentukan')),
                    ..._guru.map((t) {
                      // AMBIL NAMA DARI TABEL PROFILES (Aturan 5.1)
                      final String nama = t['nama_lengkap']?.toString() ?? 'Tanpa Nama';
                      return DropdownMenuItem(value: t['id']?.toString(), child: Text(nama));
                    }),
                  ],
                  onChanged: (val) => setState(() => _selectedTeacherId = val?.toString()),
                ),

                const SizedBox(height: 24),
                _buildSectionTitle('Detail Pelaksanaan'),

                // WAKTU BELAJAR
                const Text(
                  "WAKTU BELAJAR",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1.0),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildTimeSelector(
                        label: "Jam Mulai",
                        time: _startTime,
                        onTap: () => _selectTime(true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTimeSelector(
                        label: "Jam Berakhir",
                        time: _endTime,
                        onTap: () => _selectTime(false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Ruangan
                _buildTextField(
                  controller: _ruanganController,
                  label: 'Ruangan',
                  hint: 'Contoh: Ruang Al-Kautsar',
                ),
                const SizedBox(height: 16),

                // Kapasitas
                _buildTextField(
                  controller: _kapasitasController, // FIX: Kapasitas menggunakan kapasitasController
                  label: 'Kapasitas Maksimal Siswa',
                  hint: 'Contoh: 15',
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 48),

                // Tombol Simpan
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: academicColor, // Biru Akademik (Aturan 8)
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                      isEditing ? 'SIMPAN PERUBAHAN' : 'BUAT KELAS SEKARANG',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // WIDGET KHUSUS PICKER JAM
  Widget _buildTimeSelector({required String label, required String time, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time_filled_rounded, size: 16, color: Color(0xFF3B82F6)),
                const SizedBox(width: 8),
                Text(time, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: Color(0xFF94A3B8),
          letterSpacing: 2.0,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1.0),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontWeight: FontWeight.normal),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.red, width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required dynamic value,
    required List<DropdownMenuItem<Object>> items,
    required void Function(Object?) onChanged,
    String? hint,
    bool isLoading = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1.0),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<Object>(
          // FIX: Menggunakan value agar reaktif terhadap perubahan state AsyncNotifier
          initialValue: items.any((item) => item.value == value) ? value : null,
          items: items,
          onChanged: onChanged,
          icon: isLoading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF3B82F6)))
              : const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8)),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2)
            ),
          ),
        ),
      ],
    );
  }
}