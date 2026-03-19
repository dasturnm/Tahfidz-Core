// Lokasi: lib/features/akademik/services/akademik_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../program/models/program_model.dart';
import '../kurikulum/models/kurikulum_model.dart'; // Tambahan: Menggunakan model terpusat

class AkademikService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Mengambil daftar semua Program yang statusnya 'aktif'
  Future<List<ProgramModel>> getProgram() async { // PERBAIKAN: Singular
    try {
      final response = await _supabase
          .from('program')
          .select()
          .eq('status', 'aktif') // Hanya ambil program yang masih aktif
          .order('nama_program', ascending: true);

      return (response as List).map((json) => ProgramModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data Program: $e');
    }
  }

  /// Mengambil daftar semua Level dari kurikulum_level
  Future<List<LevelModel>> getLevel() async {
    try {
      final response = await _supabase
          .from('kurikulum_level')
          .select()
          .order('nama_level', ascending: true);

      return (response as List).map((json) => LevelModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data Level: $e');
    }
  }
}