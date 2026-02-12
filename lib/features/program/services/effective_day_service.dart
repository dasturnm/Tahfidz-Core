import '../models/agenda_model.dart';

class EffectiveDayService {
  /// Fungsi utama untuk menghitung total hari efektif belajar
  static int calculateEffectiveDays({
    required DateTime startDate,
    required DateTime endDate,
    required List<String> hariAktifProgram,
    required List<AgendaModel> allAgendas,
    required String targetProgramId,
  }) {
    int totalDays = 0;

    // Normalisasi jam agar perbandingan tanggal akurat (set ke 00:00:00)
    DateTime current = DateTime(startDate.year, startDate.month, startDate.day);
    final limit = DateTime(endDate.year, endDate.month, endDate.day);

    while (current.isBefore(limit) || current.isAtSameMomentAs(limit)) {
      // 1. Cek apakah hari ini masuk dalam jadwal rutin Program?
      String dayName = _getIndonesianDayName(current.weekday);
      bool isScheduled = hariAktifProgram.contains(dayName);

      if (isScheduled) {
        // 2. Cek apakah ada agenda LIBUR yang menimpa hari ini?
        bool isHoliday = allAgendas.any((agenda) {
          // Hanya hitung agenda berstatus LIBUR
          if (agenda.statusHariBelajar != 'LIBUR') return false;

          // Cek Scope: Berlaku jika GLOBAL atau spesifik untuk program ini
          bool isRelevantScope = agenda.scope == 'GLOBAL' ||
              (agenda.scope == 'PROG_SPESIFIK' && agenda.programId == targetProgramId);

          if (!isRelevantScope) return false;

          // Cek Rentang Tanggal Agenda
          final startAg = DateTime(agenda.tanggalMulai.year, agenda.tanggalMulai.month, agenda.tanggalMulai.day);
          final endAg = DateTime(agenda.tanggalBerakhir.year, agenda.tanggalBerakhir.month, agenda.tanggalBerakhir.day);

          return (current.isAtSameMomentAs(startAg) || current.isAtSameMomentAs(endAg)) ||
              (current.isAfter(startAg) && current.isBefore(endAg));
        });

        // 3. Jika hari ini jadwal masuk DAN bukan hari libur, tambahkan ke total
        if (!isHoliday) {
          totalDays++;
        }
      }

      current = current.add(const Duration(days: 1));
    }

    return totalDays;
  }

  /// Helper untuk konversi angka hari (1-7) ke Nama Hari Indonesia sesuai Model
  static String _getIndonesianDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday: return 'Senin';
      case DateTime.tuesday: return 'Selasa';
      case DateTime.wednesday: return 'Rabu';
      case DateTime.thursday: return 'Kamis';
      case DateTime.friday: return 'Jumat';
      case DateTime.saturday: return 'Sabtu';
      case DateTime.sunday: return 'Minggu';
      default: return '';
    }
  }
}