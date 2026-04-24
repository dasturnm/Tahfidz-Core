// Lokasi: lib/features/siswa/widgets/import_siswa_dialog.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart'; // Import normal, sudah bebas masalah
import '../models/siswa_model.dart';
import '../providers/siswa_provider.dart';
import '../../../core/providers/app_context_provider.dart';

class ImportSiswaDialog extends ConsumerStatefulWidget {
  const ImportSiswaDialog({super.key});

  @override
  ConsumerState<ImportSiswaDialog> createState() => _ImportSiswaDialogState();
}

class _ImportSiswaDialogState extends ConsumerState<ImportSiswaDialog> {
  bool _isProcessing = false;
  PlatformFile? _pickedFile;
  List<SiswaModel> _previewData = [];

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      setState(() {
        _pickedFile = result.files.first;
        _previewData = [];
      });
      _parseCsv();
    }
  }

  Future<void> _parseCsv() async {
    if (_pickedFile == null || _pickedFile!.path == null) return;

    setState(() => _isProcessing = true);

    try {
      final lembagaId = ref.read(appContextProvider).lembaga?.id;
      if (lembagaId == null) {
        throw Exception('ID Lembaga tidak ditemukan. Silakan login ulang.');
      }

      final file = File(_pickedFile!.path!);

      // Baca file langsung sebagai String utuh (otomatis UTF-8)
      final csvString = await file.readAsString();

      // JURUS PAMUNGKAS: Menggunakan API baru dari csv v7.0.0+ (Membaca file utuh lalu di-decode)
      final fields = CsvCodec().decode(csvString);

      List<SiswaModel> tempSiswa = [];
      // Mulai dari 1 untuk skip header
      for (var i = 1; i < fields.length; i++) {
        final row = fields[i];
        if (row.length >= 2) {
          tempSiswa.add(
            SiswaModel(
              lembagaId: lembagaId,
              namaLengkap: row[0].toString(),
              nisn: row.length > 1 ? row[1].toString() : null,
              email: row.length > 2 ? row[2].toString() : null,
              noHp: row.length > 3 ? row[3].toString() : null,
              jenisKelamin: row.length > 4 ? (row[4].toString().toUpperCase() == 'L' ? 'L' : 'P') : 'L',
              tglLahir: row.length > 5 ? DateTime.tryParse(row[5].toString()) : null,
              alamat: row.length > 6 ? row[6].toString() : null,
              status: row.length > 7 ? row[7].toString().toLowerCase() : 'aktif',
            ),
          );
        }
      }

      setState(() => _previewData = tempSiswa);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membaca CSV: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _executeImport() async {
    if (_previewData.isEmpty) return;

    setState(() => _isProcessing = true);

    // FIX: Menggunakan notifier dari siswaListProvider sesuai standar Riverpod Generator
    final success = await ref.read(siswaListProvider.notifier).bulkImportSiswa(_previewData);

    if (mounted) {
      setState(() => _isProcessing = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Berhasil mengimpor data siswa!'),
              backgroundColor: Color(0xFF10B981)
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // FIX: Mengambil pesan error dari state AsyncValue
              content: Text(ref.read(siswaListProvider).error?.toString() ?? 'Gagal impor'),
              backgroundColor: Colors.red
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text(
        'Import Database Siswa',
        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Gunakan format file .CSV sesuai template resmi.\nKolom: Nama, NISN, Email, No HP, JK, Tgl Lahir, Alamat, Status, Password',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            InkWell(
              onTap: _isProcessing ? null : _pickFile,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Column(
                  children: [
                    Icon(
                        Icons.cloud_upload_outlined,
                        size: 40,
                        color: _pickedFile != null ? const Color(0xFF4F46E5) : Colors.grey
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _pickedFile?.name ?? 'Klik untuk Pilih File CSV',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: _pickedFile != null ? const Color(0xFF1E293B) : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (_previewData.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Terdeteksi ${_previewData.length} data siswa siap impor.',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D9488)
                ),
              ),
            ],

            if (_isProcessing)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: LinearProgressIndicator(color: Color(0xFF4F46E5)),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => ref.read(siswaListProvider.notifier).downloadTemplate(),
          child: const Text(
              'Unduh Template',
              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
              'Batal',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)
          ),
        ),
        ElevatedButton(
          onPressed: (_isProcessing || _previewData.isEmpty) ? null : _executeImport,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F46E5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text(
              'PROSES IMPORT',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)
          ),
        ),
      ],
    );
  }
}