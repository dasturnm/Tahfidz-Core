// Lokasi: lib/features/akademik/tasmi/screens/tasmi_certificate_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TasmiCertificateScreen extends StatelessWidget {
  final Map<String, dynamic> recordData; // Diambil dari data_payload mutabaah_records

  const TasmiCertificateScreen({super.key, required this.recordData});

  @override
  Widget build(BuildContext context) {
    final detail = recordData['skor_detail'] ?? {};
    final double nilaiAkhir = recordData['nilai_akhir'] ?? 0.0;
    final String nomorSertifikat = recordData['nomor_sertifikat'] ?? '-';
    final DateTime tanggal = DateTime.parse(recordData['tanggal_ujian']);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("Sertifikat Tasmi'"),
        backgroundColor: const Color(0xFF10B981),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () { /* TODO: Implementasi PDF */ },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: AspectRatio(
              aspectRatio: 3 / 4, // Proporsi kertas A4 potret
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: 5)],
                  border: Border.all(color: const Color(0xFF10B981), width: 15), // Bingkai Utama
                ),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.amber[700]!, width: 2), // Garis Emas Dalam
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      // Header
                      Icon(Icons.verified_user_rounded, size: 60, color: Colors.amber[700]),
                      const SizedBox(height: 10),
                      Text("SERTIFIKAT TASMI'",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amber[900], letterSpacing: 2)),
                      Text("Nomor: $nomorSertifikat", style: const TextStyle(fontSize: 10)),

                      const Spacer(),

                      const Text("Diberikan Kepada:", style: TextStyle(fontStyle: FontStyle.italic)),
                      const SizedBox(height: 10),
                      const Text("NAMA SANTRI TESTER", // Nanti ambil dari profile_id
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),

                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          "Telah berhasil menyelesaikan Ujian Tasmi' pada unit modul ${recordData['nama_modul']} dengan hasil sebagai berikut:",
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Tabel Nilai
                      _buildScoreRow("Kelancaran (Itqon)", detail['itqon']),
                      _buildScoreRow("Makhraj Al-Huruf", detail['makhraj']),
                      _buildScoreRow("Hukum Tajwid", detail['tajwid']),
                      _buildScoreRow("Adab & Tartil", detail['adab']),

                      const Divider(indent: 60, endIndent: 60),

                      // Nilai Akhir
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("NILAI AKHIR: ", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(nilaiAkhir.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                        ],
                      ),

                      const Spacer(),

                      // Tanda Tangan
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSignBox("Penguji", "Nama Guru"),
                            _buildSignBox("Kepala Lembaga", "Nama Mudir"),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),
                      Text(DateFormat('dd MMMM yyyy', 'id_ID').format(tanggal), style: const TextStyle(fontSize: 10)),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreRow(String label, dynamic score) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          Text(score.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSignBox(String jabatan, String nama) {
    return Column(
      children: [
        Text(jabatan, style: const TextStyle(fontSize: 10)),
        const SizedBox(height: 40),
        Text(nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        Container(height: 1, width: 100, color: Colors.black),
      ],
    );
  }
}