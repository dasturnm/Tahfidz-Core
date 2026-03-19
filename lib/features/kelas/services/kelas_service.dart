// Lokasi: lib/features/kelas/services/kelas_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/kelas_model.dart';

class KelasService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// MENGAMBIL DAFTAR KELAS (Read)
  /// Mengambil semua kelas beserta data Wali Kelas dan Program (menggunakan fitur JOIN)
  Future<List<KelasModel>> getKelas({required String lembagaId}) async {
    try {
      // Mengambil data dari tabel 'kelas' dengan alias 'guru' untuk profil wali kelas
      final response = await _supabase
          .from('kelas')
          .select('''
            *,
            guru:profiles (*),
            program (*)
          ''')
          .eq('lembaga_id', lembagaId) // FIX: Filter berdasarkan lembagaId
          .order('name', ascending: true);

      // Mengubah respons JSON menjadi List<KelasModel>
      return (response as List)
          .map((json) => KelasModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil data kelas: $e');
    }
  }

  /// MENGAMBIL SATU KELAS BERDASARKAN ID (Read Detail)
  Future<KelasModel> getKelasById(String id) async {
    try {
      final response = await _supabase
          .from('kelas')
          .select('''
            *,
            guru:profiles (*),
            program (*)
          ''')
          .eq('id', id)
          .single();

      return KelasModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengambil detail kelas: $e');
    }
  }

  /// MENAMBAHKAN KELAS BARU (Create)
  Future<void> addKelas(KelasModel newKelas) async {
    try {
      await _supabase.from('kelas').insert(newKelas.toJson());
    } catch (e) {
      throw Exception('Gagal menambahkan kelas baru: $e');
    }
  }

  /// MEMPERBARUI DATA KELAS (Update)
  Future<void> updateKelas(KelasModel updatedKelas) async {
    if (updatedKelas.id == null) {
      throw Exception('ID Kelas tidak ditemukan untuk proses update.');
    }

    try {
      await _supabase
          .from('kelas')
          .update(updatedKelas.toJson())
          .eq('id', updatedKelas.id!);
    } catch (e) {
      throw Exception('Gagal memperbarui kelas: $e');
    }
  }

  /// MENGHAPUS KELAS (Delete)
  Future<void> deleteKelas(String id) async {
    try {
      await _supabase.from('kelas').delete().eq('id', id);
    } catch (e) {
      throw Exception('Gagal menghapus kelas: $e');
    }
  }
}