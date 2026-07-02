// Lokasi: lib/features/akademik/evaluasi/providers/kesiapan_ujian_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/app_context_provider.dart';
import '../../../siswa/models/siswa_model.dart';

part 'kesiapan_ujian_provider.g.dart';

/// Provider reaktif untuk mengambil daftar santri yang statusnya siap mengikuti ujian formal.
@riverpod
Future<List<SiswaModel>> kesiapanUjianList(KesiapanUjianListRef ref) async {
  final supabase = Supabase.instance.client;

  // 1. Ambil data lembaga aktif dari konteks global (Proteksi Multi-Tenant sesuai AGENTS.md)
  final appContext = ref.watch(appContextProvider);
  final lembagaId = appContext.lembaga?.id;

  if (lembagaId == null) return [];

  // 2. Query data siswa yang berada di bawah lembaga ini
  // FIX: Ditambahkan filter '.eq('is_ready_for_exam', true)' agar hanya siswa yang tuntas modul harian yang muncul
  final response = await supabase
      .from('siswa')
      .select('*, kelas:kelas_id(nama_kelas), level:level_id(nama_level)')
      .eq('lembaga_id', lembagaId)
      .eq('status', 'aktif')
      .eq('is_ready_for_exam', true); // Hanya menarik santri yang siap ujian formal

  // 3. Konversi hasil query menjadi List Model Siswa secara aman
  return (response as List).map((json) => SiswaModel.fromJson(json)).toList();
}