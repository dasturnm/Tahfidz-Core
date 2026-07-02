// Lokasi: lib/features/akademik/kurikulum/screens/components/modul_cakupan_section.dart
import 'package:flutter/material.dart';
import 'modul_shared_widgets.dart';

class ModulCakupanSection extends StatelessWidget {
  final bool isPlottingActive;
  final List<dynamic> silabusItems;
  final String silabusSource;
  final String selectedMetrik;
  final TextEditingController mulaiController;
  final TextEditingController akhirController;
  final int? surahIdForAyah;
  final List<dynamic> surahList;
  final List<int> juzList;
  final List<int> halamanList;
  final Function(int) onSurahChanged;
  final VoidCallback onRangeChanged;

  const ModulCakupanSection({
    super.key,
    required this.isPlottingActive,
    required this.silabusItems,
    required this.silabusSource,
    required this.selectedMetrik,
    required this.mulaiController,
    required this.akhirController,
    this.surahIdForAyah,
    this.surahList = const [],
    required this.juzList,
    required this.halamanList,
    required this.onSurahChanged,
    required this.onRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Cabang untuk Silabus Internal (Buku/Diniyah)
    if (silabusSource == 'internal') {
      // FIX: Jika plotting aktif dan ada data CSV, tampilkan Dropdown Materi (Point Penyempurnaan)
      if (isPlottingActive && silabusItems.isNotEmpty) {
        return _buildInternalMateriCakupan();
      }
      return _buildNumberCakupan("Pertemuan", silabusItems.length);
    }

    // 2. Cabang untuk Silabus Mushaf (Al-Qur'an)
    // FIX: Menambahkan return yang hilang untuk kondisi Mushaf
    switch (selectedMetrik) {
      case 'SURAH':
        return _buildSurahCakupan();
      case 'JUZ':
        return _buildDualDropdown(juzList, "Juz");
      case 'HALAMAN':
        return _buildDualDropdown(halamanList, "Halaman");
      case 'AYAT':
        return _buildAyatCakupan();
      default:
        return _buildNumberCakupan("Nomor", 100);
    }
  }

  Widget _buildDualDropdown(List<int> data, String label) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ModulSharedWidgets.buildLabel("$label Mulai"),
              const SizedBox(height: 8),
              _buildGenericDropdown(mulaiController, data, "Mulai"),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ModulSharedWidgets.buildLabel("$label Akhir"),
              const SizedBox(height: 8),
              _buildGenericDropdown(akhirController, data, "Akhir"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGenericDropdown(TextEditingController controller, List<int> data, String hint) {
    return Autocomplete<String>(
      displayStringForOption: (option) => option,
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) return data.map((e) => e.toString());
        return data.where((e) => e.toString().contains(textEditingValue.text)).map((e) => e.toString());
      },
      fieldViewBuilder: (context, fieldController, focusNode, onFieldSubmitted) {
        if (fieldController.text != controller.text) fieldController.text = controller.text;
        return TextFormField(
          controller: fieldController,
          focusNode: focusNode,
          keyboardType: TextInputType.number,
          decoration: ModulSharedWidgets.inputStyle(hint),
          onChanged: (v) {
            controller.text = v;
            onRangeChanged();
          },
        );
      },
      onSelected: (String selection) {
        controller.text = selection;
        onRangeChanged();
      },
    );
  }

