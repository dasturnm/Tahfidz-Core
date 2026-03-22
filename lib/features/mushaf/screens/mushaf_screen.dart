import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/mushaf_provider.dart';
import '../widgets/mushaf_page_view.dart';

class MushafScreen extends ConsumerStatefulWidget {
  const MushafScreen({super.key});

  @override
  ConsumerState<MushafScreen> createState() => _MushafScreenState();
}

class _MushafScreenState extends ConsumerState<MushafScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan halaman yang dipilih dari Index
    final initialPage = ref.read(currentPageProvider) - 1;
    _pageController = PageController(initialPage: initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = ref.watch(currentPageProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F2), // Warna krem kertas mushaf
      appBar: AppBar(
        title: const Text("Mushaf Al-Qur'an"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {}, // Poin 1: Toggle Search
          ),
          IconButton(
            icon: const Icon(Icons.format_list_bulleted),
            onPressed: () {}, // Poin 2 & 3: Akses Tab Surah/Juz
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text("$currentPage", style: const TextStyle(fontSize: 16)),
            ),
          )
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        reverse: true, // Kanan ke Kiri
        itemCount: 604,
        onPageChanged: (index) {
          ref.read(currentPageProvider.notifier).state = index + 1;
        },
        itemBuilder: (context, index) {
          final pageNumber = index + 1;
          final pageData = ref.watch(mushafPageProvider(pageNumber));

          return pageData.when(
            data: (lines) => MushafPageView(lines: lines),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text("Gagal memuat: $err")),
          );
        },
      ),
    );
  }
}