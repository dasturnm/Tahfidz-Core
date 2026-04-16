// Lokasi: lib/features/akademik/tahun_ajaran/providers/tahun_ajaran_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/tahun_ajaran_model.dart';
import '../../../core/providers/app_context_provider.dart';
import '../services/tahun_ajaran_service.dart'; // Import Service Baru

part 'tahun_ajaran_provider.g.dart'; // FIX: Sesuaikan dengan nama file baru

@riverpod
class TahunAjaranList extends _$TahunAjaranList { // FIX: Seragam dengan pola 'List'
  // FIX: Gunakan TahunAjaranService
  final _service = TahunAjaranService();

  @override
  Future<List<TahunAjaranModel>> build() async {
    final lembagaId = ref.watch(appContextProvider).lembaga?.id;
    if (lembagaId == null) return [];

    // FIX: Mendelegasikan ke service
    return _service.getTahunAjaran(ref, lembagaId);
  }

  // --- FUNGSI TAMBAH (CREATE) ---
  Future<void> addTahunAjaran(TahunAjaranModel ta) async {
    state = const AsyncValue.loading();
    try {
      // FIX: Mendelegasikan ke service
      await _service.addTahunAjaran(ref, ta);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // --- FUNGSI UBAH (UPDATE) ---
  Future<void> updateTahunAjaran(TahunAjaranModel ta) async {
    state = const AsyncValue.loading();
    try {
      // FIX: Mendelegasikan ke service
      await _service.updateTahunAjaran(ref, ta);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // --- FUNGSI HAPUS (DELETE) ---
  Future<void> deleteTahunAjaran(String id) async {
    state = const AsyncValue.loading();
    try {
      // FIX: Mendelegasikan ke service
      await _service.deleteTahunAjaran(id);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // --- FUNGSI SET AKTIF (Menghubungkan ke Lembaga) ---
  Future<void> setTahunAjaranAktif(String taId) async {
    state = const AsyncValue.loading();
    try {
      // FIX: Mendelegasikan ke service
      await _service.setTahunAjaranAktif(ref, taId);

      // Refresh context agar seluruh aplikasi tahu tahun ajaran sudah berubah
      await ref.read(appContextProvider.notifier).initContext();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // --- LOGIKA SEMI-OTOMATIS: SARAN TAHUN ---
  String sarankanLabelTahun() {
    final now = DateTime.now();
    // Jika bulan sekarang Juli ke atas, sarankan tahun ini/tahun depan
    if (now.month >= 7) {
      return "${now.year}/${now.year + 1}";
    } else {
      // Jika bulan Januari - Juni, sarankan tahun lalu/tahun ini
      return "${now.year - 1}/${now.year}";
    }
  }
}