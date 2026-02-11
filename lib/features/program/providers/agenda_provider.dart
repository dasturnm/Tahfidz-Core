import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../management_lembaga/providers/app_context_provider.dart';
import '../models/agenda_model.dart';

part 'agenda_provider.g.dart';

@riverpod
class AgendaNotifier extends _$AgendaNotifier {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<AgendaModel>> build() async {
    final lembagaId = ref.watch(appContextProvider).lembaga?.id;
    if (lembagaId == null) return [];
    return _fetchAgendas(lembagaId);
  }

  Future<List<AgendaModel>> _fetchAgendas(String lembagaId) async {
    final data = await _supabase
        .from('agenda_akademik')
        .select()
        .eq('lembaga_id', lembagaId);

    return (data as List).map((e) => AgendaModel.fromJson(e)).toList();
  }

  Future<void> addAgenda(AgendaModel agenda) async {
    state = const AsyncValue.loading();
    await _supabase.from('agenda_akademik').insert({
      'lembaga_id': agenda.lembagaId,
      'nama_agenda': agenda.namaAgenda,
      'tanggal_mulai': agenda.tanggalMulai.toIso8601String(),
      'tanggal_berakhir': agenda.tanggalBerakhir.toIso8601String(),
      'status_hari_belajar': agenda.statusHariBelajar,
      'scope': agenda.scope,
      'program_id': agenda.programId,
    });
    ref.invalidateSelf();
  }
}