// Lokasi: lib/features/murojaah/widgets/murojaah_checklist_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/murojaah_task_provider.dart';
import '../../akademik/kurikulum/models/kurikulum_model.dart';

class MurojaahChecklistWidget extends ConsumerWidget {
  final String studentId;
  final ModulModel modul;

  const MurojaahChecklistWidget({super.key, required this.studentId, required this.modul});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTasks = ref.watch(murojaahTasksProvider((studentId: studentId, modul: modul)));
    const Color emerald = Color(0xFF10B981);

    return asyncTasks.when(
      data: (initialTasks) {
        // Inisialisasi notifier jika belum ada
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (ref.read(checklistProvider).isEmpty) {
            ref.read(checklistProvider.notifier).initTasks(initialTasks);
          }
        });

        final tasks = ref.watch(checklistProvider);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                "TUGAS MURAJAAH HARI INI",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.blueGrey, letterSpacing: 1.1),
              ),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final task = tasks[index];
                final bool isDone = task['is_done'];

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: isDone ? emerald.withValues(alpha: 0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDone ? emerald : Colors.grey[200]!),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: IconButton(
                      onPressed: () => ref.read(checklistProvider.notifier).toggleTask(index),
                      icon: Icon(
                        isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: isDone ? emerald : Colors.grey,
                        size: 28,
                      ),
                    ),
                    title: Text(
                      task['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: isDone ? TextDecoration.lineThrough : null,
                        color: isDone ? Colors.grey : Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      task['desc'],
                      style: TextStyle(fontSize: 12, color: isDone ? Colors.grey : Colors.blueGrey),
                    ),
                    trailing: isDone
                        ? const Icon(Icons.celebration, color: Colors.orange, size: 20)
                        : const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  ),
                );
              },
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text("Gagal memuat tugas: $e"),
    );
  }
}