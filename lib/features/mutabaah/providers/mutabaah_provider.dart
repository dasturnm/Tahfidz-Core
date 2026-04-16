// Lokasi: lib/features/mutabaah/providers/mutabaah_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tahfidz_core/core/providers/app_context_provider.dart'; // FIX: Untuk mendapatkan ID Guru yang login
import 'package:tahfidz_core/features/siswa/services/siswa_service.dart'; // FIX: Untuk akses filter siswa
import 'package:tahfidz_core/features/siswa/models/siswa_model.dart';
import '../models/mutabaah_model.dart';
import '../services/mutabaah_service.dart';
import 'delegasi_provider.dart'; // FIX: Integrasi Delegasi untuk Guru Pengganti

// 1. Deklarasi Global Service Provider
final mutabaahServiceProvider = Provider((ref) => MutabaahTahfidzService());

// 2. Provider untuk mengambil riwayat mutabaah siswa tertentu
final mutabaahHistoryProvider = FutureProvider.family<List<MutabaahRecord>, String>((ref, siswaId) async {
  // FIX: Menggunakan service untuk fetch data
  return ref.read(mutabaahServiceProvider).getHistory(siswaId);
});

// 3. Provider untuk mengambil seluruh riwayat mutabaah (digunakan di Mutabaah Hub)
final mutabaahAllHistoryProvider = FutureProvider<List<MutabaahRecord>>((ref) async {
  // FIX: Menggunakan service untuk fetch data
  return ref.read(mutabaahServiceProvider).getAllHistory();
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
    } else if (record.tipeModul == 'AKADEMIK' || record.tipeModul == 'Akademik') {
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
      // FIX: Menggunakan service untuk submit data (Clean Architecture)
      await _ref.read(mutabaahServiceProvider).submitRecord(record);
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

  // B. LOGIKA GURU: Bimbingan Sendiri + Izin Delegasi (Guru Pengganti)
  final bimbinganSendiri = await ref.read(siswaServiceProvider).fetchSiswaByGuru(ref, profile.id);

  // Cek apakah ada delegasi masuk (penerima izin) untuk hari ini
  final incomingDelegations = ref.watch(incomingDelegationsProvider).value ?? [];

  if (incomingDelegations.isNotEmpty) {
    final List<SiswaModel> combinedList = [...bimbinganSendiri];

    for (var delegasi in incomingDelegations) {
      // Ambil seluruh siswa di kelas yang didelegasikan
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