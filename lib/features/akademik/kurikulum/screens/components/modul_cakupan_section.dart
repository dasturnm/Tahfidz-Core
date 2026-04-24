// Lokasi: lib/features/akademik/kurikulum/screens/components/modul_cakupan_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/kurikulum_model.dart';
import '../../../../mushaf/providers/mushaf_provider.dart'; // Mundur ke folder mushaf
import 'modul_shared_widgets.dart';

class ModulCakupanSection extends ConsumerWidget {
  final bool isPlottingActive;
  final List<SilabusItemModel> silabusItems;
  final String silabusSource;
  final String selectedMetrik;
  final TextEditingController mulaiController;
  final TextEditingController akhirController;
  final int? surahIdForAyat;
  final ValueChanged<int?> onSurahAyatChanged;
  final VoidCallback onRangeChanged;

  const ModulCakupanSection({
    super.key,
    required this.isPlottingActive,
    required this.silabusItems,
    required this.silabusSource,
    required this.selectedMetrik,
    required this.mulaiController,
    required this.akhirController,
    required this.surahIdForAyat,
    required this.onSurahAyatChanged,
    required this.onRangeChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isPlottingActive && silabusItems.isNotEmpty) {
      return _buildSyllabusDropdownRange();
    }

    if (silabusSource == 'mushaf') {
      if (selectedMetrik == 'AYAT') return _buildAyatScopeSelector(ref);
      if (selectedMetrik == 'JUZ') return _buildDropdownRange(List.generate(30, (i) => (i + 1).toString()));
      if (selectedMetrik == 'HALAMAN') return _buildDropdownRange(List.generate(604, (i) => (i + 1).toString()));
      if (selectedMetrik == 'SURAH') {
        final surahAsync = ref.watch(surahListProvider);
        return surahAsync.maybeWhen(
          data: (list) => _buildDropdownRange(list.map((s) => s['surah_name'].toString()).toList()),
          orElse: () => _buildTextRange(false),
        );
      }
    }
    return _buildTextRange(silabusSource == 'internal' && isPlottingActive);
  }

  Widget _buildSyllabusDropdownRange() {
    List<String> options = silabusItems.map((e) => "${e.pertemuan}. ${e.materi}").toList();
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: options.any((o) => o.startsWith("${mulaiController.text}. ")) ? options.firstWhere((o) => o.startsWith("${mulaiController.text}. ")) : null,
            decoration: ModulSharedWidgets.inputStyle("Mulai"),
            items: options.map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(fontSize: 10), overflow: TextOverflow.ellipsis))).toList(),
            onChanged: (v) {
              mulaiController.text = v!.split('.').first;
              onRangeChanged();
            },
          ),
        ),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.arrow_forward, color: Colors.grey, size: 16)),
        Expanded(
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: options.any((o) => o.startsWith("${akhirController.text}. ")) ? options.firstWhere((o) => o.startsWith("${akhirController.text}. ")) : null,
            decoration: ModulSharedWidgets.inputStyle("Akhir"),
            items: options.map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(fontSize: 10), overflow: TextOverflow.ellipsis))).toList(),
            onChanged: (v) {
              akhirController.text = v!.split('.').first;
              onRangeChanged();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAyatScopeSelector(WidgetRef ref) {
    final surahAsync = ref.watch(surahListProvider);
    return surahAsync.maybeWhen(
      data: (list) => Column(
        children: [
          DropdownButtonFormField<int>(
            isExpanded: true,
            initialValue: surahIdForAyat,
            decoration: ModulSharedWidgets.inputStyle("Pilih Surah Terlebih Dahulu"),
            items: list.map((s) => DropdownMenuItem<int>(value: (s['surah_number'] as num?)?.toInt() ?? 0, child: Text("${s['surah_number']}. ${s['surah_name']}"))).toList(),
            onChanged: (v) => onSurahAyatChanged(v),
          ),
          const SizedBox(height: 12),
          if (surahIdForAyat != null)
            _buildAyatRangeDropdowns(list),
        ],
      ),
      orElse: () => const Text("Memuat Surah..."),
    );
  }

  Widget _buildAyatRangeDropdowns(List<dynamic> surahList) {
    final surah = surahList.firstWhere(
          (e) => (e['surah_number'] as num?)?.toInt() == surahIdForAyat,
      orElse: () => <String, dynamic>{},
    );

    if (surah.isEmpty) return const SizedBox();

    int totalAyah = (surah['total_ayah'] as num?)?.toInt() ?? 0;
    if (totalAyah == 0) return const Text("Data ayat tidak ditemukan (NULL)", style: TextStyle(color: Colors.red, fontSize: 10));

    List<String> ayahs = List.generate(totalAyah, (i) => (i + 1).toString());

    return _buildDropdownRange(ayahs);
  }

  Widget _buildDropdownRange(List<String> options) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: options.contains(mulaiController.text) ? mulaiController.text : null,
            decoration: ModulSharedWidgets.inputStyle("Mulai"),
            items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
            onChanged: (v) {
              mulaiController.text = v!;
              onRangeChanged();
            },
          ),
        ),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Icon(Icons.arrow_forward, color: Colors.grey, size: 16)),
        Expanded(
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: options.contains(akhirController.text) ? akhirController.text : null,
            decoration: ModulSharedWidgets.inputStyle("Akhir"),
            items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
            onChanged: (v) {
              akhirController.text = v!;
              onRangeChanged();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTextRange(bool isNomor) {
    return Row(children: [
      Expanded(child: TextFormField(controller: mulaiController, enabled: !isNomor, decoration: ModulSharedWidgets.inputStyle(isNomor ? "Auto" : "Mulai"))),
      const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Icon(Icons.arrow_forward, color: Colors.grey)),
      Expanded(child: TextFormField(controller: akhirController, enabled: !isNomor, decoration: ModulSharedWidgets.inputStyle(isNomor ? "Auto" : "Akhir"))),
    ]);
  }
}