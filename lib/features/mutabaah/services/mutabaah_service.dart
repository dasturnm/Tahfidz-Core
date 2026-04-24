// Lokasi: lib/features/mutabaah/services/mutabaah_service.dart

import '../../../core/services/base_service.dart';
import '../models/mutabaah_model.dart';
import '../models/delegasi_model.dart';
import '../../akademik/kurikulum/models/kurikulum_model.dart'; // TAMBAHAN
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // TAMBAHAN
import '../../../core/providers/app_context_provider.dart'; // TAMBAHAN

class MutabaahTahfidzService extends BaseService {
  /// 1. LOGIKA KALKULASI HALAMAN & BARIS (Smart Calculation)
  /// Mengambil data koordinat dari tabel referensi data_mushaf
  Future<Map<String, dynamic>> calculateTahfidzPayload({
    required int surahMulai,
    required int ayatMulai,
    required int surahAkhir,
    required int ayatAkhir,
    double? targetAmount,
    double previousDebt = 0.0, // TAMBAHAN: Saldo hutang dari pertemuan sebelumnya
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

        // FIX: Target Riil = Target Modul + Hutang Sebelumnya
        final double totalTarget = targetAmount + previousDebt;
        isAchieved = volumeDone >= totalTarget;
        deficit = isAchieved ? 0 : (totalTarget - volumeDone);

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

  /// 3b. READ: Mengambil riwayat mutabaah berdasarkan lembaga (Mutabaah Hub)
  Future<List<MutabaahRecord>> getHistoryByLembaga(Ref ref) async {
    try {
      final profile = ref.read(appContextProvider).profile;
      if (profile == null) return [];

      final response = await supabase
          .from('mutabaah_records')
          .select('*, modul:modul_kurikulum(nama_modul), siswa!inner(lembaga_id)')
          .eq('siswa.lembaga_id', profile.lembagaId ?? '')
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

  /// 5. READ: Mengambil saldo hutang terakhir (carry-over debt) untuk modul tertentu
  Future<double> getLatestDebt(String siswaId, String modulId) async {
    try {
      final response = await supabase
          .from('mutabaah_records')
          .select('debt_created')
          .match({'siswa_id': siswaId, 'modul_id': modulId})
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return 0.0;
      return (response['debt_created'] as num).toDouble();
    } catch (e) {
      return 0.0; // Fail safe jika belum ada record
    }
  }

  /// 6. KALKULASI: Menghitung skor akhir Ujian Tasmi' berdasarkan setting gradasi dinamis
  double calculateTasmiScore(Map<String, dynamic> tasmiSettings, Map<String, dynamic> penaltyCounts, Map<String, double> directScores) {
    double totalScore = 0.0;

    tasmiSettings.forEach((aspect, config) {
      if (config['active'] == true) {
        double bobot = (config['bobot'] as num?)?.toDouble() ?? 0.0;

        // Kategori A: Deduktif (Pinalti)
        if (aspect == 'itqon' || aspect == 'tajwid' || aspect == 'makhraj') {
          double deductions = 0.0;
          if (aspect == 'itqon') {
            int countS = penaltyCounts['itqon_s'] ?? 0;
            int countT = penaltyCounts['itqon_t'] ?? 0;
            int countP = penaltyCounts['itqon_p'] ?? 0;
            deductions += countS * ((config['pinalti_stt'] as num?)?.toDouble() ?? 0.0);
            deductions += countT * ((config['pinalti_t'] as num?)?.toDouble() ?? 0.0);
            deductions += countP * ((config['pinalti_p'] as num?)?.toDouble() ?? 0.0);
          } else if (aspect == 'tajwid' || aspect == 'makhraj') {
            int countK = penaltyCounts['${aspect}_k'] ?? 0;
            int countS = penaltyCounts['${aspect}_s'] ?? 0;
            deductions += countK * ((config['pinalti_kurang'] as num?)?.toDouble() ?? 0.0);
            deductions += countS * ((config['pinalti_salah'] as num?)?.toDouble() ?? 0.0);
          }

          // Skor aspek deduktif = bobot maksimal dikurangi total pinalti
          double aspectScore = bobot - deductions;
          if (aspectScore < 0) aspectScore = 0; // Tidak boleh minus
          totalScore += aspectScore;
        }
        // Kategori B: Komulatif (Skor Langsung)
        else {
          // directScores berisi nilai 0-100, dikonversi ke proporsi bobotnya
          double rawScore = directScores[aspect] ?? 0.0;
          totalScore += (rawScore / 100) * bobot;
        }
      }
    });

    return totalScore;
  }

  /// 7. READ: Mendapatkan status delegasi aktif untuk guru pengganti di kelas tertentu
  Future<DelegasiModel?> getActiveDelegation(String kelasId, String penerimaIzinId) async {
    try {
      // Ambil tanggal hari ini (Format YYYY-MM-DD)
      final today = DateTime.now().toIso8601String().split('T')[0];

      final response = await supabase
          .from('delegasi_tugas')
          .select()
          .match({
        'kelas_id': kelasId,
        'penerima_izin_id': penerimaIzinId,
        'is_active': true,
      })
          .gte('tanggal_izin', today)
          .order('tanggal_izin', ascending: true)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return DelegasiModel.fromJson(response);
    } catch (e) {
      return null; // Fail safe jika tidak ada delegasi
    }
  }

  /// 8. READ: Mendapatkan daftar Modul Aktif berdasarkan Kebijakan Kurikulum (Akses Bebas vs Sekuensial)
  Future<List<ModulModel>> getActiveModuls(Ref ref, String siswaId) async {
    try {
      // 1. Ambil level_id dari profil siswa secara langsung (Paling Aman)
      final siswaData = await supabase
          .from('siswa')
          .select('level_id')
          .eq('id', siswaId)
          .single();

      final levelId = siswaData['level_id'];
      if (levelId == null) {
        throw Exception("Siswa belum memiliki Level. Pastikan Level Kurikulum diisi pada profil siswa.");
      }

      // 2. Ambil kurikulum_id dari tabel kurikulum_level
      final levelData = await supabase
          .from('kurikulum_level')
          .select('kurikulum_id')
          .eq('id', levelId)
          .single();

      final kurikulumId = levelData['kurikulum_id'];
      if (kurikulumId == null) {
        throw Exception("Data Kurikulum Level tidak valid (kurikulum_id kosong di database).");
      }

      // 3. Ambil data dari tabel kurikulum (Flat Query: Kebal dari Ambiguitas Join)
      final kurikulumData = await supabase
          .from('kurikulum')
          .select('id, promotion_policy')
          .eq('id', kurikulumId)
          .maybeSingle();

      if (kurikulumData == null) {
        // Jika sampai di sini nilainya null, berarti 100% masalah RLS!
        throw Exception("Akses ke tabel Kurikulum diblokir oleh Supabase. Buka dashboard Supabase -> Authentication -> Policies, pastikan tabel 'kurikulum' memiliki policy SELECT untuk authenticated users.");
      }

      final String policy = kurikulumData['promotion_policy'] ?? 'flexible';

      // 4. Ambil semua modul yang tersedia dalam kurikulum tersebut (Urut berdasarkan Level & Urutan Modul)
      final allModulsResponse = await supabase
          .from('modul_kurikulum')
          .select('*, level:level_id!inner(kurikulum_id, urutan)')
          .eq('level.kurikulum_id', kurikulumId)
          .order('level(urutan)', ascending: true);

      List<ModulModel> allModuls = (allModulsResponse as List).map((m) => ModulModel.fromJson(m)).toList();

      // 5. Ambil status kelulusan (Modul mana saja yang sudah LULUS)
      // FIX: Mengubah nama kolom dari 'is_passed' menjadi 'is_passed_target' sesuai schema database
      final passedModulsResponse = await supabase
          .from('mutabaah_records')
          .select('modul_id')
          .match({'siswa_id': siswaId, 'is_passed_target': true});

      final Set<String> passedIds = (passedModulsResponse as List).map((m) => m['modul_id'].toString()).toSet();

      // 6. FILTERING BERDASARKAN KEBIJAKAN (Tipe A vs Tipe B)
      List<ModulModel> activeModuls = [];

      if (policy == 'flexible') {
        // TIPE A (Akses Bebas): Tampilkan SEMUA modul yang belum lulus
        activeModuls = allModuls.where((m) => !passedIds.contains(m.id)).toList();
      } else {
        // TIPE B (Sekuensial): Tampilkan HANYA SATU modul pertama yang belum lulus
        for (var m in allModuls) {
          if (!passedIds.contains(m.id)) {
            activeModuls.add(m);
            break; // Stop di modul pertama yang macet
          }
        }
      }

      return activeModuls;
    } catch (e) {
      throw Exception(handleError(e));
    }
  }
}