// Lokasi: lib/features/siswa/services/siswa_service.dart

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

      // FIX: Gunakan tipe data eksplisit untuk menghindari error invalid_assignment
      PostgrestFilterBuilder query = supabase
          .from('siswa')
          .select('''
            *,
            kelas (*),
            program (*),
            kurikulum_level (*),
            guru:profiles (*)
          ''');

      // 🔥 EXPLICIT-SAFE: Gunakan helper dari BaseService
      // FIX: Casting ke PostgrestFilterBuilder<PostgrestList> untuk konsistensi linting
      query = applyLembagaFilter(query: query, lembagaId: lembagaId) as PostgrestFilterBuilder<PostgrestList>;

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

      PostgrestFilterBuilder query = supabase
          .from('siswa')
          .select('''
            *,
            kelas (*),
            program (*),
            kurikulum_level (*),
            guru:profiles (*)
          ''');

      // FIX: Casting ke PostgrestFilterBuilder<PostgrestList>
      query = applyLembagaFilter(query: query, lembagaId: lembagaId) as PostgrestFilterBuilder<PostgrestList>;

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
            kurikulum_level (*),
            guru:profiles (*)
          ''');

      query = applyLembagaFilter(query: query, lembagaId: lembagaId) as PostgrestFilterBuilder<PostgrestList>;

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
            kurikulum_level (*),
            guru:profiles (*)
          ''');

      query = applyLembagaFilter(query: query, lembagaId: lembagaId) as PostgrestFilterBuilder<PostgrestList>;

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
            kurikulum_level (*),
            guru:profiles (*)
          ''');

      query = applyLembagaFilter(query: query, lembagaId: lembagaId) as PostgrestFilterBuilder<PostgrestList>;

      final response = await query.order('nama_lengkap', ascending: true);
      return (response as List).map((json) => SiswaModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// 3. CREATE: Menambahkan siswa baru
  Future<void> addSiswa(SiswaModel siswa) async {
    try {
      // 🔥 CLEAN: Pastikan tidak ada string 'null' yang masuk ke DB
      final data = cleanData(siswa.toJson());

      // FIX: Menghapus ID null agar UUID di-generate otomatis oleh Supabase
      if (siswa.id == null || (siswa.id?.isEmpty ?? true)) {
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
      final data = cleanData(siswa.toJson());
      await supabase
          .from('siswa')
          .update(data)
          .eq('id', siswa.id!);
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
      await supabase
          .from('siswa')
          .update(cleanData({'kelas_id': kelasId}))
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
      await supabase
          .from('siswa')
          .update(cleanData({'kelas_id': kelasId}))
          .filter('id', 'in', siswaIds); // FIX: Menggunakan filter 'in' standar Supabase
    } catch (e) {
      throw Exception(handleError(e));
    }
  }
}