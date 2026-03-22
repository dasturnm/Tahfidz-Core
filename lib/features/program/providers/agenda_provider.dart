import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/providers/app_context_provider.dart';
import '../models/agenda_model.dart';

part 'agenda_provider.g.dart';

@riverpod
class AgendaNotifier extends _$AgendaNotifier {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<AgendaModel>> build({String? tahunAjaranId, String? programId}) async { // UPDATE: Parameter Filter
    final lembagaId = ref.watch(appContextProvider).lembaga?.id;
    if (lembagaId == null) return [];
    return _fetchAgendas(lembagaId, tahunAjaranId, programId);
  }

  Future<List<AgendaModel>> _fetchAgendas(String lembagaId, String? tahunAjaranId, String? programId) async {
    // UPDATE: Logika Query Berjenjang
    var query = _supabase
        .from('agenda_akademik')
        .select()
        .eq('lembaga_id', lembagaId);

    // FIX: Filter tahun_ajaran_id dinonaktifkan sementara karena kolom belum ada di database
    /*
    if (tahunAjaranId != null && tahunAjaranId.isNotEmpty) {
      query = query.eq('tahun_ajaran_id', tahunAjaranId);
    }
    */

    // FIX: Logika OR agar Agenda Global (program_id null) tetap muncul di semua program
    if (programId != null && programId.isNotEmpty) {
      query = query.or('program_id.eq.$programId,program_id.is.null');
    }

    final data = await query.order('tanggal_mulai', ascending: true);
    return (data as List).map((e) => AgendaModel.fromJson(e)).toList();
  }

  Future<void> addAgenda(AgendaModel agenda) async {
    state = const AsyncValue.loading();
    try {
      await _supabase.from('agenda_akademik').insert({
        'lembaga_id': agenda.lembagaId,
        // 'tahun_ajaran_id': agenda.tahunAjaranId, // UPDATE: Connect Tahun Ajaran (Dinonaktifkan sementara)
        'nama_agenda': agenda.namaAgenda,
        'tanggal_mulai': agenda.tanggalMulai.toIso8601String(),
        'tanggal_berakhir': agenda.tanggalBerakhir.toIso8601String(),
        'status_hari_belajar': agenda.statusHariBelajar,
        'scope': agenda.scope,
        'program_id': agenda.programId,
        'keterangan': agenda.keterangan,
        'is_siswa_libur': agenda.isSiswaLibur,
        'is_guru_masuk': agenda.isGuruMasuk,
      });
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateAgenda(AgendaModel agenda) async {
    state = const AsyncValue.loading();
    try {
      await _supabase.from('agenda_akademik').update({
        // 'tahun_ajaran_id': agenda.tahunAjaranId, // UPDATE: Connect Tahun Ajaran (Dinonaktifkan sementara)
        'nama_agenda': agenda.namaAgenda,
        'tanggal_mulai': agenda.tanggalMulai.toIso8601String(),
        'tanggal_berakhir': agenda.tanggalBerakhir.toIso8601String(),
        'status_hari_belajar': agenda.statusHariBelajar,
        'scope': agenda.scope,
        'program_id': agenda.programId,
        'keterangan': agenda.keterangan,
        'is_siswa_libur': agenda.isSiswaLibur,
        'is_guru_masuk': agenda.isGuruMasuk,
      }).eq('id', agenda.id);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteAgenda(String id) async {
    state = const AsyncValue.loading();
    try {
      await _supabase.from('agenda_akademik').delete().eq('id', id);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}