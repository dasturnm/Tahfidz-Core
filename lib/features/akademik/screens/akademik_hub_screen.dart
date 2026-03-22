// Lokasi: lib/features/akademik/screens/akademik_hub_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_context_provider.dart'; // PERBAIKAN: Import Context
import '../kurikulum/providers/kurikulum_provider.dart';
import '../kurikulum/models/kurikulum_model.dart';
import '../kurikulum/screens/kurikulum_detail_screen.dart'; // PERBAIKAN: Import file terpisah
// IMPORT MODULAR: Memisahkan komponen agar Hub tetap ramping sesuai nama sub-judul
import '../kurikulum/widgets/katalog_modul_view.dart';
import '../kurikulum/widgets/pemetaan_kelas_view.dart';
import '../kurikulum/widgets/add_kurikulum_sheet.dart'; // IMPORT BARU
import '../kurikulum/widgets/kurikulum_grid_view.dart'; // IMPORT BARU
import '../kurikulum/widgets/kurikulum_table_view.dart'; // IMPORT BARU

class AkademikHubScreen extends ConsumerStatefulWidget {
  final String lembagaId;
  const AkademikHubScreen({super.key, required this.lembagaId});

  @override
  ConsumerState<AkademikHubScreen> createState() => _AkademikHubScreenState();
}

class _AkademikHubScreenState extends ConsumerState<AkademikHubScreen> {
  bool _isGridView = true;
  int _selectedTab = 0; // 0: Daftar Kurikulum, 1: Katalog Modul, 2: Pemetaan Kelas
  bool _isListView = true; // True: Daftar Kurikulum, False: Detail Jenjang
  KurikulumModel? _activeKurikulum;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = ""; // TAMBAHAN: State pencarian
  String _sortBy = "Terbaru"; // TAMBAHAN: State untuk filter

  final Color _emerald = const Color(0xFF10B981);
  final Color _slate = const Color(0xFF1E293B);

