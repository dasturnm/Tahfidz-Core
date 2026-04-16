// Lokasi: lib/features/mutabaah/services/mutabaah_service.dart

import '../../../core/services/base_service.dart';
import '../models/mutabaah_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MutabaahTahfidzService extends BaseService {
  /// 1. LOGIKA KALKULASI HALAMAN & BARIS (Smart Calculation)
  /// Mengambil data koordinat dari tabel referensi data_mushaf
  Future<Map<String, dynamic>> calculateTahfidzPayload({
    required int surahMulai,
    required int ayatMulai,
    required int surahAkhir,
    required int ayatAkhir,
    double? targetAmount,
    String? targetUnit, // TAMBAHAN: Unit target untuk Independensi Metrik (v2026.04.16)
  }) async {
    try {
      // Mengambil page_number dan line_number dari data_mushaf
      final startData = await supabase
          .from('data_mushaf')
          .select('page_number, line_number')
          .match({'surah_number': surahMulai, 'ayah_number': ayatMulai})
          .limit(1)
          .single();

      final endData = await supabase
          .from('data_mushaf')
          .select('page_number, line_number')
          .match({'surah_number': surahAkhir, 'ayah_number': ayatAkhir})
          .limit(1)
          .single();

      int pageStart = startData['page_number'];
      int lineStart = startData['line_number'];
      int pageEnd = endData['page_number'];
      int lineEnd = endData['line_number'];

      // 1. Hitung total halaman (absolut)
      double totalPages = (pageEnd - pageStart).abs().toDouble();

      // 2. Hitung total baris (Logic: Posisi absolut baris di mushaf 15 baris)
      // Rumus: ((Halaman - 1) * 15 + Baris)
      int absoluteStart = ((pageStart - 1) * 15) + lineStart;
      int absoluteEnd = ((pageEnd - 1) * 15) + lineEnd;
      int totalLines = (absoluteEnd - absoluteStart).abs() + 1;

      // 3. Hitung total ayat (v2026.04.16: Menghitung row count records data_mushaf)
      // Query untuk menghitung jumlah baris di antara dua koordinat surah/ayat
      final ayahCountResponse = await supabase
          .from('data_mushaf')
          .select('id')
          .or('and(surah_number.eq.$surahMulai,ayah_number.gte.$ayatMulai),surah_number.gt.$surahMulai')
          .filter('surah_number', 'lte', surahAkhir);

      int totalAyahs = ayahCountResponse.length;

      // LOGIKA ESTIMASI & KOMPARASI (Poin 4 Blueprint: Independensi Metrik)
      bool isAchieved = true;
      double deficit = 0;
      int estimatedMeetings = 0;

      if (targetAmount != null && targetAmount > 0) {
        // Konversi realisasi ke unit yang diminta target (Halaman/Ayat/Baris)
        double volumeDone = totalLines.toDouble(); // Default Baris
        if (targetUnit == 'HALAMAN') volumeDone = totalLines / 15.0;
        if (targetUnit == 'AYAT') volumeDone = totalAyahs.toDouble();

        isAchieved = volumeDone >= targetAmount;
        deficit = isAchieved ? 0 : (targetAmount - volumeDone);

        // Menghitung berapa pertemuan yang dibutuhkan untuk rentang ini
        estimatedMeetings = (targetAmount > 0) ? (volumeDone / targetAmount).ceil() : 0;
      }

      return {
        "start_surah": surahMulai,
        "start_ayah": ayatMulai,
        "end_surah": surahAkhir,
        "end_ayah": ayatAkhir,
        "calculated_pages": totalPages,
        "calculated_lines": totalLines,
        "calculated_ayahs": totalAyahs,     // Info tambahan unit Ayat
        "is_target_met": isAchieved,        // Feedback untuk UI Guru
        "deficit_value": deficit,           // Info kekurangan (bisa desimal untuk Halaman)
        "estimated_meetings": estimatedMeetings, // Feedback untuk UI Admin
        "mushaf_standard": "Madinah 15 Lines (data_mushaf)"
      };
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// 2. READ: Mengambil riwayat mutabaah per siswa
  Future<List<MutabaahRecord>> getHistory(String siswaId) async {
    try {
      // FIX: Casting eksplisit untuk konsistensi tipe data
      PostgrestFilterBuilder query = supabase
          .from('mutabaah_records')
          .select('*, modul:modul_kurikulum(nama_modul)');

      final response = await (query as PostgrestFilterBuilder<PostgrestList>)
          .eq('siswa_id', siswaId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => MutabaahRecord.fromJson(json)).toList();
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// 3. READ: Mengambil seluruh riwayat (Mutabaah Hub)
  Future<List<MutabaahRecord>> getAllHistory() async {
    try {
      // FIX: Casting eksplisit untuk konsistensi tipe data
      PostgrestFilterBuilder query = supabase
          .from('mutabaah_records')
          .select('*, modul:modul_kurikulum(nama_modul)');

      final response = await (query as PostgrestFilterBuilder<PostgrestList>)
          .order('created_at', ascending: false);

      return (response as List).map((json) => MutabaahRecord.fromJson(json)).toList();
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// 4. CREATE: Menyimpan record mutabaah baru
  Future<void> submitRecord(MutabaahRecord record) async {
    try {
      // FIX: Gunakan cleanData dan toJson untuk proteksi input UUID/JSONB
      final data = cleanData(record.toJson());

      // Hapus ID jika null agar di-generate otomatis oleh DB
      if (record.id == null) {
        data.remove('id');
      }

      await supabase.from('mutabaah_records').insert(data);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }
}