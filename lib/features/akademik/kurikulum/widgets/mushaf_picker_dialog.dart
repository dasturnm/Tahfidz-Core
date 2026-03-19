import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/quran_provider.dart';

class MushafPickerDialog extends ConsumerWidget {
  const MushafPickerDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahAsync = ref.watch(quranSurahListProvider);
    const Color emerald = Color(0xFF10B981);

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: DefaultTabController(
        length: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("PILIH CAKUPAN MUSHAF", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            const SizedBox(height: 8),
            const TabBar(
              labelColor: emerald,
              unselectedLabelColor: Colors.grey,
              indicatorColor: emerald,
              indicatorWeight: 3,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              tabs: [
                Tab(text: "SURAH"),
                Tab(text: "HALAMAN"),
                Tab(text: "JUZ"),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TabBarView(
                children: [
                  surahAsync.when(
                    data: (list) => ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final s = list[index];
                        return ListTile(
                          title: Text(s['name_id'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("${s['total_ayah']} Ayat"),
                          onTap: () => Navigator.pop(context, {
                            'nama': "Surah ${s['name_id']}",
                            'mulai': "${s['id']}:1",
                            'akhir': "${s['id']}:${s['total_ayah']}",
                          }),
                        );
                      },
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text("Error: $e"),
                  ),
                  _buildHalamanList(context, ref),
                  _buildJuzList(context, ref),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHalamanList(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      itemCount: 604,
      itemBuilder: (context, index) {
        final hal = index + 1;
        return ListTile(
          leading: const Icon(Icons.import_contacts, size: 20, color: Colors.grey),
          title: Text("Halaman $hal", style: const TextStyle(fontWeight: FontWeight.bold)),
          onTap: () async {
            final bounds = await ref.read(getMushafBoundsProvider(halaman: hal).future);
            if (context.mounted) {
              Navigator.pop(context, {
                'nama': "Halaman $hal",
                'mulai': bounds['mulai'] ?? '',
                'akhir': bounds['akhir'] ?? '',
              });
            }
          },
        );
      },
    );
  }

  Widget _buildJuzList(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      itemCount: 30,
      itemBuilder: (context, index) {
        final juz = index + 1;
        return ListTile(
          leading: const Icon(Icons.auto_awesome_motion_rounded, size: 20, color: Colors.grey),
          title: Text("Juz $juz", style: const TextStyle(fontWeight: FontWeight.bold)),
          onTap: () async {
            final bounds = await ref.read(getMushafBoundsProvider(juz: juz).future);
            if (context.mounted) {
              Navigator.pop(context, {
                'nama': "Juz $juz",
                'mulai': bounds['mulai'] ?? '',
                'akhir': bounds['akhir'] ?? '',
              });
            }
          },
        );
      },
    );
  }
}