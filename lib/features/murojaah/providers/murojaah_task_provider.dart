// Lokasi: lib/features/murojaah/providers/murojaah_task_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/murojaah_task_service.dart';
import '../../akademik/kurikulum/models/kurikulum_model.dart';

// Provider untuk mengambil tugas hari ini
final murojaahTasksProvider = FutureProvider.family<List<Map<String, dynamic>>, ({String studentId, ModulModel modul})>((ref, arg) async {
  final service = MurojaahTaskService();
  return service.getTodayTasks(arg.studentId, arg.modul);
});

// StateNotifier untuk mengelola centang (is_done) secara lokal sebelum sinkron ke DB
class MurojaahChecklistNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  MurojaahChecklistNotifier() : super([]);

  void initTasks(List<Map<String, dynamic>> tasks) => state = tasks;

  void toggleTask(int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index)
          {...state[i], "is_done": !state[i]["is_done"]}
        else
          state[i]
    ];
  }
}

final checklistProvider = StateNotifierProvider<MurojaahChecklistNotifier, List<Map<String, dynamic>>>((ref) {
  return MurojaahChecklistNotifier();
});