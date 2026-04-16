// Lokasi: lib/features/program/providers/kalender_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
// FIX: Menggunakan absolute import agar aman dari error path folder (uri_does_not_exist)
import 'package:tahfidz_core/features/akademik/services/akademik_service.dart';
import 'package:tahfidz_core/core/providers/app_context_provider.dart';
import 'package:tahfidz_core/features/program/models/agenda_model.dart';

part 'kalender_provider.g.dart';

@riverpod
class CalendarNotifier extends _$CalendarNotifier {
  final _service = AkademikService(); // FIX: Gunakan Service

  @override
  Future<List<AgendaModel>> build(DateTime month) async {
    final lembagaId = ref.watch(appContextProvider).lembaga?.id;
    if (lembagaId == null) return [];

    // Tentukan awal dan akhir bulan
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    // FIX: Delegasikan query ke AkademikService
    return await _service.fetchAgendasForMonth(
      lembagaId: lembagaId,
      firstDay: firstDay,
      lastDay: lastDay,
    );
  }
}