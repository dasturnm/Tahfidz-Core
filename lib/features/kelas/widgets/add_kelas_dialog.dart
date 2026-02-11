import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../guru_staff/providers/guru_provider.dart';
import '../providers/kelas_provider.dart';

class AddKelasDialog extends ConsumerStatefulWidget {
  const AddKelasDialog({super.key});

  @override
  ConsumerState<AddKelasDialog> createState() => _AddKelasDialogState();
}

class _AddKelasDialogState extends ConsumerState<AddKelasDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedLevel;
  String? _selectedTeacherId;

  final List<String> _levels = ['Ula (Dasar)', 'Wustha (Menengah)', 'Ulya (Tinggi)'];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gurusAsync = ref.watch(guruListProvider);

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
                items: _levels.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                onChanged: (v) => setState(() => _selectedLevel = v),
                validator: (v) => v == null ? "Pilih tingkat" : null,
              ),
              const SizedBox(height: 16),
              // Dropdown Ambil Data dari Provider Guru
              gurusAsync.when(
                data: (listGuru) => DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "Wali Kelas"),
                  items: listGuru.map((g) => DropdownMenuItem(value: g.id, child: Text(g.nama))).toList(),
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

            await ref.read(kelasNotifierProvider.notifier).addKelas(
              _nameController.text,
              _selectedLevel,
              _selectedTeacherId,
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