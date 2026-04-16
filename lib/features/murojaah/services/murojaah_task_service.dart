// Lokasi: lib/features/murojaah/services/murojaah_task_service.dart

import '../../../core/services/base_service.dart';
import '../../akademik/kurikulum/models/kurikulum_model.dart';

class MurojaahTaskService extends BaseService {

  /// 1. MENGHITUNG RANGE SABQI
  /// Logika: Mengambil X halaman ke belakang dari baris terakhir yang dihafal
  Future<Map<String, dynamic>> calculateSabqiRange({
    required int lastAbsoluteLine,
    required int pagesBack,
  }) async {
    // 1 Halaman Mushaf Madinah = 15 Baris
    int totalLinesBack = pagesBack * 15;
    int startLine = lastAbsoluteLine - totalLinesBack;
    if (startLine < 1) startLine = 1;

    // Ambil koordinat Surah/Ayat dari tabel referensi data_mushaf
    final startCoord = await _getCoordFromAbsolute(startLine);
    final endCoord = await _getCoordFromAbsolute(lastAbsoluteLine);

    return {
      "type": "SABQI",
      "start": startCoord,
      "end": endCoord,
      "total_pages": pagesBack,
    };
  }

  /// 2. MENGHITUNG PORSI MANZIL (DINAMIS)
  /// Logika: Menghitung porsi hafalan lama agar khatam dalam siklus tertentu
  Future<Map<String, dynamic>> calculateManzilRange({
    required int totalLinesMemorized,
    required double amount,
    required String type, // 'fixed' atau 'percentage'
  }) async {
    int targetLines;

    if (type == 'percentage') {
      // Rumus: (Total Hafalan * Persentase) / 100
      targetLines = ((totalLinesMemorized * amount) / 100).round();
    } else {
      // Jika fixed, asumsi input adalah Halaman (1 Hal = 15 Baris)
      targetLines = (amount * 15).toInt();
    }

    // Untuk sementara, Manzil mengambil 'porsi' secara acak atau berurutan
    // dari database record mutabaah lama (bisa dikembangkan lebih lanjut)
    return {
      "type": "MANZIL",
      "target_lines": targetLines,
      "target_pages": (targetLines / 15).toStringAsFixed(1),
    };
  }

  /// 3. HELPER: KONVERSI BARIS ABSOLUT KE SURAH/AYAT
  /// Rumus Posisi: $$AbsoluteLine = (Page - 1) \times 15 + Line$$
  Future<Map<String, dynamic>> _getCoordFromAbsolute(int absoluteLine) async {
    try {
      // Hitung Page dan Line
      int page = ((absoluteLine - 1) / 15).floor() + 1;
      int line = (absoluteLine - 1) % 15 + 1;

      final data = await supabase
          .from('data_mushaf')
          .select('surah_number, ayah_number, surah_name')
          .match({'page_number': page, 'line_number': line})
          .limit(1)
          .single();

      return {
        "surah": data['surah_number'],
        "ayah": data['ayah_number'],
        "surah_name": data['surah_name'],
        "page": page,
      };
    } catch (e) {
      return {"surah": 1, "ayah": 1, "surah_name": "Al-Fatihah", "page": 1};
    }
  }

  /// 4. GENERATE DAILY CHECKLIST
  /// Fungsi utama yang akan dipanggil oleh Dashboard Santri
  Future<List<Map<String, dynamic>>> getTodayTasks(String studentId, ModulModel modul) async {
    // 1. Ambil data record mutabaah terakhir santri untuk modul Ziyadah terkait
    final lastRecord = await supabase
        .from('mutabaah_records')
        .select('data_payload')
        .eq('siswa_id', studentId)
        .eq('tipe_modul', 'ZIYADAH HAFALAN')
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (lastRecord == null) return [];

    int lastLine = (lastRecord['data_payload']['calculated_lines_total'] ?? 0).toInt();

    // 2. Hitung Sabqi
    final sabqi = await calculateSabqiRange(
      lastAbsoluteLine: lastLine,
      pagesBack: modul.sabqiAmount,
    );

    // 3. Hitung Manzil
    final manzil = await calculateManzilRange(
      totalLinesMemorized: lastLine,
      amount: modul.manzilAmount,
      type: modul.manzilType,
    );

    return [
      {
        "title": "Murojaah Sabqi",
        "desc": "${sabqi['start']['surah_name']} s/d ${sabqi['end']['surah_name']}",
        "is_done": false,
      },
      {
        "title": "Murojaah Manzil",
        "desc": "Target hari ini: ${manzil['target_pages']} Halaman",
        "is_done": false,
      }
    ];
  }
}