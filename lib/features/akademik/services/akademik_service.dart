// Lokasi: lib/features/akademik/services/akademik_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../program/models/program_model.dart';

// Model Sederhana untuk Level Kurikulum (Disisipkan di sini agar praktis)
class LevelModel {
  final String id;
  final String namaLevel;

  LevelModel({required this.id, required this.namaLevel});

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return LevelModel(
      id: json['id'].toString(),
      namaLevel: json['nama_level'] ?? 'Tanpa Nama',
    );
  }
}

class AkademikService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Mengambil daftar semua Program yang statusnya 'aktif'
  Future<List<ProgramModel>> getPrograms() async {
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
  Future<List<LevelModel>> getLevels() async {
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