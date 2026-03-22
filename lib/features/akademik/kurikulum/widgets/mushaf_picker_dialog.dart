import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/quran_provider.dart';

// Provider lokal untuk pencarian agar MushafPickerDialog tetap ConsumerWidget
final quranSearchProvider = StateProvider.autoDispose<String>((ref) => "");

class MushafPickerDialog extends ConsumerWidget {
  const MushafPickerDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahAsync = ref.watch(quranSurahListProvider);
    final search = ref.watch(quranSearchProvider).toLowerCase();
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
            const SizedBox(height: 16),

            // FITUR SEARCH (Poin 3)
            TextField(
              onChanged: (v) => ref.read(quranSearchProvider.notifier).state = v,
              decoration: InputDecoration(
                hintText: "Cari Surah, Juz, atau Halaman...",
                prefixIcon: const Icon(Icons.search, color: emerald),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),

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
                    data: (list) {
                      // Filter Surah (Poin 3)
                      final filtered = list.where((s) =>
                      (s['name_id'] ?? '').toString().toLowerCase().contains(search) ||
                          (s['nama_latin'] ?? '').toString().toLowerCase().contains(search) ||
                          (s['namaLatin'] ?? '').toString().toLowerCase().contains(search) ||
                          (s['name'] ?? '').toString().toLowerCase().contains(search)
                      ).toList();

                      return ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final s = filtered[index];
                          // PERBAIKAN: Handle variasi key API agar nama surah pasti muncul (Poin 1 & 3)
                          final String surahName = s['name_id'] ?? s['nama_latin'] ?? s['namaLatin'] ?? s['nama'] ?? s['name'] ?? 'Surah';

                          return ListTile(
                            // FIX KLIK: Memastikan Material behavior dan padding yang nyaman
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            title: Text(surahName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("${s['total_ayah']} Ayat"),
                            onTap: () => Navigator.pop(context, {
                              'nama': "Surah $surahName",
                              'mulai': "${s['id']}:1",
                              'akhir': "${s['id']}:${s['total_ayah']}",
                            }),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator(color: emerald)),
                    error: (e, _) => Text("Error: $e"),
                  ),
                  _buildHalamanList(context, ref, search),
                  _buildJuzList(context, ref, search),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHalamanList(BuildContext context, WidgetRef ref, String search) {
    // Filter Halaman (Poin 3)
    final List<int> pages = List.generate(604, (i) => i + 1)
        .where((h) => search.isEmpty || h.toString().contains(search))
        .toList();

    return ListView.builder(
      itemCount: pages.length,
      itemBuilder: (context, index) {
        final hal = pages[index];
        return ListTile(
          leading: const Icon(Icons.import_contacts, size: 20, color: Colors.grey),
          title: Text("Halaman $hal", style: const TextStyle(fontWeight: FontWeight.bold)),
          onTap: () async {
            // FIX KLIK: Menambahkan Loading indicator saat fetch bounds
            showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xFF10B981))));

            final bounds = await ref.read(getMushafBoundsProvider(halaman: hal).future);

            if (context.mounted) {
              Navigator.pop(context); // Tutup loading
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

  Widget _buildJuzList(BuildContext context, WidgetRef ref, String search) {
    // Filter Juz (Poin 3)
    final List<int> juzs = List.generate(30, (i) => i + 1)
        .where((j) => search.isEmpty || j.toString().contains(search))
        .toList();

    return ListView.builder(
      itemCount: juzs.length,
      itemBuilder: (context, index) {
        final juz = juzs[index];
        return ListTile(
          leading: const Icon(Icons.auto_awesome_motion_rounded, size: 20, color: Colors.grey),
          title: Text("Juz $juz", style: const TextStyle(fontWeight: FontWeight.bold)),
          onTap: () async {
            // FIX KLIK: Menambahkan Loading indicator saat fetch bounds
            showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xFF10B981))));

            final bounds = await ref.read(getMushafBoundsProvider(juz: juz).future);

            if (context.mounted) {
              Navigator.pop(context); // Tutup loading
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