import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../routes/app_routes.dart';
import '../providers/mushaf_provider.dart';

/// Widget untuk menampilkan daftar 114 Surah
class SurahListWidget extends ConsumerWidget {
  const SurahListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahAsync = ref.watch(surahListProvider);
    final searchQuery = ref.watch(mushafSearchProvider).toLowerCase();

    return surahAsync.when(
      data: (allSurahs) {
        // Filter berdasarkan pencarian
        final filteredList = allSurahs.where((s) {
          final name = s['surah_name'].toString().toLowerCase();
          return name.contains(searchQuery);
        }).toList();

        if (filteredList.isEmpty) {
          return const Center(child: Text("Surah tidak ditemukan"));
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: filteredList.length,
          separatorBuilder: (context, index) => Divider(
            color: Colors.grey.withValues(alpha: 0.1),
            height: 1,
          ),
          itemBuilder: (context, index) {
            final surah = filteredList[index];
            return Material(
              color: Colors.transparent,
              child: ListTile(
                leading: Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFD4AF37), width: 1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    "${surah['surah_number']}",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B4513),
                    ),
                  ),
                ),
                title: Text(
                  surah['surah_name'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                subtitle: Text(
                  "Halaman ${surah['page_number']}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                trailing: const Icon(Icons.chevron_right, color: Color(0xFFD4AF37)),
                onTap: () {
                  // Update provider halaman aktif
                  ref.read(currentPageProvider.notifier).state = surah['page_number'];
                  // FIX: Menggunakan .push agar navigasi menumpuk di atas layout index
                  ref.read(routerProvider).push('/mushaf');
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text("Error: $err")),
    );
  }
}

/// Widget untuk menampilkan Grid 30 Juz
class JuzGridWidget extends ConsumerWidget {
  const JuzGridWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mapping halaman awal tiap Juz (Standar Madinah)
    final List<int> juzPages = [
      1, 22, 42, 62, 82, 102, 122, 142, 162, 182,
      202, 222, 242, 262, 282, 302, 322, 342, 362, 382,
      402, 422, 442, 462, 482, 502, 522, 542, 562, 582
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: 30,
      itemBuilder: (context, index) {
        final int pageNumber = juzPages[index];

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              ref.read(currentPageProvider.notifier).state = pageNumber;
              // FIX: Menggunakan .push agar navigasi menumpuk di atas layout index
              ref.read(routerProvider).push('/mushaf');
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBE7),
                border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "JUZ",
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF8B4513),
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${index + 1}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Hal. $pageNumber",
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}