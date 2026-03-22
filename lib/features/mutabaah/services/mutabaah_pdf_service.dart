// Lokasi: lib/features/mutabaah/services/mutabaah_pdf_service.dart

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../siswa/models/siswa_model.dart';
import '../models/mutabaah_model.dart';

class MutabaahPdfService {
  static Future<void> generateMonthlyReport({
    required SiswaModel siswa,
    required Map<String, dynamic> stats,
    required String namaLembaga,
  }) async {
    final pdf = pw.Document();
    final records = stats['records'] as List<MutabaahRecord>;
    final bulan = DateFormat('MMMM yyyy').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // HEADER LAPORAN
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(namaLembaga.toUpperCase(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
                    pw.Text("Laporan Perkembangan Santri Bulanan", style: const pw.TextStyle(fontSize: 12)),
                  ],
                ),
                pw.Text(bulan, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // INFO Santri
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300)),
            child: pw.Column(
              children: [
                _buildInfoRow("Nama Lengkap", siswa.namaLengkap),
                _buildInfoRow("NISN", siswa.nisn ?? "-"),
                _buildInfoRow("Total Hafalan (Bulan Ini)", "${stats['monthly_pages'].toStringAsFixed(1)} Halaman"),
                _buildInfoRow("Rerata Nilai Akademik", stats['avg_score'].toStringAsFixed(1)),
              ],
            ),
          ),
          pw.SizedBox(height: 30),

          // TABEL RIWAYAT
          pw.Text("DETAIL REKAMAN MUTABAAH", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey900),
            cellHeight: 30,
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.center,
              2: pw.Alignment.centerLeft,
            },
            headers: ['Tanggal', 'Tipe', 'Capaian / Catatan'],
            data: records.map((r) {
              String capaian = "";
              if (r.tipeModul == 'HAFALAN') {
                capaian = "QS ${r.dataPayload['start_surah']}:${r.dataPayload['start_ayah']} - ${r.dataPayload['end_ayah']}";
              } else {
                capaian = "Nilai: ${r.dataPayload['nilai']}";
              }
              return [
                DateFormat('dd/MM/yy').format(r.createdAt),
                r.tipeModul,
                "$capaian\nNote: ${r.catatan ?? '-'}",
              ];
            }).toList(),
          ),

          pw.SizedBox(height: 40),
          // TANDA TANGAN
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Column(
                children: [
                  pw.Text("Dicetak pada: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}"),
                  pw.SizedBox(height: 60),
                  pw.Container(width: 150, decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide()))),
                  pw.Text("Guru / Musyrif"),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    // Langsung buka preview print/share
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 150, child: pw.Text(label, style: const pw.TextStyle(fontSize: 10))),
          pw.Text(": ", style: const pw.TextStyle(fontSize: 10)),
          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
        ],
      ),
    );
  }
}