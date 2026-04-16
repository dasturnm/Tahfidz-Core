import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/providers/app_context_provider.dart';
import '../../akademik/services/akademik_service.dart';
import '../models/agenda_model.dart';

part 'agenda_provider.g.dart';

@riverpod
class AgendaNotifier extends _$AgendaNotifier {
  final _service = AkademikService();

  @override
  Future<List<AgendaModel>> build({String? tahunAjaranId, String? programId}) async { // UPDATE: Parameter Filter
    final lembagaId = ref.watch(appContextProvider).lembaga?.id;
    if (lembagaId == null) return [];

    // Gunakan service sesuai Rule 3.3
    return _service.fetchAgendas(
      lembagaId: lembagaId,
      tahunAjaranId: tahunAjaranId,
      programId: programId,
    );
  }

  // --- FUNGSI TAMBAH AGENDA ---
  Future<void> addAgenda(AgendaModel agenda, {bool isRecurring = false, DateTime? untilDate}) async {
    state = const AsyncValue.loading();
    try {
      // Panggil service dengan parameter perulangan (Opsi B)
      await _service.addAgenda(
        agenda,
        isRecurring: isRecurring,
        untilDate: untilDate,
      );
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // --- FUNGSI UPDATE AGENDA ---
  Future<void> updateAgenda(AgendaModel agenda) async {
    state = const AsyncValue.loading();
    try {
      await _service.updateAgenda(agenda);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // --- FUNGSI HAPUS AGENDA ---
  Future<void> deleteAgenda(String id) async {
    state = const AsyncValue.loading();
    try {
      await _service.deleteAgenda(id);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}