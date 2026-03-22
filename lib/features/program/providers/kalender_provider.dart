import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/providers/app_context_provider.dart';
import '../models/agenda_model.dart';

part 'kalender_provider.g.dart';

@riverpod
class CalendarNotifier extends _$CalendarNotifier {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<AgendaModel>> build(DateTime month) async {
    final lembagaId = ref.watch(appContextProvider).lembaga?.id;
    if (lembagaId == null) return [];

    // Tentukan awal dan akhir bulan
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final data = await _supabase
        .from('agenda_akademik')
        .select()
        .eq('lembaga_id', lembagaId)
        .gte('tanggal_mulai', firstDay.toIso8601String())
        .lte('tanggal_mulai', lastDay.toIso8601String())
        .order('tanggal_mulai', ascending: true);

    return (data as List).map((e) => AgendaModel.fromJson(e)).toList();
  }
}