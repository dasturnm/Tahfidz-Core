// Lokasi: lib/features/kelas/screens/class_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/kelas_model.dart';
import '../providers/class_provider.dart';
import '../../akademik/providers/akademik_provider.dart';

class ClassFormScreen extends ConsumerStatefulWidget {
  final KelasModel? existingClass; // Jika null berarti tambah baru

  const ClassFormScreen({super.key, this.existingClass});

  @override
  ConsumerState<ClassFormScreen> createState() => _ClassFormScreenState();
}

class _ClassFormScreenState extends ConsumerState<ClassFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _waktuController = TextEditingController();
  final _ruanganController = TextEditingController();
  final _kapasitasController = TextEditingController();

  // Variabel bantuan untuk jam
  String _startTime = "--:--";
  String _endTime = "--:--";

  String? _selectedProgramId;
  String? _selectedLevelId;
  String? _selectedTeacherId;

  bool _isSaving = false;
  bool _isLoadingTeachers = false;

  // List sementara untuk menampung data guru
  List<Map<String, dynamic>> _teachers = [];

  @override
  void initState() {
    super.initState();

    // Ambil data Program & Level dari Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(akademikProvider).fetchMasterData();
      _fetchTeachers(); // Ambil daftar guru
    });

    // Jika mode edit, isi data awal
    if (widget.existingClass != null) {
      final c = widget.existingClass!;
      _nameController.text = c.name;
      _selectedProgramId = c.programId;
      _selectedLevelId = c.levelId;
      _selectedTeacherId = c.teacherId;
      _waktuController.text = c.waktuBelajar ?? '';
      _ruanganController.text = c.ruangan ?? '';
      _kapasitasController.text = c.kapasitas?.toString() ?? '';

      // Pecah string waktu jika ada data
      if (c.waktuBelajar != null && c.waktuBelajar!.contains(" - ")) {
        final parts = c.waktuBelajar!.split(" - ");
        _startTime = parts[0];
        _endTime = parts[1];
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
            colorScheme: const ColorScheme.light(primary: Color(0xFF0D9488)),
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
  Future<void> _fetchTeachers() async {
    setState(() => _isLoadingTeachers = true);
    try {
      // FIX: Query disesuaikan skema (Tabel 'gurus' kolom 'nama')
      final response = await Supabase.instance.client
          .from('gurus')
          .select('id, nama');

      debugPrint('DEBUG GURU: $response');

      setState(() {
        _teachers = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint('ERROR AMBIL GURU: $e');
    } finally {
      setState(() => _isLoadingTeachers = false);
    }
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    // Merakit data kelas
    final classData = KelasModel(
      id: widget.existingClass?.id,
      name: _nameController.text.trim(),
      levelId: _selectedLevelId,
      programId: _selectedProgramId,
      teacherId: _selectedTeacherId,
      waktuBelajar: _waktuController.text.trim(),
      ruangan: _ruanganController.text.trim(),
      kapasitas: int.tryParse(_kapasitasController.text),
    );

    bool success;
    if (widget.existingClass == null) {
      success = await ref.read(classProvider).addClass(classData);
    } else {
      success = await ref.read(classProvider).updateClass(classData);
    }

    setState(() => _isSaving = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingClass == null ? 'Kelas berhasil dibuat!' : 'Kelas diperbarui!'),
            backgroundColor: const Color(0xFF0D9488),
          ),
        );
        Navigator.pop(context); // Kembali ke halaman sebelumnya
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ref.read(classProvider).errorMessage ?? 'Terjadi kesalahan'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingClass != null;
    final akademikState = ref.watch(akademikProvider);

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
                  hint: akademikState.isLoading ? 'Memuat program...' : 'Pilih Program (Opsional)',
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Tidak Terikat Program')),
                    ...akademikState.programs.map((p) {
                      return DropdownMenuItem(value: p.id, child: Text(p.namaProgram));
                    }),
                  ],
                  onChanged: (val) => setState(() => _selectedProgramId = val?.toString()),
                ),
                const SizedBox(height: 16),

                // Level Kurikulum
                _buildDropdown(
                  label: 'Level Target',
                  value: _selectedLevelId,
                  hint: akademikState.isLoading ? 'Memuat level...' : 'Pilih Level (Opsional)',
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Tanpa Level Khusus')),
                    ...akademikState.levels.map((l) {
                      return DropdownMenuItem(value: l.id, child: Text(l.namaLevel));
                    }),
                  ],
                  onChanged: (val) => setState(() => _selectedLevelId = val?.toString()),
                ),
                const SizedBox(height: 16),

                // Guru / Wali Kelas
                _buildDropdown(
                  label: 'Guru/Wali Kelas',
                  value: _selectedTeacherId,
                  hint: _isLoadingTeachers ? 'Memuat data guru...' : 'Pilih Guru',
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Belum Ditentukan')),
                    ..._teachers.map((t) {
                      // AMBIL NAMA DARI TABEL GURUS SESUAI SKEMA
                      final String nama = t['nama'] ?? 'Tanpa Nama';
                      return DropdownMenuItem(value: t['id'].toString(), child: Text(nama));
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
                      backgroundColor: const Color(0xFF0D9488), // Teal
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
                const Icon(Icons.access_time_filled_rounded, size: 16, color: Color(0xFF0D9488)),
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
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF0D9488), width: 2)),
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
          value: value,
          items: items,
          onChanged: onChanged,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8)),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF0D9488), width: 2)
            ),
          ),
        ),
      ],
    );
  }
}