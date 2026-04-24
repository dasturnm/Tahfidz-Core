// Lokasi: lib/features/kelas/services/kelas_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/base_service.dart';
import '../models/kelas_model.dart';

part 'kelas_service.g.dart';

@riverpod
KelasService kelasService(Ref ref) {
  return KelasService();
}

class KelasService extends BaseService {
  /// MENGAMBIL DAFTAR KELAS (Read)
  /// 🔥 SMART: Mengambil lembagaId otomatis dari context (Aturan 7)
  Future<List<KelasModel>> getKelas(Ref ref) async {
    try {
      final lembagaId = getLembagaId(ref);

      PostgrestFilterBuilder query = supabase
          .from('kelas')
          .select('''
            *,
            guru:profiles (*),
            program (*)
          ''');

      // 🛡️ KEAMANAN: Menggunakan helper filter dari BaseService
      query = applyLembagaFilter(query: query, lembagaId: lembagaId);

      // FIX: Menggunakan nama kolom yang benar (nama_kelas) sesuai standar table lain
      final response = await query.order('nama_kelas', ascending: true);

      return (response as List)
          .map((json) => KelasModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// MENGAMBIL SATU KELAS BERDASARKAN ID (Read Detail)
  /// 🔥 Protokol v2026.03.22: WAJIB applyLembagaFilter
  Future<KelasModel> getKelasById(Ref ref, String id) async {
    try {
      final lembagaId = getLembagaId(ref);

      PostgrestFilterBuilder query = supabase
          .from('kelas')
          .select('''
            *,
            guru:profiles (*),
            program (*)
          ''');

      // 🛡️ KEAMANAN: Filter lembaga diwajibkan untuk mencegah data leak
      query = applyLembagaFilter(query: query, lembagaId: lembagaId);

      final response = await query.eq('id', id).single();

      return KelasModel.fromJson(response);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// MENAMBAHKAN KELAS BARU (Create)
  Future<void> addKelas(KelasModel newKelas) async {
    try {
      // Membersihkan data sebelum dikirim ke database
      final data = cleanData(newKelas.toJson());
      await supabase.from('kelas').insert(data);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// MEMPERBARUI DATA KELAS (Update)
  Future<void> updateKelas(KelasModel updatedKelas) async {
    if (updatedKelas.id == null) {
      throw Exception('ID Kelas tidak ditemukan untuk proses update.');
    }

    try {
      final data = cleanData(updatedKelas.toJson());
      await supabase
          .from('kelas')
          .update(data)
          .eq('id', updatedKelas.id!);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// MENGHAPUS KELAS (Delete)
  Future<void> deleteKelas(String id) async {
    try {
      // 🛡️ SAFE DELETE: Cek apakah masih ada siswa di kelas ini (Aturan 12 - Predictable)
      final checkSiswa = await supabase
          .from('siswa')
          .select('id')
          .eq('kelas_id', id)
          .limit(1);

      if ((checkSiswa as List).isNotEmpty) {
        throw 'Gagal menghapus: Kelas masih memiliki siswa aktif. Pindahkan siswa ke kelas lain atau kosongkan kelas terlebih dahulu.';
      }

      await supabase.from('kelas').delete().eq('id', id);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }
}