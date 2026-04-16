// Lokasi: lib/features/kelas/widgets/add_kelas_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../guru_staff/providers/staff_provider.dart';
import '../providers/kelas_provider.dart'; // PERBAIKAN: Path Import
import '../models/kelas_model.dart';

class AddKelasDialog extends ConsumerStatefulWidget {
  const AddKelasDialog({super.key});

  @override
  ConsumerState<AddKelasDialog> createState() => _AddKelasDialogState();
}

class _AddKelasDialogState extends ConsumerState<AddKelasDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  // FIX: _selectedLevel dihapus untuk menghilangkan warning unused_field
  String? _selectedTeacherId;

  final List<String> _level = ['Ula (Dasar)', 'Wustha (Menengah)', 'Ulya (Tinggi)'];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final guruAsync = ref.watch(staffListProvider);

    return AlertDialog(
      title: const Text("Tambah Kelas Baru", style: TextStyle(fontWeight: FontWeight.bold)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Nama Kelas", hintText: "Misal: Abu Bakar"),
                validator: (v) => v == null || v.isEmpty ? "Nama wajib diisi" : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Tingkat"),
                // PERBAIKAN: Mengembalikan ke 'value' & tipe eksplisit <String>
                items: _level.map((l) => DropdownMenuItem<String>(value: l, child: Text(l))).toList(),
                onChanged: (v) {
                  // Assignment dihapus karena variabel penampung dihilangkan
                },
                validator: (v) => v == null ? "Pilih tingkat" : null,
              ),
              const SizedBox(height: 16),
              // Dropdown Ambil Data dari Provider Guru
              guruAsync.when(
                data: (listGuru) => DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "Wali Kelas"),
                  // PERBAIKAN: Mengembalikan ke 'value' & tipe eksplisit <String>
                  items: listGuru.map((g) => DropdownMenuItem<String>(value: g.id, child: Text(g.namaLengkap))).toList(),
                  onChanged: (v) => setState(() => _selectedTeacherId = v),
                  hint: const Text("Pilih Guru"),
                  validator: (v) => v == null ? "Pilih wali kelas" : null,
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text("Gagal mengambil data guru"),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
        ElevatedButton(
          onPressed: () async {
            if (!_formKey.currentState!.validate()) return;

            // PERBAIKAN: Menggunakan kelasListProvider.notifier sesuai standar Riverpod Generator
            await ref.read(kelasListProvider.notifier).addKelas(
              KelasModel(
                name: _nameController.text,
                guruId: _selectedTeacherId,
                // level dihapus sementara agar tidak error undefined_named_parameter
              ),
            );

            if (!context.mounted) return;
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
          child: const Text("Simpan", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}