  @override
  void initState() {
    super.initState();
    // PERBAIKAN: Menghubungkan controller ke state pencarian agar reaktif
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // FIX: Ambil lembagaId secara reaktif dari context agar data muncul otomatis saat inisialisasi selesai
    final appContext = ref.watch(appContextProvider);
    final effectiveLembagaId = appContext.lembaga?.id ?? widget.lembagaId;

    final kurikulumAsync = ref.watch(kurikulumListProvider(effectiveLembagaId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchAndFilterRow(), // PERBAIKAN POIN 3: Baris Pencarian Permanen
            _buildSubMenuTabs(),
            Expanded(
              child: kurikulumAsync.when(
                data: (list) {
                  // PERBAIKAN: Sortir list utama agar filter global aktif di semua Tab
                  var sortedList = List<KurikulumModel>.from(list);
                  if (_sortBy == "A-Z") {
                    sortedList.sort((a, b) => a.namaKurikulum.toLowerCase().compareTo(b.namaKurikulum.toLowerCase()));
                  } else if (_sortBy == "Terbaru") {
                    sortedList = sortedList.reversed.toList();
                  }

                  // Logika Filtering Pencarian (Khusus Tab 0)
                  var filteredList = sortedList.where((k) =>
                      k.namaKurikulum.toLowerCase().contains(_searchQuery)
                  ).toList();

                  // PERBAIKAN: Implementasi RefreshIndicator untuk menarik data (Pull to Refresh)
                  // Gunakan sortedList agar Katalog & Pemetaan terpengaruh filter
                  if (_selectedTab != 0) {
                    return RefreshIndicator(
                      onRefresh: () => ref.refresh(kurikulumListProvider(effectiveLembagaId).future),
                      color: _emerald,
                      child: _buildActiveKurikulumContent(sortedList),
                    );
                  }

                  if (list.isEmpty) return _buildEmptyState("Belum ada blueprint kurikulum.");

                  // Tampilkan Daftar Kurikulum (Blueprint)
                  return RefreshIndicator(
                    onRefresh: () => ref.refresh(kurikulumListProvider(effectiveLembagaId).future),
                    color: _emerald,
                    child: _buildMainScrollableContent(sortedList, filteredList, effectiveLembagaId),
                  );
                },
                loading: () => Center(child: CircularProgressIndicator(color: _emerald)),
                error: (e, _) => Center(child: Text("Error: $e")),
              ),
            ),
          ],
        ),
      ),
      // PERBAIKAN: Menambahkan kembali Tombol Plus (FAB) di pojok kanan bawah
      floatingActionButton: (_selectedTab == 0 && _isListView)
          ? FloatingActionButton(
        onPressed: () => AddKurikulumSheet.show(
          context: context,
          ref: ref,
          lembagaId: effectiveLembagaId,
          slate: _slate,
        ),
        backgroundColor: _slate,
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
    );
  }

  // PERBAIKAN: Memisahkan konten agar selalu bisa di-scroll untuk RefreshIndicator
  Widget _buildMainScrollableContent(List<KurikulumModel> fullList, List<KurikulumModel> filteredList, String effectiveLembagaId) {
    if (_selectedTab != 0) return _buildActiveKurikulumContent(fullList);

    if (fullList.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          _buildEmptyState("Belum ada blueprint kurikulum."),
        ],
      );
    }

    if (_isListView) {
      return _isGridView
          ? KurikulumGridView(
        list: filteredList,
        lembagaId: effectiveLembagaId,
        slate: _slate,
        onSelect: (k) => setState(() {
          _activeKurikulum = k;
          _isListView = false;
        }),
      )
          : KurikulumTableView(
        list: filteredList,
        lembagaId: effectiveLembagaId,
        emerald: _emerald,
        slate: _slate,
        onSelect: (k) => setState(() {
          _activeKurikulum = k;
          _isListView = false;
        }),
      );
    }

    return _buildActiveKurikulumContent(filteredList);
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 8),
      child: Row(
        children: [
          if (!_isListView && _selectedTab == 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: IconButton(
                onPressed: () => setState(() => _isListView = true),
                icon: const Icon(Icons.arrow_back_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _slate,
                  padding: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),
            ),
          Expanded(
            child: Text(
              "Manajemen Akademik",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _slate, letterSpacing: -0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.grey, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: "Cari kurikulum atau modul...",
                            border: InputBorder.none,
                            hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // PERBAIKAN: Memberikan fungsi pada tombol filter (Modal sederhana)
              _iconActionButton(Icons.tune_rounded, () {
                _showFilterOptions(context);
              }),
              const SizedBox(width: 8),
              // PERBAIKAN POIN 2: Satu ikon dua fungsi (Toggle Grid/List)
              _iconActionButton(
                _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                    () => setState(() => _isGridView = !_isGridView),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _isListView || _selectedTab != 0 ? "Blueprint Pendidikan" : (_activeKurikulum?.namaKurikulum ?? "Detail"),
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _iconActionButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48, width: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Icon(icon, size: 20, color: _slate),
      ),
    );
  }

  Widget _buildSubMenuTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Row(
        children: [
          _tabButton(0, Icons.account_tree_outlined, "Daftar Kurikulum"),
          const SizedBox(width: 8),
          _tabButton(1, Icons.layers_outlined, "Katalog Modul"),
          const SizedBox(width: 8),
          _tabButton(2, Icons.language_outlined, "Pemetaan Kelas"),
        ],
      ),
    );
  }

  Widget _tabButton(int index, IconData icon, String label) {
    bool isActive = _selectedTab == index;
    return InkWell(
      onTap: () => setState(() {
        _selectedTab = index;
        if (index != 0) _isListView = true; // Reset ke list view jika pindah tab
      }),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isActive ? _emerald.withValues(alpha: 0.1) : Colors.transparent),
          boxShadow: isActive ? [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)] : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isActive ? _emerald : const Color(0xFF94A3B8)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isActive ? FontWeight.w900 : FontWeight.bold,
                color: isActive ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                fontSize: 10.5, // PERBAIKAN: Font size lebih kecil agar muat label panjang
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveKurikulumContent(List<KurikulumModel> dataList) {
    switch (_selectedTab) {
      case 0:
        if (_activeKurikulum == null) return _buildEmptyState("Pilih kurikulum terlebih dahulu.");
        return KurikulumDetailScreen(kurikulum: _activeKurikulum!);
      case 1:
      // PERBAIKAN: Tambahkan parameter sortBy
        return KatalogModulView(
          kurikulumList: dataList,
          searchQuery: _searchQuery,
          emerald: _emerald,
          isGridView: _isGridView,
          sortBy: _sortBy,
        );
      case 2:
      // PERBAIKAN: Tambahkan parameter sortBy
        return PemetaanKelasView(
          kurikulumList: dataList,
          emerald: _emerald,
          slate: _slate,
          isGridView: _isGridView,
          sortBy: _sortBy,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome_motion_rounded, size: 64, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // --- MODAL FILTER (Untuk Tombol Filter) ---
  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Urutkan Berdasarkan", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ListTile(
              leading: Icon(Icons.sort_by_alpha, color: _sortBy == "A-Z" ? _emerald : Colors.grey),
              title: Text("Urutkan A-Z", style: TextStyle(fontWeight: _sortBy == "A-Z" ? FontWeight.bold : FontWeight.normal)),
              onTap: () {
                setState(() => _sortBy = "A-Z");
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.history, color: _sortBy == "Terbaru" ? _emerald : Colors.grey),
              title: Text("Terbaru", style: TextStyle(fontWeight: _sortBy == "Terbaru" ? FontWeight.bold : FontWeight.normal)),
              onTap: () {
                setState(() => _sortBy = "Terbaru");
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}