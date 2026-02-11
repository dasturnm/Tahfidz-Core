import 'dart:convert';
import 'dart:io';
// ignore: deprecated_member_use
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/siswa_model.dart';

part 'siswa_provider.g.dart';

@riverpod
class SiswaList extends _$SiswaList {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<SiswaModel>> build() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    final profile = await _supabase.from('profiles').select('lembaga_id').eq('id', user.id).single();
    final lembagaId = profile['lembaga_id'];

    final response = await _supabase
        .from('siswa')
        .select('*, wali_kelas:profiles!guru_id(nama_lengkap), kelas:classes(name)')
        .eq('lembaga_id', lembagaId)
        .order('nama_lengkap', ascending: true);

    return (response as List).map((e) => SiswaModel.fromJson(e)).toList();
  }

  // --- FUNGSI IMPORT CSV ---
  Future<String> importSiswaFromCSV() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null) return "Batal memilih file";

      final file = File(result.files.single.path!);
      final input = file.openRead();
      final fields = await input
          .transform(utf8.decoder)
          .transform(const CsvToListConverter())
          .toList();

      if (fields.length < 2) return "File kosong atau tidak ada data";

      final user = _supabase.auth.currentUser;
      final profile = await _supabase.from('profiles').select('lembaga_id').eq('id', user!.id).single();
      final lembagaId = profile['lembaga_id'];

      List<Map<String, dynamic>> dataToInsert = [];

      for (int i = 1; i < fields.length; i++) {
        final row = fields[i];
        if (row.length < 2) continue;

        String nama = row[1].toString().trim();
        if (nama.isEmpty) continue;

        String rawGender = row[2].toString().toLowerCase();
        String gender = (rawGender.contains('p') || rawGender.contains('wanita')) ? 'P' : 'L';

        dataToInsert.add({
          'lembaga_id': lembagaId,
          'nama_lengkap': nama,
          'jenis_kelamin': gender,
          'nisn': row.length > 3 ? row[3].toString() : null,
          'alamat': row.length > 4 ? row[4].toString() : null,
          'created_by': user.id,
        });
      }

      if (dataToInsert.isEmpty) return "Tidak ada data valid";

      await _supabase.from('siswa').insert(dataToInsert);

      // ignore: invalid_use_of_visible_for_testing_member
      ref.invalidateSelf();

      return "Berhasil import ${dataToInsert.length} siswa!";
    } catch (e) {
      return "Gagal Import: $e";
    }
  }

  // --- FUNGSI EXPORT CSV ---
  Future<void> exportSiswaToCSV() async {
    try {
      final currentData = state.value;
      if (currentData == null || currentData.isEmpty) throw "Data kosong";

      List<List<dynamic>> rows = [];
      rows.add(["No", "Nama Lengkap", "Jenis Kelamin", "NISN", "Alamat", "Wali Kelas"]);

      for (int i = 0; i < currentData.length; i++) {
        final item = currentData[i];
        final wali = item.namaWaliKelas ?? '-';

        rows.add([
          i + 1,
          item.namaLengkap,
          item.jenisKelamin,
          item.nisn ?? '',
          item.alamat ?? '',
          wali
        ]);
      }

      String csv = const ListToCsvConverter().convert(rows);

      final directory = await getTemporaryDirectory();
      final path = "${directory.path}/data_siswa_export.csv";
      final file = File(path);
      await file.writeAsString(csv);

      // ignore: deprecated_member_use
      await Share.shareXFiles([XFile(path)], text: 'Export Data Siswa');

    } catch (e) {
      throw "Gagal Export: $e";
    }
  }

  // --- FUNGSI TAMBAH MANUAL ---
  Future<void> tambahSiswa({
    required String nama,
    required String jenisKelamin,
    required String? guruId,
    String? classId,
    String? nisn,
    String? alamat,
  }) async {
    final user = _supabase.auth.currentUser;
    final profile = await _supabase.from('profiles').select('lembaga_id').eq('id', user!.id).single();

    await _supabase.from('siswa').insert({
      'lembaga_id': profile['lembaga_id'],
      'nama_lengkap': nama,
      'jenis_kelamin': jenisKelamin,
      'guru_id': guruId,
      'class_id': classId,
      'nisn': nisn,
      'alamat': alamat,
      'created_by': user.id,
    });

    // ignore: invalid_use_of_visible_for_testing_member
    ref.invalidateSelf();
  }

  // --- FUNGSI UPDATE KURIKULUM & LEVEL SISWA ---
  Future<void> updateKurikulum({
    required String siswaId,
    required String kurikulumId,
    required String levelId,
  }) async {
    await _supabase.from('siswa').update({
      'kurikulum_id': kurikulumId,
      'current_level_id': levelId,
    }).eq('id', siswaId);

    // Refresh data agar UI terupdate
    // ignore: invalid_use_of_visible_for_testing_member
    ref.invalidateSelf();
  }
}