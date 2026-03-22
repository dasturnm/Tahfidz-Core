import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/mushaf_provider.dart';
import '../widgets/surah_juz_list_widget.dart';

class MushafIndexScreen extends ConsumerStatefulWidget {
  const MushafIndexScreen({super.key});

  @override
  ConsumerState<MushafIndexScreen> createState() => _MushafIndexScreenState();
}

class _MushafIndexScreenState extends ConsumerState<MushafIndexScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: _isSearching
              ? _buildSearchField()
              : const Text("Mushaf Al-Qur'an"),
          actions: [
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchController.clear();
                    ref.read(mushafSearchProvider.notifier).state = "";
                  }
                });
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: "SURAH"),
              Tab(text: "JUZ"),
            ],
            indicatorColor: Color(0xFFD4AF37),
            labelColor: Color(0xFFD4AF37),
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
        ),
        body: const TabBarView(
          children: [
            SurahListWidget(), // POIN 2: Tab Surah
            JuzGridWidget(),   // POIN 3: Tab Juz
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: "Cari nama surah...",
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
      ),
      style: const TextStyle(fontSize: 16),
      onChanged: (value) {
        // POIN 1: Update provider pencarian secara real-time
        ref.read(mushafSearchProvider.notifier).state = value;
      },
    );
  }
}