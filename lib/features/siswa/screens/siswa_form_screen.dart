// Lokasi: lib/features/siswa/screens/siswa_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/siswa_model.dart';
import '../providers/siswa_provider.dart';
import '../../program/providers/program_provider.dart'; // FIX: Migrasi ke programNotifierProvider
import '../../kelas/providers/kelas_provider.dart';
// FIX: Menggunakan level_provider spesifik
import '../../akademik/kurikulum/providers/kurikulum_provider.dart'; // TAMBAHAN: Import provider kurikulum
import 'package:tahfidz_core/core/providers/app_context_provider.dart';

class SiswaFormScreen extends ConsumerStatefulWidget {
  final SiswaModel? existingSiswa;

  const SiswaFormScreen({super.key, this.existingSiswa});

  @override
  ConsumerState<SiswaFormScreen> createState() => _SiswaFormScreenState();
}

class _SiswaFormScreenState extends ConsumerState<SiswaFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _namaController = TextEditingController();
  final _nisnController = TextEditingController();
  final _alamatController = TextEditingController();

  String _jenisKelamin = 'L';
  String _status = 'aktif';
  DateTime? _tglLahir;
  String? _selectedProgramId;
  String? _selectedKurikulumId; // TAMBAHAN
  String? _selectedLevelId;
  String? _selectedModulId; // TAMBAHAN
  String? _selectedKelasId; // PERBAIKAN: Label Kelas

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // FIX (Aturan 7): Data ditarik otomatis oleh AsyncNotifier saat di-watch di build()
    });

    if (widget.existingSiswa != null) {
      final s = widget.existingSiswa!;
      _namaController.text = s.namaLengkap;
      _nisnController.text = s.nisn ?? '';
      _alamatController.text = s.alamat ?? '';
      _jenisKelamin = s.jenisKelamin;
      _status = s.status;
      _tglLahir = s.tglLahir;
      _selectedProgramId = s.programId;
      _selectedKurikulumId = s.kurikulumId; // TAMBAHAN
      _selectedLevelId = s.levelId ?? s.currentLevelId;
      _selectedModulId = s.currentModulId; // TAMBAHAN
      _selectedKelasId = s.kelasId;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nisnController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tglLahir ?? DateTime.now().subtract(const Duration(days: 365 * 10)),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D9488),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _tglLahir) {
      setState(() {
        _tglLahir = picked;
      });
    }
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final lembagaId = ref.read(appContextProvider).lembaga?.id ?? '';

    if (lembagaId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: ID Lembaga tidak ditemukan.')),
      );
      setState(() => _isSaving = false);
      return;
    }

    final siswaData = SiswaModel(
      id: widget.existingSiswa?.id,
      lembagaId: lembagaId,
      namaLengkap: _namaController.text.trim(),
      nisn: _nisnController.text.trim().isEmpty ? null : _nisnController.text.trim(),
      jenisKelamin: _jenisKelamin,
      tglLahir: _tglLahir,
      alamat: _alamatController.text.trim().isEmpty ? null : _alamatController.text.trim(),
      status: _status,
      programId: _selectedProgramId,
      kurikulumId: _selectedKurikulumId, // TAMBAHAN
      levelId: _selectedLevelId,
      currentLevelId: _selectedLevelId,
      currentModulId: _selectedModulId, // TAMBAHAN
      kelasId: _selectedKelasId,
      totalJuzHafalan: widget.existingSiswa?.totalJuzHafalan ?? 0,
      lastSurah: widget.existingSiswa?.lastSurah,
      lastAyah: widget.existingSiswa?.lastAyah,
    );

    bool success;
    if (widget.existingSiswa == null) {
      success = await ref.read(siswaListProvider.notifier).addSiswa(siswaData);
    } else {
      success = await ref.read(siswaListProvider.notifier).updateSiswa(siswaData);
    }

    setState(() => _isSaving = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingSiswa == null ? 'Siswa berhasil ditambahkan!' : 'Data siswa diperbarui!'),
            backgroundColor: const Color(0xFF059669),
          ),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ref.read(siswaListProvider).error?.toString() ?? 'Terjadi kesalahan'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingSiswa != null;
    final programsAsync = ref.watch(programNotifierProvider);
    final kelasAsync = ref.watch(kelasListProvider);

    // 🔥 DATA DYNAMIC
    final kurikulumAsync = ref.watch(kurikulumByProgramProvider(_selectedProgramId));
    final levelsAsync = ref.watch(levelsByKurikulumProvider(_selectedKurikulumId));
    final modulsAsync = ref.watch(modulByLevelProvider(_selectedLevelId));

    final selectedKurikulum = (kurikulumAsync.value ?? []).where((k) => k.id == _selectedKurikulumId).firstOrNull;
    bool isLinear = selectedKurikulum?.isLinear ?? false;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        title: Text(
          isEditing ? 'Edit Data Siswa' : 'Tambah Siswa Baru',
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
                _buildSectionTitle('Informasi Personal'),
                _buildTextField(
                  controller: _namaController,
                  label: 'Nama Lengkap',
                  hint: 'Masukkan nama siswa',
                  validator: (val) => val == null || val.isEmpty ? 'Nama tidak boleh kosong' : null,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _nisnController,
                        label: 'NIS / NISN (Opsional)',
                        hint: 'Nomor Induk',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdown(
                        label: 'Jenis Kelamin',
                        value: _jenisKelamin,
                        items: const [
                          DropdownMenuItem(value: 'L', child: Text('Ikhwan (L)')),
                          DropdownMenuItem(value: 'P', child: Text('Akhwat (P)')),
                        ],
                        onChanged: (val) => setState(() => _jenisKelamin = val.toString()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tanggal Lahir',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDate(context),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.transparent),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _tglLahir == null ? 'Pilih Tanggal' : DateFormat('dd MMMM yyyy').format(_tglLahir!),
                              style: TextStyle(
                                color: _tglLahir == null ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Icon(Icons.calendar_month_rounded, color: Color(0xFF94A3B8)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                _buildTextField(
                  controller: _alamatController,
                  label: 'Alamat Lengkap',
                  hint: 'Masukkan alamat domisili',
                  maxLines: 3,
                ),

                const SizedBox(height: 32),
                _buildSectionTitle('Informasi Akademik'),

                _buildDropdown(
                  label: 'Program Akademik',
                  value: _selectedProgramId,
                  hint: programsAsync.isLoading ? 'Memuat program...' : 'Pilih Program',
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Tanpa Program')),
                    ...programsAsync.maybeWhen(
                      data: (list) => list.map((p) => DropdownMenuItem(
                          value: p.id,
                          child: Text(p.namaProgram, overflow: TextOverflow.ellipsis)
                      )).toList(),
                      orElse: () => [],
                    ),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedProgramId = val?.toString();
                      _selectedKurikulumId = null;
                      _selectedLevelId = null;
                      _selectedModulId = null;
                    });
                  },
                ),

                // TAMBAHAN: Dropdown Kurikulum
                const SizedBox(height: 16),
                _buildDropdown(
                  label: 'Kurikulum',
                  value: _selectedKurikulumId,
                  hint: kurikulumAsync.isLoading ? 'Memuat kurikulum...' : 'Pilih Kurikulum',
                  items: kurikulumAsync.maybeWhen(
                    data: (list) => list.map((k) => DropdownMenuItem(
                        value: k.id,
                        child: Text(k.namaKurikulum, overflow: TextOverflow.ellipsis)
                    )).toList(),
                    orElse: () => [],
                  ),
                  onChanged: (val) => setState(() {
                    _selectedKurikulumId = val?.toString();
                    _selectedLevelId = null;
                    _selectedModulId = null;
                  }),
                ),

                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        label: isLinear ? 'Jenjang' : 'Level',
                        value: _selectedLevelId,
                        hint: levelsAsync.isLoading ? 'Memuat...' : 'Pilih ${isLinear ? 'Jenjang' : 'Level'}',
                        items: levelsAsync.maybeWhen(
                          data: (list) => list.map((l) => DropdownMenuItem(
                            value: l.id,
                            child: Text(l.namaLevel),
                          )).toList(),
                          orElse: () => [],
                        ),
                        onChanged: (val) => setState(() {
                          _selectedLevelId = val?.toString();
                          _selectedModulId = null;
                        }),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdown(
                        label: 'Modul Awal',
                        value: _selectedModulId,
                        hint: modulsAsync.isLoading ? 'Memuat...' : 'Pilih Modul',
                        items: modulsAsync.maybeWhen(
                          data: (list) => list.map((m) => DropdownMenuItem(
                            value: m.id,
                            child: Text(m.namaModul),
                          )).toList(),
                          orElse: () => [],
                        ),
                        onChanged: (val) => setState(() => _selectedModulId = val?.toString()),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                _buildDropdown(
                  label: 'Unit Kelas',
                  value: _selectedKelasId,
                  hint: kelasAsync.isLoading ? 'Memuat...' : 'Pilih Kelas',
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Belum Ada')),
                    ...(kelasAsync.value ?? [])
                        .where((c) => _selectedProgramId == null || c.programId == _selectedProgramId)
                        .map((c) {
                      return DropdownMenuItem(value: c.id, child: Text(c.namaKelas, overflow: TextOverflow.ellipsis));
                    }),
                  ],
                  onChanged: (val) => setState(() => _selectedKelasId = val?.toString()),
                ),

                const SizedBox(height: 16),
                _buildDropdown(
                  label: 'Status Siswa',
                  value: _status,
                  items: const [
                    DropdownMenuItem(value: 'aktif', child: Text('Aktif')),
                    DropdownMenuItem(value: 'nonaktif', child: Text('Non-Aktif')),
                    DropdownMenuItem(value: 'cuti', child: Text('Cuti')),
                    DropdownMenuItem(value: 'lulus', child: Text('Lulus')),
                    DropdownMenuItem(value: 'pindah', child: Text('Pindah')),
                  ],
                  onChanged: (val) => setState(() => _status = val.toString()),
                ),

                const SizedBox(height: 48),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                      isEditing ? 'SIMPAN PERUBAHAN' : 'TAMBAH SISWA',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
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
    int maxLines = 1,
    String? Function(String?)? validator,
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
          maxLines: maxLines,
          validator: validator,
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
          items: items,
          onChanged: onChanged,
          initialValue: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8)),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF0D9488), width: 2)),
          ),
        ),
      ],
    );
  }
}