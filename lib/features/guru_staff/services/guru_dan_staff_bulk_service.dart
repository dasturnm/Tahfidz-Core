// Lokasi: lib/features/guru_staff/services/guru_dan_staff_bulk_service.dart

import 'dart:io';
import 'dart:typed_data'; // Tambahkan untuk konversi bytes
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/services/base_service.dart';
import 'package:tahfidz_core/shared/models/profile_model.dart';
import '../../auth/services/auth_service.dart';

// FIX: Nama part harus sesuai dengan nama file fisik (staff)
part 'guru_dan_staff_bulk_service.g.dart';

@riverpod
GuruDanStaffBulkService guruDanStaffBulkService(Ref ref) {
  return GuruDanStaffBulkService();
}

class GuruDanStaffBulkService extends BaseService {
  GuruDanStaffBulkService();

  // --- 1. EXPORT & BAGIKAN (SHARE) ---
  // Method ini memicu dialog sharing (WA, Email, dll)
  Future<void> exportKeCsv(List<ProfileModel> listStaff) async {
    List<List<dynamic>> rows = [
      ["Nama Lengkap", "NIP", "Nomor HP", "Email", "Jabatan", "Cabang", "Status"]
    ];

    for (var staff in listStaff) {
      rows.add([
        staff.nama,
        staff.id.length >= 8 ? staff.id.substring(0, 8).toUpperCase() : staff.id,
        staff.kontak ?? '-',
        "-",
        staff.namaJabatan ?? '-',
        staff.namaCabang ?? '-',
        staff.isActive ? "AKTIF" : "NONAKTIF",
      ]);
    }

    String csvData = CsvCodec().encode(rows); // FIX: Hapus const
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/Export_Staff_${DateTime.now().millisecondsSinceEpoch}.csv');

    await file.writeAsString(csvData);

    // FIX: Class di paket share_plus tetap bernama 'Share', bukan 'SharePlus'
    await Share.shareXFiles([XFile(file.path)], subject: 'Export Data Guru dan Staff');
  }

  // --- 1a. UNDUH KE PERANGKAT (DOWNLOAD) ---
  // Method ini murni menyimpan file ke folder pilihan user (misal: Downloads)
  Future<String?> unduhKePerangkat(List<ProfileModel> listStaff) async {
    try {
      List<List<dynamic>> rows = [
        ["Nama Lengkap", "NIP", "Nomor HP", "Email", "Jabatan", "Cabang", "Status"]
      ];

      for (var staff in listStaff) {
        rows.add([
          staff.nama,
          staff.id.length >= 8 ? staff.id.substring(0, 8).toUpperCase() : staff.id,
          staff.kontak ?? '-',
          "-",
          staff.namaJabatan ?? '-',
          staff.namaCabang ?? '-',
          staff.isActive ? "AKTIF" : "NONAKTIF",
        ]);
      }

      String csvData = CsvCodec().encode(rows); // FIX: Hapus const
      Uint8List bytes = Uint8List.fromList(csvData.codeUnits);

      // Menggunakan FilePicker untuk "Save As" agar user bisa pilih folder Downloads
      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Simpan Data Guru & Staff',
        fileName: 'Data_Staff_${DateTime.now().millisecondsSinceEpoch}.csv',
        bytes: bytes,
      );

      return outputPath;
    } catch (e) {
      debugPrint("Gagal mengunduh file: $e");
      return null;
    }
  }

  // --- 2. IMPORT DATA DARI CSV ---
  Future<Map<String, int>> importDariCsv({
    required String lembagaId,
    required String defaultJabatanId,
    required String defaultCabangId,
    required AuthService authService,
    required Future<void> Function(String stafId) onTambahPenugasan,
    required VoidCallback onComplete,
  }) async {
    int sukses = 0;
    int gagal = 0;

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result == null) return {'sukses': 0, 'gagal': 0};

    final file = File(result.files.single.path!);
    final csvString = await file.readAsString();

    final fields = CsvCodec().decode(csvString); // FIX: Hapus const

    for (int i = 1; i < fields.length; i++) {
      final row = fields[i];
      if (row.length < 3) continue;

      try {
        final nama = row[0].toString();
        final email = row[3].toString();
        final noHp = row[2].toString();
        const password = "User123!";

        final String? newUserId = await authService.registerGuru(
          nama: nama,
          email: email,
          noHp: noHp,
          password: password,
          lembagaId: lembagaId,
        );

        if (newUserId != null) {
          await onTambahPenugasan(newUserId);
          sukses++;
        }
      } catch (e) {
        gagal++;
        debugPrint("Gagal import baris $i: $e");
      }
    }

    onComplete();

    return {'sukses': sukses, 'gagal': gagal};
  }
}