import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/kelas_model.dart';

class ClassService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// MENGAMBIL DAFTAR KELAS (Read)
  /// Mengambil semua kelas beserta data Wali Kelas dan Program (menggunakan fitur JOIN)
  Future<List<KelasModel>> getClasses() async {
    try {
      // Query ini akan mengambil semua kolom di 'classes',
      // ditambah data dari tabel 'profiles' dan 'program' yang terhubung.
      final response = await _supabase
          .from('classes')
          .select('''
            *,
            profiles (*),
            program (*)
          ''')
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
  Future<KelasModel> getClassById(String id) async {
    try {
      final response = await _supabase
          .from('classes')
          .select('''
            *,
            profiles (*),
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
  Future<void> addClass(KelasModel newClass) async {
    try {
      await _supabase.from('classes').insert(newClass.toJson());
    } catch (e) {
      throw Exception('Gagal menambahkan kelas baru: $e');
    }
  }

  /// MEMPERBARUI DATA KELAS (Update)
  Future<void> updateClass(KelasModel updatedClass) async {
    if (updatedClass.id == null) {
      throw Exception('ID Kelas tidak ditemukan untuk proses update.');
    }

    try {
      await _supabase
          .from('classes')
          .update(updatedClass.toJson())
          .eq('id', updatedClass.id!);
    } catch (e) {
      throw Exception('Gagal memperbarui kelas: $e');
    }
  }

  /// MENGHAPUS KELAS (Delete)
  Future<void> deleteClass(String id) async {
    try {
      await _supabase.from('classes').delete().eq('id', id);
    } catch (e) {
      throw Exception('Gagal menghapus kelas: $e');
    }
  }
}