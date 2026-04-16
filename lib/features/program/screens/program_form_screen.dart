import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/program_provider.dart';
import '../models/program_model.dart'; // Baru: Import model
import '../../management_lembaga/providers/cabang_provider.dart';

class ProgramFormScreen extends ConsumerStatefulWidget {
  final ProgramModel? program; // Baru: Untuk mode edit
  const ProgramFormScreen({super.key, this.program});

  @override
  ConsumerState<ProgramFormScreen> createState() => _ProgramFormScreenState();
}

class _ProgramFormScreenState extends ConsumerState<ProgramFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _regController = TextEditingController();
  final _sppController = TextEditingController();

  String? _selectedCabangId; // Baru: State untuk menyimpan cabang terpilih
  final List<String> _selectedDays = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Jika dalam mode edit, isi controller dengan data yang ada
    if (widget.program != null) {
      _nameController.text = widget.program!.namaProgram;
      _descController.text = widget.program!.deskripsi ?? '';
      _regController.text = widget.program!.biayaPendaftaran.toInt().toString();
      _sppController.text = widget.program!.biayaSpp.toInt().toString();
      _selectedCabangId = widget.program!.cabangId;
      _selectedDays.clear();
      _selectedDays.addAll(widget.program!.hariAktif);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _regController.dispose();
    _sppController.dispose();
    super.dispose();
  }

  Future<void> _saveProgram() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      if (widget.program == null) {
        // MODE TAMBAH
        await ref.read(programNotifierProvider.notifier).addProgram(
          nama: _nameController.text.trim(),
          cabangId: _selectedCabangId, // Diubah: Mengirim cabangId bukan tag
          deskripsi: _descController.text.trim(),
          pendaftaran: double.tryParse(_regController.text) ?? 0,
          spp: double.tryParse(_sppController.text) ?? 0,
          hari: _selectedDays,
        );
      } else {
        // MODE EDIT
        final updatedProgram = ProgramModel(
          id: widget.program!.id,
          lembagaId: widget.program!.lembagaId,
          cabangId: _selectedCabangId,
          namaProgram: _nameController.text.trim(),
          deskripsi: _descController.text.trim(),
          biayaPendaftaran: double.tryParse(_regController.text) ?? 0,
          biayaSpp: double.tryParse(_sppController.text) ?? 0,
          hariAktif: _selectedDays,
          status: widget.program!.status,
        );
        await ref.read(programNotifierProvider.notifier).updateProgram(updatedProgram);
      }

      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil daftar cabang untuk dropdown
    final cabangAsync = ref.watch(cabangListProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.program == null ? "Tambah Program Baru" : "Edit Program",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("INFORMASI DASAR"),
              const SizedBox(height: 16),
              _buildLabel("Nama Program"),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecor("Misal: Tahfidz Intensif"),
                validator: (val) => val!.isEmpty ? "Nama wajib diisi" : null,
              ),
              const SizedBox(height: 20),

              // DIUBAH: Mengganti label menjadi pertanyaan informatif
              _buildLabel("Di mana program ini akan berjalan?"),
              const Text(
                "Pilih 'Lembaga Pusat' jika program ini berlaku untuk seluruh cabang, atau pilih cabang spesifik.",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              cabangAsync.when(
                data: (list) => DropdownButtonFormField<String?>(
                  initialValue: _selectedCabangId,
                  decoration: _inputDecor("Pilih Cakupan Wilayah"),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text("🏢 Lembaga Pusat (Global)"),
                    ),
                    ...list.map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Text("📍 ${c.namaCabang}"),
                    )),
                  ],
                  onChanged: (val) => setState(() => _selectedCabangId = val),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text("Gagal memuat daftar cabang"),
              ),

              const SizedBox(height: 20),
              _buildLabel("Deskripsi Singkat"),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: _inputDecor("Jelaskan program ini..."),
              ),
              const SizedBox(height: 40),

              _buildSectionHeader("BIAYA PROGRAM"),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Pendaftaran"),
                        TextFormField(
                          controller: _regController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecor("Rp"),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("SPP / Bulan"),
                        TextFormField(
                          controller: _sppController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecor("Rp"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              _buildSectionHeader("TEMPLATE JADWAL"),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'].map((day) {
                  final isSelected = _selectedDays.contains(day);
                  return FilterChip(
                    label: Text(day),
                    selected: isSelected,
                    onSelected: (bool value) {
                      setState(() {
                        if (value) {
                          _selectedDays.add(day);
                        } else {
                          _selectedDays.remove(day);
                        }
                      });
                    },
                    selectedColor: const Color(0xFF10B981),
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 60),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProgram,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    widget.program == null ? "Simpan Program" : "Simpan Perubahan",
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) => Text(
    title,
    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1),
  );

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
  );

  InputDecoration _inputDecor(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.grey[50],
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF10B981), width: 2)),
  );
}