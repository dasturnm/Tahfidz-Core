// Lokasi: lib/features/akademik/tasmi/screens/tasmi_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../kurikulum/models/kurikulum_model.dart';
import '../models/tasmi_model.dart';
import '../providers/tasmi_provider.dart';

// =============================================================================
// SCREEN: TasmiFormScreen
// Digunakan oleh Guru untuk menilai ujian Tasmi' Santri secara realtime
// =============================================================================

class TasmiFormScreen extends ConsumerStatefulWidget {
  final String siswaId;
  final String namaSiswa;
  final ModulModel modul;

  const TasmiFormScreen({
    super.key,
    required this.siswaId,
    required this.namaSiswa,
    required this.modul,
  });

  @override
  ConsumerState<TasmiFormScreen> createState() => _TasmiFormScreenState();
}

class _TasmiFormScreenState extends ConsumerState<TasmiFormScreen> {
  // ---------------------------------------------------------------------------
  // 1. STATE & COUNTERS (PINALTI & POINT-IN SYSTEM)
  // ---------------------------------------------------------------------------

  // Counter untuk aspek ITQON (Kelancaran)
  final Map<String, int> _itqonSTT = {'itqon': 0}; // Salah Tanpa Teguran
  final Map<String, int> _itqonT = {'itqon': 0};   // Teguran
  final Map<String, int> _itqonP = {'itqon': 0};   // Dipandu

  // Counter untuk aspek TEKNIS (Makhraj & Tajwid)
  final Map<String, int> _kurangCounts = {'makhraj': 0, 'tajwid': 0};
  final Map<String, int> _salahCounts = {'makhraj': 0, 'tajwid': 0};

  // State untuk aspek NON-TEKNIS (Point-In System)
  final Map<String, double> _pointInScores = {
    'adab': 0.0, 'nada': 0.0, 'penampilan': 0.0, 'tebak_surah': 0.0
  };

  // ---------------------------------------------------------------------------
  // 2. BUILD & CALCULATION LOGIC
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Ambil Konfigurasi Bobot dari Modul Kurikulum
    final int bItqon = widget.modul.bobotItqon;
    final int bMakhraj = widget.modul.bobotMakhraj;
    final int bTajwid = widget.modul.bobotTajwid;
    final int bAdab = widget.modul.bobotAdab;
    final int bNada = widget.modul.bobotNada;
    final int bPenampilan = widget.modul.bobotPenampilan;
    final int bTebakSurah = widget.modul.bobotTebakSurah;

    /// Fungsi Pembantu: Hitung Nilai Per Kategori
    /// Mendukung sistem Pinalti (Pengurangan dari 100) dan Point-In (Input Langsung)
    double getScore(String key) {
      final settings = widget.modul.tasmiSettings?[key] ?? {};

      // Jika tidak ada data pinalti di settings, gunakan sistem Point-In (Penambahan)
      if (!settings.containsKey('pinalti_stt') && !settings.containsKey('pinalti_kurang')) {
        return _pointInScores[key] ?? 0.0;
      }

      // Sistem Pinalti (Pengurangan)
      double score = 100.0;
      if (key == 'itqon') {
        score -= (_itqonSTT[key]! * (settings['pinalti_stt'] ?? 0.0).toDouble());
        score -= (_itqonT[key]! * (settings['pinalti_t'] ?? 0.0).toDouble());
        score -= (_itqonP[key]! * (settings['pinalti_p'] ?? 0.0).toDouble());
      } else {
        score -= (_kurangCounts[key]! * (settings['pinalti_kurang'] ?? 0.0).toDouble());
        score -= (_salahCounts[key]! * (settings['pinalti_salah'] ?? 0.0).toDouble());
      }
      return score < 0 ? 0 : score;
    }

    // Masukkan hasil kalkulasi ke TasmiScoreModel untuk divalidasi
    final tasmiScore = TasmiScoreModel(
      itqon: getScore('itqon'),
      makhraj: getScore('makhraj'),
      tajwid: getScore('tajwid'),
      adab: getScore('adab'),
      nada: getScore('nada'),
      penampilan: getScore('penampilan'),
      tebakSurah: getScore('tebak_surah'),
    );

    // Hitung Nilai Akhir menggunakan bobot dari Kurikulum
    double finalScore = tasmiScore.calculateFinalScore(
      bItqon: bItqon,
      bMakhraj: bMakhraj,
      bTajwid: bTajwid,
      bAdab: bAdab,
      bNada: bNada,
      bPenampilan: bPenampilan,
      bTebakSurah: bTebakSurah,
    );

    bool isLulus = finalScore >= widget.modul.kkm;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Form Ujian Tasmi'"),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showInstructionDialog,
            tooltip: "Instruksi Penilaian",
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStudentCard(),
            const SizedBox(height: 32),

            Text("PENILAIAN UJIAN",
                style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 20),

            // 1. ITQON SECTION (3-Tier Penalty)
            if (bItqon > 0) _buildItqonSection(getScore('itqon')),

            // 2. MAKHRAJ & TAJWID (2-Tier Penalty)
            if (bMakhraj > 0) _buildTechnicalSection("Makharijul Huruf", 'makhraj', getScore('makhraj')),
            if (bTajwid > 0) _buildTechnicalSection("Hukum Tajwid", 'tajwid', getScore('tajwid')),

            // 3. ADAB, NADA, DLL (Point-In System)
            if (bAdab > 0) _buildPointInSection("Fashahah & Adab", 'adab', bAdab),
            if (bNada > 0) _buildPointInSection("Lagam / Nada", 'nada', bNada),
            if (bPenampilan > 0) _buildPointInSection("Penampilan", 'penampilan', bPenampilan),
            if (bTebakSurah > 0) _buildPointInSection("Tebak Surah", 'tebak_surah', bTebakSurah),

