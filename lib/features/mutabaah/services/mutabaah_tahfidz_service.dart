// lib/features/mutabaah/services/mutabaah_tahfidz_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class MutabaahTahfidzService {
  final _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> calculateTahfidzPayload({
    required int surahMulai,
    required int ayatMulai,
    required int surahAkhir,
    required int ayatAkhir,
  }) async {
    // 1. Ambil data halaman dari tabel quran_lines kamu
    final startData = await _supabase
        .from('quran_lines')
        .select('page')
        .match({'surah': surahMulai, 'ayah': ayatMulai})
        .limit(1)
        .single();

    final endData = await _supabase
        .from('quran_lines')
        .select('page')
        .match({'surah': surahAkhir, 'ayah': ayatAkhir})
        .limit(1)
        .single();

    int pageStart = startData['page'];
    int pageEnd = endData['page'];

    // 2. Hitung selisih halaman (Smart Calculation)
    double totalPages = (pageEnd - pageStart).abs() + 0.1; // +0.1 sebagai asumsi minimal 1 baris

    // 3. Kembalikan dataPayload yang siap dipakai model
    return {
      "start_surah": surahMulai,
      "start_ayah": ayatMulai,
      "end_surah": surahAkhir,
      "end_ayah": ayatAkhir,
      "calculated_pages": totalPages,
      "mushaf_standard": "Madinah/Kemenag (quran_lines)"
    };
  }
}