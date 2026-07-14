// Lokasi: lib/features/akademik/evaluasi/screens/form_evaluasi_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../kurikulum/models/kurikulum_model.dart';
import '../providers/evaluasi_controller.dart';

// =============================================================================
// SCREEN: FormEvaluasiScreen
// Guru dapat menilai ujian formal (Tasmi' / UKL) secara realtime
// =============================================================================

class FormEvaluasiScreen extends ConsumerStatefulWidget {
  final String siswaId;
  final String namaSiswa;
  final ModulModel modul;
  final String tipeEvaluasi; // 'TASMI' atau 'UKL'

  const FormEvaluasiScreen({
    super.key,
    required this.siswaId,
    required this.namaSiswa,
    required this.modul,
    this.tipeEvaluasi = 'TASMI', // Default ke TASMI
  });

  @override
  ConsumerState<FormEvaluasiScreen> createState() => _FormEvaluasiScreenState();
}

class _FormEvaluasiScreenState extends ConsumerState<FormEvaluasiScreen> {
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

  final TextEditingController _catatanController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Poin 5: Lakukan Fetching data hasil ujian lama dari database pasca-inisialisasi layar
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final dataLama = await ref.read(evaluasiControllerProvider.notifier).fetchSavedEvaluasi(
          siswaId: widget.siswaId,
          modulId: widget.modul.id!,
        );
        if (dataLama != null && dataLama['detail_penilaian'] != null && mounted) {
          final detail = dataLama['detail_penilaian'] as Map<String, dynamic>;
          setState(() {
            _itqonSTT['itqon'] = (detail['itqon_stt'] as num?)?.toInt() ?? 0;
            _itqonT['itqon'] = (detail['itqon_t'] as num?)?.toInt() ?? 0;
            _itqonP['itqon'] = (detail['itqon_p'] as num?)?.toInt() ?? 0;
            _kurangCounts['makhraj'] = (detail['makhraj_kurang'] as num?)?.toInt() ?? 0;
            _salahCounts['makhraj'] = (detail['makhraj_salah'] as num?)?.toInt() ?? 0;
            _kurangCounts['tajwid'] = (detail['tajwid_kurang'] as num?)?.toInt() ?? 0;
            _salahCounts['tajwid'] = (detail['tajwid_salah'] as num?)?.toInt() ?? 0;
            _pointInScores['adab'] = (detail['skor_adab'] as num?)?.toDouble() ?? 0.0;
            _pointInScores['nada'] = (detail['skor_nada'] as num?)?.toDouble() ?? 0.0;
            _pointInScores['penampilan'] = (detail['skor_penampilan'] as num?)?.toDouble() ?? 0.0;
            _pointInScores['tebak_surah'] = (detail['skor_tebak_surah'] as num?)?.toDouble() ?? 0.0;
            _catatanController.text = dataLama['catatan']?.toString() ?? '';
          });
        }
      } catch (e) {
        debugPrint("Belum ada data evaluasi tersimpan sebelumnya: $e");
      }
    });
  }

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // 2. BUILD & CALCULATION LOGIC
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Pantau status dari controller (loading/error/data)
    final evaluasiState = ref.watch(evaluasiControllerProvider);
    final isLoading = evaluasiState.isLoading;

    // Ambil Konfigurasi Bobot dari Modul Kurikulum via tasmiSettings
    final Map<String, dynamic> settings = widget.modul.sertifikasiSettings ?? {};
    double getBobot(String key) => (settings[key]?['bobot'] as num?)?.toDouble() ?? 0.0;

    final double bItqon = getBobot('itqon');
    final double bMakhraj = getBobot('makhraj');
    final double bTajwid = getBobot('tajwid');
    final double bAdab = getBobot('adab');
    final double bNada = getBobot('nada');
    final double bPenampilan = getBobot('penampilan');
    final double bTebakSurah = getBobot('tebak_surah');

    /// Fungsi Pembantu: Hitung Nilai Per Kategori
    double getScore(String key) {
      final settings = widget.modul.sertifikasiSettings?[key] ?? {};

      // Jika tidak ada data pinalti di settings, gunakan sistem Point-In
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

    /// Kalkulasi Nilai Akhir (Weighted Average)
    double calculateFinalScore() {
      double totalScore = 0.0;
      double totalWeight = (bItqon + bMakhraj + bTajwid + bAdab + bNada + bPenampilan + bTebakSurah).toDouble();

      if (totalWeight <= 0) return 100.0; // Fail safe jika tidak ada bobot diatur

      totalScore += (getScore('itqon') * bItqon);
      totalScore += (getScore('makhraj') * bMakhraj);
      totalScore += (getScore('tajwid') * bTajwid);
      totalScore += (getScore('adab') * bAdab);
      totalScore += (getScore('nada') * bNada);
      totalScore += (getScore('penampilan') * bPenampilan);
      totalScore += (getScore('tebak_surah') * bTebakSurah);

      return totalScore / totalWeight;
    }

    double finalScore = calculateFinalScore();
    bool isLulus = finalScore >= widget.modul.kkm;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Form Ujian ${widget.tipeEvaluasi}"),
        backgroundColor: const Color(0xFF3B82F6), // Mengikuti AGENTS.md: Biru untuk Akademik
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
            if (bAdab > 0) _buildPointInSection("Fashahah & Adab", 'adab', bAdab.toInt()),
            if (bNada > 0) _buildPointInSection("Lagam / Nada", 'nada', bNada.toInt()),
            if (bPenampilan > 0) _buildPointInSection("Penampilan", 'penampilan', bPenampilan.toInt()),
            if (bTebakSurah > 0) _buildPointInSection("Tebak Surah", 'tebak_surah', bTebakSurah.toInt()),

            const SizedBox(height: 16),
            _buildCatatanField(),

            const SizedBox(height: 40),
            _buildResultCard(finalScore, isLulus),

            const SizedBox(height: 32),
            _buildActionButtons(isLulus, finalScore, isLoading),
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
              Text("Santri terhenti total atau melakukan kesalahan fatal sehingga harus dibacakan potongan ayah selanjutnya.", style: TextStyle(fontSize: 12)),
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
              Text("${currentVal.toInt()} / $maxWeight", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3B82F6))),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: currentVal,
            min: 0,
            max: maxWeight.toDouble(),
            divisions: maxWeight > 0 ? maxWeight : 1,
            activeColor: const Color(0xFF3B82F6),
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
                  style: TextStyle(fontWeight: FontWeight.bold, color: currentScore < 70 ? Colors.red : const Color(0xFF3B82F6))),
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

  Widget _buildCatatanField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Catatan Penguji (Opsional)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),
        TextField(
          controller: _catatanController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: "Tuliskan masukan atau evaluasi khusus di sini...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
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
          Text("NILAI AKHIR ${widget.tipeEvaluasi}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
          const CircleAvatar(radius: 25, backgroundColor: Color(0xFF3B82F6), child: Icon(Icons.person, color: Colors.white)),
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

  Widget _buildActionButtons(bool isLulus, double finalScore, bool isLoading) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton.icon(
            onPressed: isLoading
                ? null
                : () async {
              try {
                // Bungkus rincian penilain (detailPenilaian) ke dalam Map
                final Map<String, dynamic> rincian = {
                  'itqon_stt': _itqonSTT['itqon'],
                  'itqon_t': _itqonT['itqon'],
                  'itqon_p': _itqonP['itqon'],
                  'makhraj_kurang': _kurangCounts['makhraj'],
                  'makhraj_salah': _salahCounts['makhraj'],
                  'tajwid_kurang': _kurangCounts['tajwid'],
                  'tajwid_salah': _salahCounts['tajwid'],
                  'skor_adab': _pointInScores['adab'],
                  'skor_nada': _pointInScores['nada'],
                  'skor_penampilan': _pointInScores['penampilan'],
                  'skor_tebak_surah': _pointInScores['tebak_surah'],
                };

                // Panggil method submit di provider
                await ref.read(evaluasiControllerProvider.notifier).submitEvaluasi(
                  siswaId: widget.siswaId,
                  modulId: widget.modul.id!,
                  tipeEvaluasi: widget.tipeEvaluasi,
                  nilaiAkhir: finalScore,
                  isLulus: isLulus,
                  detailPenilaian: rincian,
                  catatan: _catatanController.text,
                );

                // ASYNC SAFETY (Wajib di Flutter / Riverpod)
                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Hasil Ujian Berhasil Disimpan!"),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );

                // Tutup form setelah berhasil simpan
                Navigator.pop(context);

              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
                );
              }
            },
            icon: isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.save_rounded, color: Colors.white),
            label: Text(isLoading ? "MENYIMPAN..." : "SIMPAN HASIL UJIAN",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        if (isLulus) ...[
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () {
              // TODO: Navigasi ke halaman E-Sertifikat
            },
            icon: const Icon(Icons.verified_user_rounded, color: Color(0xFF3B82F6)),
            label: const Text("PREVIEW SERTIFIKAT", style: TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold)),
          ),
        ],
      ],
    );
  }
}