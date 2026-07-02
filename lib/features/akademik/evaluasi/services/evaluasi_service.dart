// Lokasi: lib/features/akademik/evaluasi/services/evaluasi_service.dart

import '../../../../core/services/base_service.dart';
import '../models/evaluasi_record_model.dart';
import '../models/evaluasi_config_model.dart';

class EvaluasiService extends BaseService {
  /// 1. CREATE: Menyimpan data evaluasi (Ujian Tasmi / UKL) ke tabel khusus
  /// FIX: Disesuaikan dengan nama tabel rial di database 'siswa_evaluasi_nilai'
  Future<void> submitEvaluasi(EvaluasiRecordModel record) async {
    try {
      // Membersihkan data dari null atau string kosong sesuai protokol AGENTS.md
      final data = cleanData(record.toJson());

      // Hapus ID jika null agar Supabase yang melakukan auto-generate UUID
      if (data['id'] == null || data['id'].toString().trim().isEmpty) {
        data.remove('id');
      }

      // Bersihkan template_id jika berisi string kosong atau teks 'null' agar tidak memicu error sintaksis UUID
      if (data.containsKey('template_id')) {
        final val = data['template_id']?.toString().trim();
        if (val == null || val.isEmpty || val == 'null') {
          data.remove('template_id');
        }
      }

      await supabase.from('siswa_evaluasi_nilai').insert(data);

      // TAMBAHAN OPSI B: Reset kembali flag kesiapan ujian di profil siswa setelah dievaluasi (Pembersihan Antrean)
      await supabase.from('siswa').update({
        'is_ready_for_exam': false,
        'ready_modul_id': null,
        'academic_state': 'daily', // TAMBAHAN: Reset kembali ke daily agar gembok input harian terbuka kembali
      }).eq('id', record.siswaId);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// 2. READ: Mengambil riwayat ujian formal seorang siswa
  Future<List<EvaluasiRecordModel>> getRiwayatEvaluasi(String siswaId) async {
    try {
      final response = await supabase
          .from('siswa_evaluasi_nilai')
          .select('*, modul:modul_kurikulum(nama_modul), guru:profiles(nama_lengkap)')
          .eq('siswa_id', siswaId)
          .order('tanggal_evaluasi', ascending: false);

      return (response as List).map((json) => EvaluasiRecordModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// TAMBAHAN: Mengambil data rekaman ujian terakhir yang spesifik berdasarkan kombinasi siswa dan modul
  Future<Map<String, dynamic>?> fetchSavedEvaluasi(String siswaId, String modulId) async {
    try {
      final response = await supabase
          .from('siswa_evaluasi_nilai')
          .select('*')
          .eq('siswa_id', siswaId)
          .eq('modul_id', modulId)
          .order('tanggal_evaluasi', ascending: false)
          .maybeSingle();
      return response;
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// TAMBAHAN: Fungsi transisi untuk menyelesaikan validasi volume Tasmi' dan bergeser ke siap mengisi ujian formal
  Future<void> completeTasmiVolume(String siswaId) async {
    try {
      await supabase.from('siswa').update({
        'academic_state': 'exam_ready',
      }).eq('id', siswaId);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// 3. KALKULATOR: Menghitung Skor Rata-rata Tertimbang (Weighted Average)
  /// Sangat berguna untuk form mode "CHECKLIST" skala 1-4
  double calculateWeightedAverage(Map<String, double> scores, EvaluasiConfigModel config) {
    double totalScore = 0.0;
    double totalWeight = 0.0;

    // Asumsi: scores berisi key seperti 'itqon', 'tajwid', 'makhraj' dengan nilai 1-4 atau 0-100
    if (scores.containsKey('itqon')) {
      totalScore += (scores['itqon']! * config.bobotItqon);
      totalWeight += config.bobotItqon;
    }

    if (scores.containsKey('tajwid')) {
      totalScore += (scores['tajwid']! * config.bobotTajwid);
      totalWeight += config.bobotTajwid;
    }

    if (scores.containsKey('makhraj')) {
      totalScore += (scores['makhraj']! * config.bobotMakhraj);
      totalWeight += config.bobotMakhraj;
    }

    // Hindari pembagian dengan nol
    if (totalWeight <= 0) return 0.0;

    // Mengembalikan nilai akhir
    return totalScore / totalWeight;
  }
}