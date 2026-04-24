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
  Future<void> exportKeCsv(List<dynamic> listStaff) async {
    // Sinkronisasi kolom: Nama, NIP, Email, No HP, JK, Tgl Gabung, Lokasi, Jabatan, Password
    List<List<dynamic>> rows = [
      ["Nama Lengkap", "NIP", "Email", "No HP", "Jenis Kelamin", "Tanggal Bergabung", "Lokasi Tugas", "Jabatan", "Password Sementara"]
    ];

    for (var staff in listStaff) {
      rows.add([
        staff.namaStaf ?? staff.nama ?? '-',
        staff.nip ?? '-',
        staff.emailStaf ?? staff.email ?? '-',
        staff.noHp ?? staff.kontak ?? '-',
        staff.jenisKelamin ?? '-',
        staff.tanggalBergabung ?? '-',
        staff.namaCabang ?? '-',
        staff.namaJabatan ?? '-',
        "-", // Password tidak di-export demi keamanan
      ]);
    }

    String csvData = CsvCodec().encode(rows); // FIX: Menggunakan CsvCodec
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/Export_Staff_${DateTime.now().millisecondsSinceEpoch}.csv');

    await file.writeAsString(csvData);

    // FIX: Class di paket share_plus adalah 'Share', bukan 'SharePlus'
    await Share.shareXFiles([XFile(file.path)], subject: 'Export Data Guru dan Staff');
  }

  // --- 1a. UNDUH KE PERANGKAT (DOWNLOAD) ---
  // Method ini murni menyimpan file ke folder pilihan user (misal: Downloads)
  Future<String?> unduhKePerangkat(List<dynamic> listStaff) async {
    try {
      List<List<dynamic>> rows = [
        ["Nama Lengkap", "NIP", "Email", "No HP", "Jenis Kelamin", "Tanggal Bergabung", "Lokasi Tugas", "Jabatan", "Password Sementara"]
      ];

      for (var staff in listStaff) {
        rows.add([
          staff.namaStaf ?? staff.nama ?? '-',
          staff.nip ?? '-',
          staff.emailStaf ?? staff.email ?? '-',
          staff.noHp ?? staff.kontak ?? '-',
          staff.jenisKelamin ?? '-',
          staff.tanggalBergabung ?? '-',
          staff.namaCabang ?? '-',
          staff.namaJabatan ?? '-',
          "-",
        ]);
      }

      String csvData = CsvCodec().encode(rows); // FIX: Menggunakan CsvCodec
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

  // --- 1b. UNDUH TEMPLATE (DOWNLOAD TEMPLATE) ---
  // Method untuk menyediakan template kosong dengan contoh pengisian
  Future<void> unduhTemplateCsv() async {
    try {
      List<List<dynamic>> rows = [
        ["Nama Lengkap", "NIP", "Email", "No HP", "Jenis Kelamin", "Tanggal Bergabung", "Lokasi Tugas", "Jabatan", "Password Sementara"],
        ["Ahmad Fulan", "12345678", "ahmad@email.com", "08123456789", "L", "2024-01-01", "Pusat", "Pengajar", "User123!"] // Baris Contoh
      ];

      String csvData = CsvCodec().encode(rows); // FIX: Menggunakan CsvCodec
      Uint8List bytes = Uint8List.fromList(csvData.codeUnits);

      await FilePicker.platform.saveFile(
        dialogTitle: 'Simpan Template Import Staff',
        fileName: 'Template_Import_Staff.csv',
        bytes: bytes,
      );
    } catch (e) {
      debugPrint("Gagal mengunduh template: $e");
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

    final fields = CsvCodec().decode(csvString); // FIX: Menggunakan CsvCodec

    for (int i = 1; i < fields.length; i++) {
      final row = fields[i];
      if (row.length < 3) continue;

      try {
        final nama = row[0].toString();
        final email = row[2].toString(); // Indeks Nama, NIP, Email (2)
        final noHp = row[3].toString();  // Indeks No HP (3)
        final password = row.length > 8 ? row[8].toString() : "User123!"; // Password di kolom ke-9

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