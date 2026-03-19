// Lokasi: lib/features/siswa/services/siswa_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/siswa_model.dart'; // Pastikan path ini sesuai

class SiswaService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 1. READ: Mengambil semua data siswa (Untuk Tab Database Siswa)
  Future<List<SiswaModel>> getSiswa({required String lembagaId}) async {
    try {
      // Mengambil data siswa beserta relasi kelas, program, dan levelnya
      final response = await _supabase
          .from('siswa')
          .select('''
            *,
            kelas (*),
            program (*),
            kurikulum_level (*),
            guru:profiles (*)
          ''') // FIX: Tambahkan join profile dengan alias guru
          .eq('lembaga_id', lembagaId) // FIX: Filter berdasarkan lembagaId
          .order('nama_lengkap', ascending: true);

      // FIX: Tambahkan log untuk melacak aliran data dari database
      print("DEBUG SISWA: lembagaId yang dicari = $lembagaId");
      print("DEBUG SISWA: Jumlah data ditarik = ${(response as List).length}");

      return (response as List)
          .map((json) => SiswaModel.fromJson(json))
          .toList();
    } catch (e) {
      print("DEBUG SISWA ERROR: $e"); // FIX: Print error untuk deteksi masalah Join/RLS
      throw Exception('Gagal mengambil data siswa: $e');
    }
  }

  /// 2. READ BY KELAS: Mengambil siswa berdasarkan Kelas (Untuk Detail Kelas)
  Future<List<SiswaModel>> getSiswaByKelas(String kelasId) async {
    try {
      final response = await _supabase
          .from('siswa')
          .select('''
            *,
            kelas (*),
            program (*),
            kurikulum_level (*),
            guru:profiles (*)
          ''') // FIX: Tambahkan join profile dengan alias guru
          .eq('kelas_id', kelasId)
          .order('nama_lengkap', ascending: true);

      return (response as List)
          .map((json) => SiswaModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil data siswa di kelas ini: $e');
    }
  }

  /// 3. CREATE: Menambahkan siswa baru
  Future<void> addSiswa(SiswaModel siswa) async {
    try {
      // FIX: Hapus field 'id' jika null agar UUID auto-generate bekerja di Supabase
      final data = siswa.toJson();
      if (siswa.id == null) {
        data.remove('id');
      }
      await _supabase.from('siswa').insert(data);
    } catch (e) {
      throw Exception('Gagal menambahkan siswa baru: $e');
    }
  }

  /// 4. UPDATE: Memperbarui data siswa
  Future<void> updateSiswa(SiswaModel siswa) async {
    if (siswa.id == null) throw Exception('ID siswa tidak ditemukan');

    try {
      await _supabase
          .from('siswa')
          .update(siswa.toJson())
          .eq('id', siswa.id!);
    } catch (e) {
      throw Exception('Gagal memperbarui data siswa: $e');
    }
  }

  /// 5. DELETE: Menghapus siswa
  Future<void> deleteSiswa(String id) async {
    try {
      await _supabase.from('siswa').delete().eq('id', id);
    } catch (e) {
      throw Exception('Gagal menghapus data siswa: $e');
    }
  }

  /// 6. PLOTTING: Memasukkan/Mengeluarkan siswa dari Kelas
  /// Jika kelasId null, artinya siswa dikeluarkan dari kelas (Unassigned)
  Future<void> assignSiswaToKelas(String siswaId, String? kelasId) async {
    try {
      await _supabase
          .from('siswa')
          .update({'kelas_id': kelasId}) // Hanya mengupdate kolom kelas_id
          .eq('id', siswaId);
    } catch (e) {
      throw Exception('Gagal melakukan plotting siswa: $e');
    }
  }

  /// 7. BULK CREATE: Import siswa dalam jumlah banyak (Untuk Import CSV)
  Future<void> bulkAddSiswa(List<SiswaModel> siswa) async {
    try {
      final data = siswa.map((s) => s.toJson()).toList();
      await _supabase.from('siswa').insert(data);
    } catch (e) {
      throw Exception('Gagal mengimpor data siswa: $e');
    }
  }

  /// 8. BULK PLOTTING: Memasukkan banyak siswa ke dalam satu Kelas sekaligus
  Future<void> bulkAssignSiswaToKelas(List<String> siswaIds, String? kelasId) async {
    try {
      await _supabase
          .from('siswa')
          .update({'kelas_id': kelasId})
          .filter('id', 'in', siswaIds); // FIX: Menggunakan .filter('in') untuk list UUID agar kompatibel dengan SDK
    } catch (e) {
      throw Exception('Gagal melakukan plotting masal santri: $e');
    }
  }
}