  Widget _buildSurahCakupan() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ModulSharedWidgets.buildLabel("Surah Mulai"),
              const SizedBox(height: 8),
              _buildSurahDropdown(mulaiController),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ModulSharedWidgets.buildLabel("Surah Akhir"),
              const SizedBox(height: 8),
              _buildSurahDropdown(akhirController),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAyatCakupan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ModulSharedWidgets.buildLabel("Pilih Surah"),
        const SizedBox(height: 8),
        _buildSurahDropdown(null, isForAyahParent: true),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ModulSharedWidgets.buildLabel("Ayat Mulai"),
                  const SizedBox(height: 8),
                  _buildAyatDropdown(mulaiController),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ModulSharedWidgets.buildLabel("Ayat Akhir"),
                  const SizedBox(height: 8),
                  _buildAyatDropdown(akhirController),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSurahDropdown(TextEditingController? controller, {bool isForAyahParent = false}) {
    final String? currentValue = isForAyahParent ? surahIdForAyah?.toString() : controller?.text;
    final bool isValueValid = surahList.any((s) => s['surah_number'].toString() == currentValue);
    final String? effectiveValue = isValueValid ? currentValue : null;

    return DropdownButtonFormField<String>(
      initialValue: effectiveValue,
      isExpanded: true,
      decoration: ModulSharedWidgets.inputStyle("Pilih Surah"),
      items: surahList.map((s) => DropdownMenuItem<String>(
        value: s['surah_number'].toString(),
        child: Text("${s['surah_number']}. ${s['surah_name']}",
            style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
      )).toList(),
      onChanged: (v) {
        if (v != null) {
          final int sId = int.parse(v);
          if (isForAyahParent) {
            onSurahChanged(sId);
          } else {
            controller?.text = v;
            onRangeChanged();
          }
        }
      },
    );
  }

  Widget _buildAyatDropdown(TextEditingController controller) {
    final surahData = surahList.firstWhere(
          (s) => s['surah_number'].toString() == surahIdForAyah.toString(),
      orElse: () => {'total_ayah': 1},
    );

    final int totalAyah = surahData['total_ayah'] ?? 1;
    final List<String> ayatItems = List.generate(totalAyah, (i) => (i + 1).toString());

    final bool isValueValid = ayatItems.contains(controller.text);
    final String? effectiveValue = isValueValid ? controller.text : (ayatItems.isNotEmpty ? "1" : null);

    return DropdownButtonFormField<String>(
      initialValue: effectiveValue,
      decoration: ModulSharedWidgets.inputStyle("Ayat"),
      items: ayatItems.map((a) => DropdownMenuItem(
        value: a,
        child: Text(a, style: const TextStyle(fontSize: 12)),
      )).toList(),
      onChanged: (v) {
        if (v != null) {
          controller.text = v;
          onRangeChanged();
        }
      },
    );
  }

  Widget _buildNumberCakupan(String label, int max) {
    final List<int> data = List.generate(max, (i) => i + 1);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ModulSharedWidgets.buildLabel("$label Mulai"),
              const SizedBox(height: 8),
              _buildGenericDropdown(mulaiController, data, "1"),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ModulSharedWidgets.buildLabel("$label Akhir"),
              const SizedBox(height: 8),
              _buildGenericDropdown(akhirController, data, max.toString()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInternalMateriCakupan() {
    final List<String> materiList = silabusItems.asMap().entries.map((entry) {
      return "${entry.key + 1}. ${entry.value.materi}";
    }).toList();

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ModulSharedWidgets.buildLabel("Materi Mulai"),
              const SizedBox(height: 8),
              _buildMateriDropdown(mulaiController, materiList),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ModulSharedWidgets.buildLabel("Materi Akhir"),
              const SizedBox(height: 8),
              _buildMateriDropdown(akhirController, materiList),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMateriDropdown(TextEditingController controller, List<String> data) {
    final bool isValueValid = data.contains(controller.text);
    final String? effectiveValue = isValueValid ? controller.text : (data.isNotEmpty ? data.first : null);

    return DropdownButtonFormField<String>(
      initialValue: effectiveValue,
      isExpanded: true,
      decoration: ModulSharedWidgets.inputStyle("Pilih Materi"),
      items: data.map((String e) => DropdownMenuItem(
        value: e,
        child: Text(e, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
      )).toList(),
      onChanged: (v) {
        if (v != null) {
          controller.text = v;
          onRangeChanged();
        }
      },
    );
  }
}