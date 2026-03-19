// Lokasi: lib/features/mutabaah/providers/mutabaah_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/mutabaah_model.dart';

// Provider untuk mengambil riwayat mutabaah siswa tertentu
final mutabaahHistoryProvider = FutureProvider.family<List<MutabaahRecord>, String>((ref, siswaId) async {
  final supabase = Supabase.instance.client;

  final response = await supabase
      .from('mutabaah_records')
      .select('*, modul:modul_kurikulum(nama_modul)') // Join untuk ambil nama modul
      .eq('siswa_id', siswaId)
      .order('created_at', ascending: false);

  // FIX: Menggunakan factory fromJson untuk menangani pemetaan guru_id dan UUID
  return (response as List).map((json) => MutabaahRecord.fromJson(json)).toList();
});

// Provider untuk mengambil seluruh riwayat mutabaah (digunakan di Mutabaah Hub)
final mutabaahAllHistoryProvider = FutureProvider<List<MutabaahRecord>>((ref) async {
  final supabase = Supabase.instance.client;

  final response = await supabase
      .from('mutabaah_records')
      .select('*, modul:modul_kurikulum(nama_modul)')
      .order('created_at', ascending: false);

  // FIX: Menggunakan factory fromJson untuk menangani pemetaan guru_id dan UUID
  return (response as List).map((json) => MutabaahRecord.fromJson(json)).toList();
});

// Provider untuk menghitung statistik bulanan siswa secara reaktif
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
    if (record.tipeModul == 'HAFALAN') {
      totalPages += (record.dataPayload['calculated_pages'] ?? 0.0);
    } else if (record.tipeModul == 'AKADEMIK') {
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

final mutabaahProvider = StateNotifierProvider<MutabaahNotifier, AsyncValue<void>>((ref) {
  return MutabaahNotifier();
});

class MutabaahNotifier extends StateNotifier<AsyncValue<void>> {
  MutabaahNotifier() : super(const AsyncValue.data(null));

  final _supabase = Supabase.instance.client;

  Future<void> submitRecord(MutabaahRecord record) async {
    state = const AsyncValue.loading();
    try {
      await _supabase.from('mutabaah_records').insert(record.toMap());
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}