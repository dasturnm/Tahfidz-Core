// Lokasi: lib/features/akademik/screens/akademik_hub_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../kurikulum/providers/kurikulum_provider.dart';
import '../kurikulum/models/kurikulum_model.dart';
import '../kurikulum/screens/kurikulum_detail_screen.dart'; // PERBAIKAN: Import file terpisah
import '../kurikulum/widgets/kurikulum_card.dart';
// IMPORT MODULAR: Memisahkan komponen agar Hub tetap ramping sesuai nama sub-judul
import '../kurikulum/widgets/katalog_modul_view.dart';
import '../kurikulum/widgets/pemetaan_kelas_view.dart';

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
    final kurikulumAsync = ref.watch(kurikulumListProvider(widget.lembagaId));

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
                  if (_selectedTab != 0) return RefreshIndicator(
                    onRefresh: () => ref.refresh(kurikulumListProvider(widget.lembagaId).future),
                    color: _emerald,
                    child: _buildActiveKurikulumContent(sortedList),
                  );

                  if (list.isEmpty) return _buildEmptyState("Belum ada blueprint kurikulum.");

                  // Tampilkan Daftar Kurikulum (Blueprint)
                  return RefreshIndicator(
                    onRefresh: () => ref.refresh(kurikulumListProvider(widget.lembagaId).future),
                    color: _emerald,
                    child: _buildMainScrollableContent(sortedList, filteredList),
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
        onPressed: () => _showAddKurikulumSheet(context),
        backgroundColor: _slate,
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
    );
  }

  // PERBAIKAN: Memisahkan konten agar selalu bisa di-scroll untuk RefreshIndicator
  Widget _buildMainScrollableContent(List<KurikulumModel> fullList, List<KurikulumModel> filteredList) {
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
          ? _buildKurikulumGrid(filteredList)
          : _buildKurikulumTable(filteredList);
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
          border: Border.all(color: isActive ? _emerald.withOpacity(0.1) : Colors.transparent),
          boxShadow: isActive ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)] : null,
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

  Widget _buildKurikulumGrid(List<KurikulumModel> list) {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(), // Wajib untuk RefreshIndicator
      padding: const EdgeInsets.all(32),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1, // Disesuaikan untuk mobile
        mainAxisSpacing: 24,
        childAspectRatio: 0.85,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final k = list[index];
        return KurikulumCard(
          kurikulum: k,
          onTap: () => setState(() {
            _activeKurikulum = k;
            _isListView = false;
          }),
          // PERBAIKAN: Menghubungkan tombol Edit
          onEdit: () => _showAddKurikulumSheet(context, kurikulum: k),
          // PERBAIKAN: Menghubungkan tombol Hapus dengan refresh state dan dialog konfirmasi
          onDelete: () => _confirmDelete(context, k),
        );
      },
    );
  }

  // PERBAIKAN POIN 2 & 4: Table View Modern (Glassmorphism Style)
  Widget _buildKurikulumTable(List<KurikulumModel> list) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(), // Wajib untuk RefreshIndicator
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final k = list[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            title: Row(
              children: [
                // PERBAIKAN: Gunakan Expanded untuk mencegah overflow teks nama kurikulum
                Expanded(
                  child: Text(
                    k.namaKurikulum,
                    style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                // Indikator Level Tunggal vs Hierarki
                _buildBadge(k.isLinear ? "LINEAR" : "HIERARKI", k.isLinear ? Colors.orange : _emerald),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                "${k.jenjangs.length} Jng | ${k.totalLevels} Lvl | ${k.totalModules} Mod",
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
              ),
            ),
            // PERBAIKAN: Menambah menu aksi pada tampilan tabel dengan dialog konfirmasi
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
              onSelected: (val) async {
                if (val == 'edit') _showAddKurikulumSheet(context, kurikulum: k);
                if (val == 'delete') _confirmDelete(context, k);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text("Edit")),
                const PopupMenuItem(value: 'delete', child: Text("Hapus", style: TextStyle(color: Colors.red))),
              ],
            ),
            onTap: () => setState(() {
              _activeKurikulum = k;
              _isListView = false;
            }),
          ),
        );
      },
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
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

  // --- MODAL TAMBAH/EDIT KURIKULUM (Untuk Tombol Plus & Edit) ---
  void _showAddKurikulumSheet(BuildContext context, {KurikulumModel? kurikulum}) {
    final nameController = TextEditingController(text: kurikulum?.namaKurikulum);
    bool isLinear = kurikulum?.isLinear ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
              left: 32, right: 32, top: 32
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  kurikulum == null ? "Buat Blueprint Baru" : "Edit Blueprint",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)
              ),
              const SizedBox(height: 32),
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: "NAMA KURIKULUM",
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Mode Linear", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Tanpa jenjang bertingkat/level."),
                value: isLinear,
                onChanged: (val) => setState(() => isLinear = val),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty) return;

                    final data = KurikulumModel(
                      id: kurikulum?.id,
                      lembagaId: widget.lembagaId,
                      namaKurikulum: nameController.text.trim(),
                      isLinear: isLinear,
                      jenjangs: kurikulum?.jenjangs ?? [],
                    );

                    // PERBAIKAN: Gunakan await dan invalidate agar UI refresh
                    await ref.read(kurikulumListProvider(widget.lembagaId).notifier).saveKurikulum(data);
                    ref.invalidate(kurikulumListProvider(widget.lembagaId));

                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: _slate, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: Text(
                      kurikulum == null ? "SIMPAN" : "PERBARUI",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                  ),
                ),
              ),
            ],
          ),
        ),
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

  // TAMBAHAN: Dialog Konfirmasi Hapus
  void _confirmDelete(BuildContext context, KurikulumModel k) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Hapus Kurikulum?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Apakah Anda yakin ingin menghapus '${k.namaKurikulum}'? Semua data jenjang, level, dan modul di dalamnya akan ikut terhapus."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(kurikulumListProvider(widget.lembagaId).notifier).deleteKurikulum(k.id!);
              ref.invalidate(kurikulumListProvider(widget.lembagaId));
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}