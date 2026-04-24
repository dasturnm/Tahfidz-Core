// Lokasi: lib/features/siswa/services/siswa_service.dart

import 'dart:io'; // TAMBAHAN
import 'dart:typed_data'; // TAMBAHAN
import 'package:csv/csv.dart'; // TAMBAHAN
import 'package:file_picker/file_picker.dart'; // TAMBAHAN
import 'package:path_provider/path_provider.dart'; // TAMBAHAN
import 'package:share_plus/share_plus.dart'; // TAMBAHAN
import 'package:flutter/material.dart'; // TAMBAHAN
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/base_service.dart';
import '../models/siswa_model.dart';

part 'siswa_service.g.dart';

@riverpod
SiswaService siswaService(Ref ref) {
  return SiswaService();
}

class SiswaService extends BaseService {
  /// 1. READ: Mengambil semua data siswa (Untuk Tab Database Siswa)
  /// 🔥 SMART: Mengambil lembagaId otomatis dari context
  Future<List<SiswaModel>> getSiswa(Ref ref) async {
    try {
      final lembagaId = getLembagaId(ref);

      // FIX: Menggunakan Left Join agar siswa muncul meski data relasi (kelas/level) ada yang kosong
      PostgrestFilterBuilder query = supabase
          .from('siswa')
          .select('''
            *,
            kelas (*),
            program (*),
            kurikulum_level!level_id (*),
            guru:profiles (*)
          ''');

      // 🔥 EXPLICIT-SAFE: Gunakan helper dari BaseService tanpa casting berlebihan
      query = applyLembagaFilter(query: query, lembagaId: lembagaId);

      final response = await query.order('nama_lengkap', ascending: true);

      return (response as List)
          .map((json) => SiswaModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// 2. READ BY KELAS: Mengambil siswa berdasarkan Kelas (Untuk Detail Kelas)
  /// 🔥 Protokol v2026.03.22: WAJIB applyLembagaFilter
  Future<List<SiswaModel>> getSiswaByKelas(Ref ref, String kelasId) async {
    try {
      final lembagaId = getLembagaId(ref);

      // FIX: Menghapus tanda '!' untuk mencegah siswa hilang jika level/guru belum diset
      PostgrestFilterBuilder query = supabase
          .from('siswa')
          .select('''
            *,
            kelas (*),
            program (*),
            kurikulum_level!level_id (*),
            guru:profiles (*)
          ''');

      query = applyLembagaFilter(query: query, lembagaId: lembagaId);

      final response = await query
          .eq('kelas_id', kelasId)
          .order('nama_lengkap', ascending: true);

      return (response as List)
          .map((json) => SiswaModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// 2a. READ BY GURU: Mengambil santri bimbingan langsung
  Future<List<SiswaModel>> fetchSiswaByGuru(Ref ref, String guruId) async {
    try {
      final lembagaId = getLembagaId(ref);
      PostgrestFilterBuilder query = supabase.from('siswa').select('''
            *,
            kelas (*),
            program (*),
            kurikulum_level!level_id (*),
            guru:profiles (*)
          ''');

      query = applyLembagaFilter(query: query, lembagaId: lembagaId);

      final response = await query
          .eq('guru_id', guruId)
          .order('nama_lengkap', ascending: true);

      return (response as List).map((json) => SiswaModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// 2b. READ BY WALI KELAS: Mengambil santri berdasarkan Kelas yang diampu
  Future<List<SiswaModel>> fetchSiswaByWaliKelas(Ref ref, String guruId) async {
    try {
      final lembagaId = getLembagaId(ref);
      // Menggunakan !inner untuk melakukan filter berdasarkan kolom di tabel relasi (kelas)
      PostgrestFilterBuilder query = supabase.from('siswa').select('''
            *,
            kelas!inner(*),
            program (*),
            kurikulum_level!level_id (*),
            guru:profiles (*)
          ''');

      query = applyLembagaFilter(query: query, lembagaId: lembagaId);

      final response = await query
          .eq('kelas.guru_id', guruId)
          .order('nama_lengkap', ascending: true);

      return (response as List).map((json) => SiswaModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// 2c. READ BY LEMBAGA: Mengambil semua siswa dalam satu lembaga (Untuk Admin/Pengganti)
  Future<List<SiswaModel>> getSiswaByLembaga(Ref ref) async {
    try {
      final lembagaId = getLembagaId(ref);
      PostgrestFilterBuilder query = supabase.from('siswa').select('''
            *,
            kelas (*),
            program (*),
            kurikulum_level!level_id (*),
            guru:profiles (*)
          ''');

      query = applyLembagaFilter(query: query, lembagaId: lembagaId);

      final response = await query.order('nama_lengkap', ascending: true);
      return (response as List).map((json) => SiswaModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// 3. CREATE: Menambahkan siswa baru
  Future<void> addSiswa(SiswaModel siswa) async {
    try {
      String? targetLembagaId = siswa.lembagaId;
      String? targetLevelId = siswa.levelId;

      // 🛡️ SYNC LEMBAGA: Pastikan siswa mengikuti lembaga_id dari Kelas yang dipilih
      if (siswa.kelasId != null) {
        final classData = await supabase
            .from('kelas')
            .select('program_id, lembaga_id')
            .eq('id', siswa.kelasId!)
            .single();

        targetLembagaId = classData['lembaga_id']; // Paksa sinkron ke lembaga kelas

        if (siswa.programId != null && classData['program_id'] != siswa.programId) {
          throw Exception('Peringatan Keamanan: Program siswa tidak cocok dengan Program pada Kelas yang dipilih.');
        }
      }

      // 🎯 AUTO-ASSIGN LEVEL: Hubungkan siswa ke level pertama jika level_id kosong
      if (targetLevelId == null && siswa.programId != null) {
        final firstLevel = await supabase
            .from('kurikulum_level')
            .select('id')
            .eq('program_id', siswa.programId!)
            .order('urutan', ascending: true)
            .limit(1)
            .maybeSingle();

        targetLevelId = firstLevel?['id'];
      }

      // 🔥 FINAL OBJECT: Gunakan copyWith untuk menyisipkan targetLembagaId dan targetLevelId
      final finalSiswa = siswa.copyWith(
        lembagaId: targetLembagaId,
        levelId: targetLevelId,
        currentLevelId: targetLevelId,
      );

      final data = cleanData(finalSiswa.toJson());

      // FIX: Menghapus ID null agar UUID di-generate otomatis oleh Supabase
      if (finalSiswa.id == null || (finalSiswa.id?.isEmpty ?? true)) {
        data.remove('id');
      }

      await supabase.from('siswa').insert(data);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// 4. UPDATE: Memperbarui data siswa
  Future<void> updateSiswa(SiswaModel siswa) async {
    if (siswa.id == null) throw Exception('ID siswa tidak ditemukan');

    try {
      String? targetLembagaId = siswa.lembagaId;
      String? targetLevelId = siswa.levelId;

      // 🛡️ SYNC LEMBAGA pada Update
      if (siswa.kelasId != null) {
        final classData = await supabase
            .from('kelas')
            .select('program_id, lembaga_id')
            .eq('id', siswa.kelasId!)
            .single();

        targetLembagaId = classData['lembaga_id'];

        if (siswa.programId != null && classData['program_id'] != siswa.programId) {
          throw Exception('Peringatan Keamanan: Program siswa tidak cocok dengan Program pada Kelas yang dipilih.');
        }
      }

      // 🎯 AUTO-ASSIGN LEVEL: Hubungkan siswa ke level pertama jika program berubah dan level kosong
      if (targetLevelId == null && siswa.programId != null) {
        final firstLevel = await supabase
            .from('kurikulum_level')
            .select('id')
            .eq('program_id', siswa.programId!)
            .order('urutan', ascending: true)
            .limit(1)
            .maybeSingle();

        targetLevelId = firstLevel?['id'];
      }

      final finalSiswa = siswa.copyWith(
        lembagaId: targetLembagaId,
        levelId: targetLevelId,
        currentLevelId: targetLevelId,
      );

      final data = cleanData(finalSiswa.toJson());
      await supabase
          .from('siswa')
          .update(data)
          .eq('id', finalSiswa.id!);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// 5. DELETE: Menghapus siswa
  Future<void> deleteSiswa(String id) async {
    try {
      await supabase.from('siswa').delete().eq('id', id);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// 6. PLOTTING: Memasukkan/Mengeluarkan siswa dari Kelas
  Future<void> assignSiswaToKelas(String siswaId, String? kelasId) async {
    try {
      // FIX: Jangan gunakan cleanData agar nilai null (untuk unplotting) tidak terhapus
      await supabase
          .from('siswa')
          .update({'kelas_id': kelasId})
          .eq('id', siswaId);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// 7. BULK CREATE: Import siswa dalam jumlah banyak
  Future<void> bulkAddSiswa(List<SiswaModel> siswa) async {
    try {
      final data = siswa.map((s) => cleanData(s.toJson())).toList();
      await supabase.from('siswa').insert(data);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// 8. BULK PLOTTING: Memasukkan banyak siswa ke dalam satu Kelas sekaligus
  Future<void> bulkAssignSiswaToKelas(List<String> siswaIds, String? kelasId) async {
    try {
      // FIX: Menggunakan .filter dengan operator 'in' sebagai pengganti .in_ untuk menghindari error undefined_method
      await supabase
          .from('siswa')
          .update({'kelas_id': kelasId})
          .filter('id', 'in', siswaIds);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// 9. CSV: Export data siswa ke file CSV
  Future<void> exportSiswaKeCsv(List<SiswaModel> listSiswa) async {
    List<List<dynamic>> rows = [
      ["Nama Lengkap", "NISN", "Email", "No HP", "Jenis Kelamin", "Tanggal Lahir", "Alamat", "Status", "Password Sementara"]
    ];

    for (var s in listSiswa) {
      rows.add([
        s.namaLengkap,
        s.nisn ?? '-',
        s.email ?? '-',
        s.noHp ?? '-',
        s.jenisKelamin,
        s.tglLahir?.toIso8601String().split('T')[0] ?? '-',
        s.alamat ?? '-',
        s.status,
        "-", // Password tidak di-export
      ]);
    }

    String csvData = CsvCodec().encode(rows); // FIX: Menghapus const karena bukan const constructor
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/Export_Siswa_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csvData);

    // FIX: Gunakan class Share langsung dari package share_plus
    await Share.shareXFiles([XFile(file.path)], subject: 'Export Data Siswa');
  }

  /// 10. CSV: Unduh Template Kosong Siswa
  Future<void> unduhTemplateSiswaCsv() async {
    try {
      List<List<dynamic>> rows = [
        ["Nama Lengkap", "NISN", "Email", "No HP", "Jenis Kelamin", "Tanggal Lahir", "Alamat", "Status", "Password Sementara"],
        ["Zaidan Akram", "123456789", "wali.zaidan@email.com", "08123456789", "L", "2015-05-20", "Jl. Melati No. 12", "aktif", "Siswa123!"]
      ];

      String csvData = CsvCodec().encode(rows); // FIX: Menghapus const karena bukan const constructor
      Uint8List bytes = Uint8List.fromList(csvData.codeUnits);

      await FilePicker.platform.saveFile(
        dialogTitle: 'Simpan Template Import Siswa',
        fileName: 'Template_Import_Siswa.csv',
        bytes: bytes,
      );
    } catch (e) {
      debugPrint("Gagal mengunduh template: $e");
    }
  }

  /// 11. CSV: Import data siswa dari file CSV
  Future<Map<String, int>> importSiswaDariCsv({
    required String lembagaId,
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
    final fields = CsvCodec().decode(csvString); // FIX: Menghapus const karena bukan const constructor

    for (int i = 1; i < fields.length; i++) {
      final row = fields[i];
      if (row.length < 5) continue;

      try {
        final siswa = SiswaModel(
          lembagaId: lembagaId,
          namaLengkap: row[0].toString(),
          nisn: row[1].toString(),
          email: row[2].toString(),
          noHp: row[3].toString(),
          jenisKelamin: row[4].toString().toUpperCase(),
          tglLahir: DateTime.tryParse(row[5].toString()),
          alamat: row[6].toString(),
          status: row[7].toString().toLowerCase(),
        );

        await addSiswa(siswa);
        sukses++;
      } catch (e) {
        gagal++;
        debugPrint("Gagal import siswa baris $i: $e");
      }
    }

    onComplete();
    return {'sukses': sukses, 'gagal': gagal};
  }
}