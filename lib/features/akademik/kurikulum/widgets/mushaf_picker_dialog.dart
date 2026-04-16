import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../features/mushaf/providers/mushaf_provider.dart';

// Provider lokal untuk pencarian agar MushafPickerDialog tetap ConsumerWidget
final quranSearchProvider = StateProvider.autoDispose<String>((ref) => "");

class MushafPickerDialog extends ConsumerWidget {
  const MushafPickerDialog({super.key});

  // Helper lokal untuk query bounds halaman/juz langsung ke tabel data_mushaf
  Future<Map<String, String>> _getMushafBounds({int? halaman, int? juz}) async {
    try {
      final supabase = Supabase.instance.client;
      // FIX: Tambahkan 'id' ke dalam select agar bisa dilakukan ordering
      var query = supabase.from('data_mushaf').select('id, surah_number, ayah_number');

      if (halaman != null) query = query.eq('page_number', halaman);
      if (juz != null) query = query.eq('juz_number', juz);

      final res = await query.order('id', ascending: true);

      if (res.isEmpty) return {'mulai': '', 'akhir': ''};

      final first = res.first;
      final last = res.last;

      return {
        'mulai': "${first['surah_number']}:${first['ayah_number']}",
        'akhir': "${last['surah_number']}:${last['ayah_number']}",
      };
    } catch (e) {
      debugPrint("❌ Error fetching bounds: $e");
      return {'mulai': '', 'akhir': ''};
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahAsync = ref.watch(surahListProvider);
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
                      // Filter Surah (Poin 3) menggunakan kolom data_mushaf
                      final filtered = list.where((s) =>
                      (s['surah_name'] ?? '').toString().toLowerCase().contains(search) ||
                          (s['surah_number'] ?? '').toString().contains(search)
                      ).toList();

                      return ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final s = filtered[index];
                          // PERBAIKAN: Menggunakan kolom tabel data_mushaf (surah_name)
                          final String surahName = s['surah_name'] ?? 'Surah';

                          return ListTile(
                            // FIX KLIK: Memastikan Material behavior dan padding yang nyaman
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            title: Text(surahName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("${s['total_ayah'] ?? 0} Ayat"),
                            onTap: () => Navigator.pop(context, {
                              'nama': "Surah $surahName",
                              'mulai': "${s['surah_number']}:1",
                              'akhir': "${s['surah_number']}:${s['total_ayah'] ?? 0}",
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

            // Menggunakan helper lokal
            final bounds = await _getMushafBounds(halaman: hal);

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

            // Menggunakan helper lokal
            final bounds = await _getMushafBounds(juz: juz);

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