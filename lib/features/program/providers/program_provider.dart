// Lokasi: lib/features/program/providers/program_provider.dart

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tahfidz_core/core/providers/app_context_provider.dart';
import 'package:tahfidz_core/features/program/models/program_model.dart';
import 'package:tahfidz_core/features/program/services/program_service.dart';

part 'program_provider.g.dart';

@riverpod
class ProgramNotifier extends _$ProgramNotifier {
  final _service = ProgramService();

  @override
  Future<List<ProgramModel>> build() async {
    // FIX (Aturan 7): Pantau context untuk mengecek status loading secara reaktif
    final appContext = ref.watch(appContextProvider);
    final lembagaId = appContext.lembaga?.id;
    final cabangId = appContext.currentCabang?.id;

    debugPrint("🔍 ProgramProvider: Memulai build (Lembaga: $lembagaId)...");
    try {
      // 🛡️ GUARD: Jika context masih loading, jangan return list kosong dulu (Mencegah masalah Poin 4)
      if (appContext.isLoading) {
        debugPrint("⏳ ProgramProvider: AppContext masih loading, menunggu...");
        return [];
      }

      debugPrint("🆔 ProgramProvider: LembagaID=$lembagaId, CabangID=$cabangId");

      // Validasi ID
      if (lembagaId == null || lembagaId.isEmpty || lembagaId == 'null') {
        debugPrint("⚠️ ProgramProvider: lembagaId kosong, return [].");
        return [];
      }

      debugPrint("🚀 ProgramProvider: Memanggil fetchPrograms...");
      final results = await _service.fetchPrograms(lembagaId: lembagaId, cabangId: cabangId);
      debugPrint("✅ ProgramProvider: Berhasil mengambil ${results.length} program.");

      return results;
    } catch (e) {
      debugPrint("❌ Error build ProgramNotifier: $e");
      return []; // Kembalikan list kosong jika error agar loading berhenti
    }
  }

  // --- FUNGSI TAMBAH PROGRAM BARU ---
  Future<void> addProgram({
    required String nama,
    String? kurikulumId, // Tambahkan kurikulumId
    String? cabangId, // Diubah: Mengganti tag menjadi cabangId
    String? deskripsi,
    double pendaftaran = 0,
    double spp = 0,
    List<String> hari = const [],
  }) async {
    state = const AsyncValue.loading();

    final context = ref.read(appContextProvider);
    final lembagaId = context.lembaga?.id;
    final currentCabangId = context.currentCabang?.id;

    if (lembagaId == null) return;

    state = await AsyncValue.guard(() async {
      await _service.addProgram(
        lembagaId: lembagaId,
        nama: nama,
        kurikulumId: kurikulumId, // Teruskan kurikulumId ke service
        cabangId: cabangId,
        deskripsi: deskripsi,
        pendaftaran: pendaftaran,
        spp: spp,
        hari: hari,
      );

      return _service.fetchPrograms(lembagaId: lembagaId, cabangId: currentCabangId);
    });
  }

  // --- FUNGSI UPDATE PROGRAM ---
  Future<void> updateProgram(ProgramModel updated) async {
    state = const AsyncValue.loading();
    final context = ref.read(appContextProvider);
    final lembagaId = context.lembaga?.id;
    final cabangId = context.currentCabang?.id;

    if (lembagaId == null) return;

    state = await AsyncValue.guard(() async {
      await _service.updateProgram(updated);

      return _service.fetchPrograms(lembagaId: lembagaId, cabangId: cabangId);
    });
  }

  // --- FUNGSI HAPUS PROGRAM ---
  Future<bool> deleteProgram(String programId) async {
    state = const AsyncValue.loading();
    final context = ref.read(appContextProvider);
    final lembagaId = context.lembaga?.id;
    final currentCabangId = context.currentCabang?.id;

    if (lembagaId == null) return false;

    try {
      await _service.deleteProgram(programId);

      state = await AsyncValue.guard(() async {
        return _service.fetchPrograms(lembagaId: lembagaId, cabangId: currentCabangId);
      });
      return true;
    } catch (e) {
      debugPrint("❌ Error deleteProgram: $e");
      // Mengambil ulang data agar state tidak berhenti di loading jika terjadi gagal hapus (misal FK constraint)
      state = await AsyncValue.guard(() async {
        return _service.fetchPrograms(lembagaId: lembagaId, cabangId: currentCabangId);
      });
      return false;
    }
  }
}

/// --- UTILITAS ESTIMASI (Poin 3 Blueprint) ---
/// Mengambil daftar hari efektif program secara reaktif untuk kalkulasi estimasi tanggal selesai.
@riverpod
List<String> programHariEfektif(ProgramHariEfektifRef ref, String programId) {
  if (programId.isEmpty || programId == 'null') {
    debugPrint("⚠️ Estimasi Lulus: programId KOSONG. Pastikan Level ini sudah terhubung dengan program_id di Database.");
    return [];
  }

  final programs = ref.watch(programNotifierProvider).value ?? [];
  if (programs.isEmpty) {
    debugPrint("⏳ Estimasi Lulus: Menunggu data ProgramNotifier selesai di-load...");
  }

  final match = programs.where((p) => p.id == programId);

  if (match.isEmpty && programs.isNotEmpty) {
    debugPrint("⚠️ Estimasi Lulus: Program dengan ID $programId TIDAK DITEMUKAN di dalam list Program!");
    return [];
  }

  final hari = match.isNotEmpty ? match.first.hariAktif : <String>[];
  if (match.isNotEmpty) {
    debugPrint("✅ Estimasi Lulus: Ditemukan hari aktif $hari untuk program ${match.first.namaProgram}.");
  }

  return hari;
}