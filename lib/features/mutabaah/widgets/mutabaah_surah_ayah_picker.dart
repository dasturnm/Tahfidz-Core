import 'package:flutter/material.dart';
import '../../akademik/kurikulum/models/kurikulum_model.dart';

class MutabaahSurahAyahPicker extends StatelessWidget {
  final ModulModel modul;
  final String label;
  final int? surahValue;
  final int? ayahValue;
  final List<Map<String, dynamic>> surahList;
  final Function(int?, int?) onUpdate;

  const MutabaahSurahAyahPicker({
    super.key,
    required this.modul,
    required this.label,
    required this.surahValue,
    required this.ayahValue,
    required this.surahList,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    // Tentukan Batas Rentang Cakupan dari Modul Berdasarkan JENIS METRIK
    int startS = 1;
    int endS = 114;
    int originalStartCoord = 1;
    int originalEndCoord = 114;

    if (modul.jenisMetrik == 'JUZ') {
      int startJuz = int.tryParse(modul.mulaiKoordinatJuz ?? '1') ?? 1;
      int endJuz = int.tryParse(modul.akhirKoordinatJuz ?? '30') ?? 30;

      // FIX: Handle reverse order (e.g., Juz 30 to 26) agar list dropdown tetap terisi
      int minJuz = startJuz < endJuz ? startJuz : endJuz;
      int maxJuz = startJuz > endJuz ? startJuz : endJuz;

      // Kamus Peta Juz ke Surah (Indeks 1 = Juz 1, dst)
      const juzStartSurah = [0, 1, 2, 2, 3, 4, 4, 5, 6, 7, 8, 9, 11, 12, 15, 17, 18, 21, 23, 25, 27, 29, 33, 36, 39, 41, 46, 51, 58, 67, 78];
      const juzEndSurah = [0, 2, 2, 3, 4, 4, 5, 6, 7, 8, 9, 11, 12, 14, 16, 18, 20, 22, 25, 27, 29, 33, 36, 39, 41, 45, 51, 57, 66, 77, 114];

      startS = juzStartSurah[minJuz.clamp(1, 30)];
      endS = juzEndSurah[maxJuz.clamp(1, 30)];

      originalStartCoord = juzStartSurah[startJuz.clamp(1, 30)];
      originalEndCoord = juzEndSurah[endJuz.clamp(1, 30)];
    } else if (modul.jenisMetrik == 'SURAH') {
      originalStartCoord = int.tryParse(modul.mulaiKoordinatJuz ?? '1') ?? 1;
      originalEndCoord = int.tryParse(modul.akhirKoordinatJuz ?? '114') ?? 114;

      // FIX: Handle reverse order Surah (e.g., Surah 114 to 78)
      startS = originalStartCoord < originalEndCoord ? originalStartCoord : originalEndCoord;
      endS = originalStartCoord > originalEndCoord ? originalStartCoord : originalEndCoord;
    } else {
      // Jika berbasis HALAMAN atau lainnya, buka seluruh akses Surah agar guru bebas memilih
      startS = 1;
      endS = 114;
      originalStartCoord = 1;
      originalEndCoord = 114;
    }

    // Filter daftar surah sesuai cakupan modul
    List<Map<String, dynamic>> availableSurahs = surahList.where((s) {
      int sId = s['id'] as int;
      return sId >= startS && sId <= endS;
    }).toList();

    // FIX: Proteksi agar value Dropdown selalu ada di dalam list availableSurahs (dihitung DULUAN)
    final bool isSurahValid = surahValue != null && availableSurahs.any((s) => s['id'] == surahValue);
    final int? effectiveSurah = isSurahValid ? surahValue : (availableSurahs.isNotEmpty ? availableSurahs.first['id'] as int : null);

    int minAyah = 1;
    int maxAyah = 286;

    // Kalkulasi batas ayat HARUS menggunakan effectiveSurah, bukan surahValue
    if (effectiveSurah != null && availableSurahs.isNotEmpty) {
      final surahData = availableSurahs.firstWhere(
              (e) => e['id'] == effectiveSurah,
          orElse: () => availableSurahs.first
      );
      int actualTotalAyah = surahData['total_ayah'] ?? 286;
      maxAyah = actualTotalAyah;

      // Filter Ayat jika berada di Surah Awal atau Akhir Cakupan
      if (effectiveSurah == originalStartCoord && modul.ayahStart > 0) minAyah = modul.ayahStart;
      if (effectiveSurah == originalEndCoord && modul.ayahEnd > 0) maxAyah = modul.ayahEnd;

      // Safety Fallback (Agar tidak ada Dropdown Crash)
      if (maxAyah > actualTotalAyah) maxAyah = actualTotalAyah;
      if (minAyah > maxAyah) minAyah = maxAyah;
    }

    // Koreksi Auto-Value jika keluar batas atau null
    int? safeAyahValue = ayahValue;
    if (safeAyahValue != null) {
      if (safeAyahValue < minAyah) safeAyahValue = minAyah;
      if (safeAyahValue > maxAyah) safeAyahValue = maxAyah;
    } else {
      safeAyahValue = minAyah; // Default if null
    }

    // SINKRONISASI: Paksa state parent mengikuti visual fallback HANYA jika data surah sudah siap dimuat
    if (surahList.isNotEmpty && (surahValue != effectiveSurah || ayahValue != safeAyahValue)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onUpdate(effectiveSurah, safeAyahValue);
      });
    }

    // FIX: Cegah OVERFLOW dengan membagi proporsi Row menggunakan Expanded
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(children: [
        Expanded(
            flex: 3,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.grey))
        ),
        const SizedBox(width: 8),
        Expanded(
            flex: 5,
            child: DropdownButton<int>(
                isExpanded: true, underline: const SizedBox(),
                value: effectiveSurah,
                items: availableSurahs.map((s) => DropdownMenuItem(value: s['id'] as int, child: Text("${s['id']}. ${s['name_id']}", style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis))).toList(),
                // Otomatis kalkulasi ulang minAyah jika guru mengganti pilihan surah
                onChanged: (v) {
                  int newMinAyah = 1;
                  if (v == originalStartCoord && modul.ayahStart > 0) newMinAyah = modul.ayahStart;
                  onUpdate(v, newMinAyah);
                }
            )
        ),
        const SizedBox(width: 8),
        Expanded(
            flex: 3,
            child: DropdownButton<int>(
                isExpanded: true, underline: const SizedBox(),
                value: safeAyahValue,
                items: List.generate((maxAyah - minAyah) + 1, (i) => DropdownMenuItem(value: minAyah + i, child: Text("${minAyah + i}", style: const TextStyle(fontSize: 12)))).toList(),
                onChanged: (v) => onUpdate(effectiveSurah, v)
            )
        ),
      ]),
    );
  }
}