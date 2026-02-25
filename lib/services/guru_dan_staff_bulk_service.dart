import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart'; // Opsional: Untuk membagikan file hasil export
import '../features/guru_staff/models/staff_model.dart';
import '../features/guru_staff/providers/staff_provider.dart';
import '../features/guru_staff/providers/penugasan_staf_provider.dart';
import 'auth_service.dart';

part 'guru_dan_staff_bulk_service.g.dart';

@riverpod
GuruDanStaffBulkService guruDanStaffBulkService(Ref ref) {
  return GuruDanStaffBulkService(ref);
}

class GuruDanStaffBulkService {
  final Ref _ref;
  GuruDanStaffBulkService(this._ref);

  // --- 1. EXPORT DATA KE CSV ---
  Future<void> exportKeCsv(List<StaffModel> listStaff) async {
    // Header sesuai dengan prototype React Anda
    List<List<dynamic>> rows = [
      ["Nama Lengkap", "NIP", "Nomor HP", "Email", "Jabatan", "Cabang", "Status"]
    ];

    // Mapping data staff ke baris CSV
    for (var staff in listStaff) {
      rows.add([
        staff.nama,
        staff.id?.substring(0, 8).toUpperCase() ?? '-',
        staff.kontak ?? '-',
        "-", // Email biasanya sensitif, bisa dikosongkan atau ambil dari auth
        staff.namaJabatan ?? '-',
        staff.namaCabang ?? '-',
        staff.isActive ? "AKTIF" : "NONAKTIF",
      ]);
    }

    // Menggunakan API baru dari csv v7.0.0+
    String csvData = CsvCodec().encode(rows);

    // Simpan ke file sementara dan bagikan/download
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/Data_Guru_Dan_Staff_${DateTime.now().millisecondsSinceEpoch}.csv');

    await file.writeAsString(csvData);

    // Gunakan share_plus agar user bisa memilih simpan ke Files atau kirim ke WA
    // ignore: deprecated_member_use
    await Share.shareXFiles([XFile(file.path)], text: 'Export Data Guru dan Staff');
  }

  // --- 2. IMPORT DATA DARI CSV ---
  Future<Map<String, int>> importDariCsv({
    required String lembagaId,
    required String defaultJabatanId,
    required String defaultCabangId,
  }) async {
    int sukses = 0;
    int gagal = 0;

    // 1. Pilih File
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result == null) return {'sukses': 0, 'gagal': 0};

    final file = File(result.files.single.path!);

    // Menggunakan API baru dari csv v7.0.0+ (Membaca file utuh lalu di-decode)
    final csvString = await file.readAsString();
    final fields = CsvCodec().decode(csvString);

    // 2. Looping Data (Lewati baris pertama/header)
    for (int i = 1; i < fields.length; i++) {
      final row = fields[i];
      if (row.length < 3) continue; // Skip baris kosong

      try {
        final nama = row[0].toString();
        final email = row[3].toString(); // Asumsi kolom 4 adalah email
        final noHp = row[2].toString();
        const password = "User123!"; // Password default untuk mass import

        // A. Register Auth & Profile
        final String? newUserId = await _ref.read(authServiceProvider).registerGuru(
          nama: nama,
          email: email,
          noHp: noHp,
          password: password,
          lembagaId: lembagaId,
        );

        // B. Berikan Penugasan Default
        if (newUserId != null) {
          await _ref.read(penugasanStafProvider.notifier).tambahPenugasan(
            stafId: newUserId,
            cabangId: defaultCabangId,
            jabatanId: defaultJabatanId,
          );
          sukses++;
        }
      } catch (e) {
        gagal++;
        debugPrint("Gagal import baris $i: $e");
      }
    }

    // Refresh data setelah selesai import massal
    _ref.invalidate(staffListProvider);

    return {'sukses': sukses, 'gagal': gagal};
  }
}