            const SizedBox(height: 40),
            _buildResultCard(finalScore, isLulus),

            const SizedBox(height: 32),
            _buildActionButtons(isLulus, tasmiScore),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. UI COMPONENTS
  // ---------------------------------------------------------------------------

  void _showInstructionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Instruksi Penilaian Kelancaran"),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Salah Tanpa Teguran (STT):", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Text("Santri menyadari kesalahan bacaan sendiri dan memperbaikinya tanpa bantuan.", style: TextStyle(fontSize: 12)),
              SizedBox(height: 10),
              Text("Teguran (T):", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Text("Penguji memberikan kode/ketukan karena santri melakukan kesalahan yang tidak disadari.", style: TextStyle(fontSize: 12)),
              SizedBox(height: 10),
              Text("Dipandu (P):", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Text("Santri terhenti total atau melakukan kesalahan fatal sehingga harus dibacakan potongan ayat selanjutnya.", style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("MENGERTI"))],
      ),
    );
  }

  Widget _buildItqonSection(double currentScore) {
    return _buildSectionWrapper(
      label: "Tahfidz (Kelancaran)",
      currentScore: currentScore,
      child: Row(
        children: [
          _buildCounterButton('itqon', "STT", Colors.orange, _itqonSTT),
          const SizedBox(width: 8),
          _buildCounterButton('itqon', "Tegur", Colors.red, _itqonT),
          const SizedBox(width: 8),
          _buildCounterButton('itqon', "Pandu", Colors.purple, _itqonP),
        ],
      ),
    );
  }

  Widget _buildTechnicalSection(String label, String key, double currentScore) {
    return _buildSectionWrapper(
      label: label,
      currentScore: currentScore,
      child: Row(
        children: [
          _buildCounterButton(key, "Kurang", Colors.orange, _kurangCounts),
          const SizedBox(width: 12),
          _buildCounterButton(key, "Salah", Colors.red, _salahCounts),
        ],
      ),
    );
  }

  Widget _buildPointInSection(String label, String key, int maxWeight) {
    double currentVal = _pointInScores[key] ?? 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text("${currentVal.toInt()} / $maxWeight", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: currentVal,
            min: 0,
            max: maxWeight.toDouble(),
            divisions: maxWeight > 0 ? maxWeight : 1,
            activeColor: const Color(0xFF10B981),
            onChanged: (v) => setState(() => _pointInScores[key] = v),
          ),
          const Divider(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionWrapper({required String label, required double currentScore, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text("Skor: ${currentScore.toInt()}",
                  style: TextStyle(fontWeight: FontWeight.bold, color: currentScore < 70 ? Colors.red : const Color(0xFF10B981))),
            ],
          ),
          const SizedBox(height: 12),
          child,
          const Divider(height: 32),
        ],
      ),
    );
  }

  Widget _buildCounterButton(String key, String label, Color color, Map<String, int> map) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                Text("${map[key]}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            Row(
              children: [
                InkWell(
                  onTap: map[key]! > 0 ? () => setState(() => map[key] = map[key]! - 1) : null,
                  child: const Icon(Icons.remove_circle_outline, size: 20),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: () => setState(() => map[key] = map[key]! + 1),
                  child: Icon(Icons.add_circle, color: color, size: 20),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(double score, bool lulus) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: lulus ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: lulus ? const Color(0xFF10B981) : Colors.red, width: 2),
      ),
      child: Column(
        children: [
          const Text("NILAI AKHIR TASMI'", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(score.toStringAsFixed(1),
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: lulus ? const Color(0xFF065F46) : Colors.red[900])),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(lulus ? Icons.check_circle : Icons.error, color: lulus ? const Color(0xFF10B981) : Colors.red),
              const SizedBox(width: 8),
              Text(lulus ? "SANTRI DINYATAKAN LULUS" : "SANTRI PERLU REMEDIAL",
                  style: TextStyle(fontWeight: FontWeight.bold, color: lulus ? const Color(0xFF10B981) : Colors.red)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStudentCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey[200]!)),
      child: Row(
        children: [
          const CircleAvatar(radius: 25, backgroundColor: Color(0xFF10B981), child: Icon(Icons.person, color: Colors.white)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.namaSiswa, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("Modul: ${widget.modul.namaModul}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          Column(
            children: [
              const Text("KKM", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              Text("${widget.modul.kkm.toInt()}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isLulus, TasmiScoreModel finalSkor) {
    final tasmiState = ref.watch(tasmiNotifierProvider);

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton.icon(
            onPressed: tasmiState.isLoading
                ? null
                : () async {
              try {
                await ref.read(tasmiNotifierProvider.notifier).simpanHasilTasmi(
                  siswaId: widget.siswaId,
                  modul: widget.modul,
                  skor: finalSkor,
                );

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Hasil Tasmi' Berhasil Disimpan!"),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                  Navigator.pop(context);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
                  );
                }
              }
            },
            icon: tasmiState.isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.save_rounded, color: Colors.white),
            label: Text(tasmiState.isLoading ? "MENYIMPAN..." : "SIMPAN HASIL TASMI'",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        if (isLulus) ...[
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () { /* Logic Sertifikat */ },
            icon: const Icon(Icons.verified_user_rounded, color: Color(0xFF10B981)),
            label: const Text("PREVIEW SERTIFIKAT", style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
          ),
        ],
      ],
    );
  }
}