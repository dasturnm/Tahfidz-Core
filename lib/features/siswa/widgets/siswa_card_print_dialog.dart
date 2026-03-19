// Lokasi: lib/features/siswa/widgets/siswa_card_print_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../providers/siswa_provider.dart';

class SiswaCardPrintDialog extends ConsumerStatefulWidget {
  const SiswaCardPrintDialog({super.key});

  @override
  ConsumerState<SiswaCardPrintDialog> createState() => _SiswaCardPrintDialogState();
}

class _SiswaCardPrintDialogState extends ConsumerState<SiswaCardPrintDialog> {
  final List<String> _selectedIds = [];

  Future<void> _generateCards() async {
    final pdf = pw.Document();
    final allSiswa = ref.read(siswaProvider).siswa;
    final selectedSiswa = allSiswa.where((s) => _selectedIds.contains(s.id)).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.GridView(
              crossAxisCount: 2,
              childAspectRatio: 0.6,
              children: selectedSiswa.map((s) {
                return pw.Container(
                  margin: const pw.EdgeInsets.all(10),
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text("KARTU SISWA", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Divider(),
                      pw.Container(width: 60, height: 80, color: PdfColors.grey300), // Placeholder Foto
                      pw.SizedBox(height: 10),
                      pw.Text(s.namaLengkap, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      pw.Text("NISN: ${s.nisn ?? '-'}", style: const pw.TextStyle(fontSize: 8)),
                      pw.Spacer(),
                      pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data: s.id ?? "",
                        width: 40,
                        height: 40,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    final siswa = ref.watch(siswaProvider).siswa;

    return AlertDialog(
      title: const Text("Cetak Kartu Siswa", style: TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: ListView.builder(
          itemCount: siswa.length,
          itemBuilder: (context, index) {
            final s = siswa[index];
            return CheckboxListTile(
              title: Text(s.namaLengkap, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              value: _selectedIds.contains(s.id),
              activeColor: const Color(0xFF4F46E5),
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    _selectedIds.add(s.id!);
                  } else {
                    _selectedIds.remove(s.id);
                  }
                });
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Batal", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _selectedIds.isEmpty ? null : _generateCards,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F46E5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text(
            "CETAK KARTU",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}