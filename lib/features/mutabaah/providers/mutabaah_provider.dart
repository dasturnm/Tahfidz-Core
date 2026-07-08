// Lokasi: lib/features/mutabaah/providers/mutabaah_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tahfidz_core/core/providers/app_context_provider.dart'; // FIX: Untuk mendapatkan ID Guru yang login
import 'package:tahfidz_core/features/siswa/services/siswa_service.dart'; // FIX: Untuk akses filter siswa
import 'package:tahfidz_core/features/siswa/models/siswa_model.dart';
import 'package:tahfidz_core/features/akademik/kurikulum/models/kurikulum_model.dart'; // TAMBAHAN
import '../models/mutabaah_model.dart';
import '../services/mutabaah_service.dart';
import 'delegasi_provider.dart'; // FIX: Integrasi Delegasi untuk Guru Pengganti
import '../../siswa/providers/siswa_provider.dart'; // TAMBAHAN: Sinkronisasi Dashboard

// 1. Deklarasi Global Service Provider
final mutabaahServiceProvider = Provider((ref) => MutabaahTahfidzService());

// 2. Provider untuk mengambil riwayat mutabaah siswa tertentu
final mutabaahHistoryProvider = FutureProvider.family<List<MutabaahRecord>, String>((ref, siswaId) async {
  // FIX: Menggunakan service untuk fetch data
  return ref.read(mutabaahServiceProvider).getHistory(siswaId);
});

// 2b. Provider untuk mengambil daftar surah (Dropdown UI) - SENTRALISASI FIX
final surahListProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.read(mutabaahServiceProvider).getSurahList();
});

// 3. Provider untuk mengambil seluruh riwayat mutabaah (digunakan di Mutabaah Hub)
final mutabaahAllHistoryProvider = FutureProvider<List<MutabaahRecord>>((ref) async {
  // FIX: Menggunakan service untuk fetch data
  return ref.read(mutabaahServiceProvider).getHistoryByLembaga(ref);
});

// 4. Provider untuk menghitung statistik bulanan siswa secara reaktif
final mutabaahStatsProvider = Provider.family<Map<String, dynamic>, String>((ref, siswaId) {
  final historyAsync = ref.watch(mutabaahHistoryProvider(siswaId));
  final history = historyAsync.asData?.value ?? [];

  double totalPages = 0;
  double totalScore = 0;
  int academicCount = 0;

  final now = DateTime.now();
  final currentMonthRecords = history.where((r) =>
  r.createdAt.month == now.month && r.createdAt.year == now.year
  ).toList();

  for (var record in currentMonthRecords) {
    if (record.tipeModul == 'HAFALAN' || record.tipeModul == 'Tahfidz') {
      totalPages += (record.dataPayload['calculated_pages'] ?? 0.0);
    } else if (['AKADEMIK', 'Akademik', 'INTERNAL', 'Internal'].contains(record.tipeModul)) {
      totalScore += (record.dataPayload['nilai'] ?? 0.0);
      academicCount++;
    }
  }

  return {
    'monthly_pages': totalPages,
    'avg_score': academicCount > 0 ? totalScore / academicCount : 0.0,
    'total_records': currentMonthRecords.length,
    'records': currentMonthRecords,
  };
});

// 5. Notifier untuk Submit Data
final mutabaahProvider = StateNotifierProvider<MutabaahNotifier, AsyncValue<void>>((ref) {
  return MutabaahNotifier(ref);
});

class MutabaahNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  MutabaahNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> submitRecord(MutabaahRecord record) async {
    state = const AsyncValue.loading();
    try {
      MutabaahRecord updatedRecord = record;

      // 1. Kalkulasi Baris Fisik & Validasi Target (SENTRALISASI: Menggunakan Service)
      // FIX (Poin 6): Menghapus limit surah dan menambah switch logika untuk membaca materi silabus internal
      if (record.surahId > 0 && record.ayahStart > 0) {
        final payload = await _ref.read(mutabaahServiceProvider).calculateTahfidzPayload(
          surahMulai: record.surahId,
          ayahMulai: record.ayahStart,
          surahAkhir: record.endSurahId > 0 ? record.endSurahId : record.surahId,
          ayahAkhir: record.ayahEnd,
        );

        final int actualBaris = (payload['calculated_lines'] as num?)?.toInt() ?? 0;
        final int finalBaris = record.totalBaris > 0 ? record.totalBaris : actualBaris;

        // Ambil Target dari Modul Kurikulum (Gunakan Snapshot untuk Integritas Data)
        final supabase = Supabase.instance.client;
        final modulRes = await supabase
            .from('modul_kurikulum')
            .select('total_baris')
            .eq('id', record.modulId)
            .single();

        final int targetBaris = (modulRes['total_baris'] ?? 0) as int;

        updatedRecord = record.copyWith(
          totalBaris: finalBaris,
          endSurahId: record.endSurahId > 0 ? record.endSurahId : record.surahId,
          achievedAmount: finalBaris.toDouble(),
          targetSnapshot: targetBaris.toDouble(),
          isPassedTarget: finalBaris >= targetBaris,
        );
      } else if (record.tipeModul == 'INTERNAL') {
        // Logika Internal: Memastikan status kelulusan berdasarkan nilai angka (KKM default 70 jika snapshot kosong)
        int startVal = record.internalStart > 0 ? record.internalStart : (int.tryParse(record.dataPayload['halaman_awal']?.toString() ?? '') ?? 0);
        int endVal = record.internalEnd > 0 ? record.internalEnd : (int.tryParse(record.dataPayload['halaman_akhir']?.toString() ?? '') ?? 0);
        String? materiVal = record.materiSilabusAktif ?? record.dataPayload['materi']?.toString() ?? record.dataPayload['materi_silabus']?.toString();
        int urutanVal = record.nomorUrutMateri > 0 ? record.nomorUrutMateri : (int.tryParse(record.dataPayload['nomor_urut']?.toString() ?? '') ?? 0);

        // Map status keputusan dari payload jika belum diset secara eksplisit di model
        int mappedStatus = record.statusKeputusan;
        if (mappedStatus == 0 && record.dataPayload.containsKey('keputusan_kedisiplinan')) {
          String extKeputusan = record.dataPayload['keputusan_kedisiplinan']?.toString() ?? '';
          if (extKeputusan == 'ULANG') {
            mappedStatus = -1;
          } else if (extKeputusan == 'LANJUT') mappedStatus = 1;
        }

        updatedRecord = record.copyWith(
          internalStart: startVal,
          internalEnd: endVal,
          materiSilabusAktif: materiVal,
          nomorUrutMateri: urutanVal,
          statusKeputusan: mappedStatus,
          isPassedTarget: mappedStatus == 1 || record.achievedAmount >= (record.targetSnapshot > 0 ? record.targetSnapshot : 70.0),
        );
      }

      // FIX: Menggunakan service untuk submit data (Clean Architecture)
      await _ref.read(mutabaahServiceProvider).submitRecord(updatedRecord);

      // TAMBAHAN: Sinkronisasi daftar siswa (Penting jika ada promosi level otomatis)
      _ref.invalidate(siswaListProvider);
      _ref.invalidate(mutabaahHistoryProvider(record.siswaId));
      _ref.invalidate(activeModulsBySiswaProvider(record.siswaId));

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // TAMBAHAN: Fungsi untuk submit banyak record sekaligus (Multi-Modul)
  Future<void> submitBatchRecords(List<MutabaahRecord> records) async {
    state = const AsyncValue.loading();
    try {
      // Looping untuk menyimpan record melalui service secara konsisten
      for (var record in records) {
        MutabaahRecord recordToSubmit = record;

        // TAMBAHAN: Logika Smart Converter (Skala 1-4 ke Persentase 0-100)
        if (record.dataPayload.containsKey('nilai') && record.dataPayload['nilai'] != null) {
          // FIX: Gunakan null-aware cast untuk keamanan konversi skala
          double rawValue = (record.dataPayload['nilai'] as num?)?.toDouble() ?? 0.0;

          // Deteksi input skala 1-4 (bilangan bulat 1, 2, 3, atau 4)
          if (rawValue >= 1.0 && rawValue <= 4.0 && rawValue % 1 == 0) {
            double convertedValue = 0.0;
            String keputusan = 'LANJUT'; // Default
            int finalStatusDecision = 1; // Default: Lanjut

            if (rawValue == 1.0) {
              convertedValue = 50.0;
              keputusan = 'ULANG'; // FIX: Skala 1 otomatis jadi ULANG
              finalStatusDecision = -1;
            } else if (rawValue == 2.0) {
              convertedValue = 75.0;
            } else if (rawValue == 3.0) {
              convertedValue = 85.0;
            } else if (rawValue == 4.0) {
              convertedValue = 100.0;
            }

            Map<String, dynamic> newPayload = Map.from(record.dataPayload);
            newPayload['nilai'] = convertedValue;
            newPayload['keputusan_kedisiplinan'] = keputusan; // FIX: Simpan keputusan ke payload

            recordToSubmit = record.copyWith(
              achievedAmount: convertedValue,
              statusKeputusan: finalStatusDecision,
              dataPayload: newPayload,
            );
          }
        }

        await submitRecord(recordToSubmit);
      }

      // TAMBAHAN: Sinkronisasi daftar siswa setelah batch simpan selesai
      _ref.invalidate(siswaListProvider);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// 6. Provider Siswa Cerdas (Fleksibel: Guru Tetap vs Admin vs Delegasi Pengganti)
final siswaByGuruProvider = FutureProvider<List<SiswaModel>>((ref) async {
  final appContext = ref.watch(appContextProvider);
  final profile = appContext.profile;

  if (profile == null) return [];

  // A. LOGIKA ADMIN: Bisa melihat semua siswa di lembaga (Tanpa Filter Guru)
  if (profile.role == 'admin' || profile.role == 'super_admin') {
    return ref.read(siswaServiceProvider).getSiswaByLembaga(ref);
  }

  // B. GURU: Bimbingan Sendiri + Izin Delegasi (Guru Pengganti)
  final bimbinganSendiri = await ref.read(siswaServiceProvider).fetchSiswaByGuru(ref, profile.id);

  // Cek apakah ada delegasi masuk (penerima izin) untuk hari ini
  final incomingDelegations = ref.watch(incomingDelegationsProvider).value ?? [];

  if (incomingDelegations.isNotEmpty) {
    final List<SiswaModel> combinedList = [...bimbinganSendiri];

    for (var delegasi in incomingDelegations) {
      // Ambal seluruh siswa di kelas yang didelegasikan
      final siswaDelegasi = await ref.read(siswaServiceProvider).getSiswaByKelas(ref, delegasi.kelasId);
      combinedList.addAll(siswaDelegasi);
    }

    // Hilangkan duplikasi jika satu siswa terdaftar di beberapa filter
    final seenIds = <String>{};
    return combinedList.where((s) => seenIds.add(s.id ?? '')).toList();
  }

  return bimbinganSendiri;
});

// 7. Session Provider (Menyimpan draft input sementara sesuai Analisa)
final mutabaahSessionProvider = StateProvider<MutabaahRecord?>((ref) => null);

// 8. Provider untuk mendeteksi Modul Aktif (Kantong Hutang vs Kantong Kewajiban)
// Mengambil modul berdasarkan kebijakan promotion_policy Kurikulum (Flexible/Strict)
final activeModulsBySiswaProvider = FutureProvider.family<List<ModulModel>, String>((ref, siswaId) async {
  final service = ref.read(mutabaahServiceProvider);
  // Ambil data modul yang benar-benar aktif (termasuk yang sedang 'Locked' untuk ujian)
  final activeModuls = await service.getActiveModuls(ref, siswaId);

  // Pastikan data reaktif terhadap perubahan status akademik siswa di database
  return activeModuls;
});

// 9. TAMBAHAN (Fase 2): Provider untuk memfilter Materi Silabus Internal (Smart Hide)
class MateriFilterParam {
  final String siswaId;
  final ModulModel modul;

  MateriFilterParam({required this.siswaId, required this.modul});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is MateriFilterParam &&
              siswaId == other.siswaId &&
              modul.id == other.modul.id;

  @override
  int get hashCode => siswaId.hashCode ^ modul.id.hashCode;
}

final remainingMateriProvider = FutureProvider.family<List<String>, MateriFilterParam>((ref, param) async {
  return ref.read(mutabaahServiceProvider).getRemainingMateri(param.siswaId, param.modul);
});