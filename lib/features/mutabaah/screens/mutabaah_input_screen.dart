// Lokasi: lib/features/mutabaah/screens/mutabaah_input_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../akademik/kurikulum/models/kurikulum_model.dart';
import '../../siswa/models/siswa_model.dart';
import '../models/mutabaah_model.dart';
import '../providers/mutabaah_provider.dart';
import '../services/mutabaah_service.dart';
import '../../mushaf/services/mushaf_calculator.dart';
import '../widgets/status_switch_button.dart';
import '../widgets/mutabaah_surah_ayah_picker.dart'; // FIX: Kembalikan import picker surah/ayah
import '../widgets/mutabaah_rating_picker.dart';     // FIX: Kembalikan import picker rating skala 1-4
import '../widgets/mutabaah_projection_board.dart';
import 'package:go_router/go_router.dart'; // TAMBAHAN: Untuk integrasi navigasi ke lembar ujian formal
import '../../akademik/evaluasi/services/evaluasi_service.dart'; // TAMBAHAN

part 'components/pilar_input_tahfidz.dart';
part 'components/pilar_input_internal.dart';
part 'components/pilar_input_akademik.dart';
part 'components/pengontrol_input_mutabaah.dart';

class MutabaahInputScreen extends ConsumerStatefulWidget {
  final SiswaModel siswa;
  final List<ModulModel> activeModuls;

  const MutabaahInputScreen({
    super.key,
    required this.siswa,
    required this.activeModuls,
  });

  @override
  ConsumerState<MutabaahInputScreen> createState() => _ModulInputScreenState();
}

class _ModulInputScreenState extends ConsumerState<MutabaahInputScreen> with TickerProviderStateMixin {
  final _supabase = Supabase.instance.client;
  TabController? _tabController;

  late SiswaModel _currentSiswa;

  final Map<String, TextEditingController> _catatanControllers = {};
  final Map<String, TextEditingController> _nilaiControllers = {};
  final Map<String, TextEditingController> _sabqiControllers = {};
  final Map<String, TextEditingController> _manzilControllers = {};
  final Map<String, TextEditingController> _halamanAwalControllers = {};
  final Map<String, TextEditingController> _halamanAkhirControllers = {};

  final Map<String, int?> _startSurah = {};
  final Map<String, int?> _startAyahs = {};
  final Map<String, int?> _endSurah = {};
  final Map<String, int?> _endAyahs = {};

  final Map<String, double> _pagesMap = {};
  final Map<String, double> _linesMap = {};
  final Map<String, double> _ayahsMap = {};
  final Map<String, double> _surahsMap = {};
  final Map<String, double> _juzsMap = {};
  final Map<String, double> _pagesUniqueMap = {};
  final Map<String, bool> _targetsMetMap = {};
  final Map<String, bool> _loadingMap = {};

  final Map<String, double> _debtsMap = {};
  final Map<String, double> _totalTargetsMap = {};

  final Map<String, String?> _selectedMateri = {};
  final Map<String, int> _switchStates = {};
  final Map<String, int?> _pertemuanSebelumnyaMap = {};
  final Map<String, String?> _materiSebelumnyaMap = {};
  final Map<String, bool> _modulCompleted = {};

  List<Map<String, dynamic>> _surahList = [];
  bool _isInitialLoading = true;

  final Map<String, int> _penaltyCounts = {
    'itqon_s': 0, 'itqon_t': 0, 'itqon_p': 0,
    'tailwind_k': 0, 'tajwid_s': 0,
    'makhraj_k': 0, 'makhraj_s': 0,
  };
  final Map<String, double> _directScores = {};

  @override
  void initState() {
    super.initState();
    _currentSiswa = widget.siswa;
    _tabController = TabController(length: widget.activeModuls.length, vsync: this);
    _tabController?.addListener(() => setState(() {}));
    _fetchSurah();

    for (var modul in widget.activeModuls) {
      final mId = modul.id!;
      _catatanControllers[mId] = TextEditingController();
      _nilaiControllers[mId] = TextEditingController();
      _sabqiControllers[mId] = TextEditingController();
      _manzilControllers[mId] = TextEditingController();
      _halamanAwalControllers[mId] = TextEditingController();
      _halamanAkhirControllers[mId] = TextEditingController();

      _switchStates[mId] = 0;
      _targetsMetMap[mId] = true;
      _loadingMap[mId] = false;

      final String tipeModul = modul.tipe.trim().toUpperCase();
      if (['ZIYADAH HAFALAN', 'ZIYADAH TILAWAH', 'MUROJAAH', 'HAFALAN', 'TILAWAH', 'TASMI\''].contains(tipeModul)) {
        _loadModulSpecificData(modul);
      }

      if (tipeModul == 'TASMI\'') {
        final settings = modul.tasmiSettings ?? {};
        settings.forEach((key, val) {
          if (val['active'] == true && (key == 'nada' || key == 'adab' || val['is_custom'] == true)) {
            _directScores[key] = 80.0;
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    for (var c in _catatanControllers.values) { c.dispose(); }
    for (var c in _nilaiControllers.values) { c.dispose(); }
    for (var c in _sabqiControllers.values) { c.dispose(); }
    for (var c in _manzilControllers.values) { c.dispose(); }
    for (var c in _halamanAwalControllers.values) { c.dispose(); }
    for (var c in _halamanAkhirControllers.values) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final submitState = ref.watch(mutabaahProvider);
    const Color emerald = Color(0xFF10B981);
    const Color slate = Color(0xFF1E293B);

    bool hasSubmittableModul = widget.activeModuls.any((m) {
      return !(m.isExamRequired && _currentSiswa.isReadyForExam && _currentSiswa.readyModulId == m.id!);
    });

    final ModulModel? currentModul = widget.activeModuls.isNotEmpty
        ? widget.activeModuls[_tabController?.index ?? 0]
        : null;

    bool isAllSwitchesReady = currentModul != null &&
        hasSubmittableModul &&
        (() {
          final isExamReady = currentModul.isExamRequired && _currentSiswa.isReadyForExam && _currentSiswa.readyModulId == currentModul.id!;
          return isExamReady || _switchStates[currentModul.id!] != 0;
        })();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(_currentSiswa.namaLengkap, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: slate,
        bottom: widget.activeModuls.length > 1
            ? TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: emerald,
          unselectedLabelColor: Colors.grey,
          indicatorColor: emerald,
          tabs: widget.activeModuls.map((m) => Tab(text: m.namaModul)).toList(),
        )
            : null,
      ),
      body: TabBarView(
        controller: _tabController,
        children: widget.activeModuls.map((modul) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: _buildModulSection(modul, emerald),
          );
        }).toList(),
      ),
      bottomNavigationBar: hasSubmittableModul ? Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]
        ),
        child: SizedBox(
          width: double.infinity,
          height: 65,
          child: ElevatedButton(
            onPressed: (!submitState.isLoading && isAllSwitchesReady) ? _submitDataBatch : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isAllSwitchesReady ? emerald : Colors.grey.shade400,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: isAllSwitchesReady ? 8 : 0,
              shadowColor: emerald.withOpacity(0.3),
            ),
            child: submitState.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(isAllSwitchesReady ? "SIMPAN LAPORAN" : "TENTUKAN STATUS (ULANG/LANJUT)",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
          ),
        ),
      ) : null,
    );
  }

  Widget _buildModulSection(ModulModel modul, Color color) {
    final mId = modul.id!;
    final String tipe = modul.tipe.trim().toUpperCase();
    final isQuranic = !['INTERNAL', 'AKADEMIK'].contains(tipe) &&
        ['ZIYADAH HAFALAN', 'ZIYADAH TILAWAH', 'MUROJAAH', 'HAFALAN', 'TILAWAH', 'TASMI\''].contains(tipe);
    final bool isPreviousUlang = _catatanControllers['${mId}_is_ulang_prev']?.text == 'true';

    if (_modulCompleted[mId] == true) {
      return _buildCompletedModule(modul, color);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(modul.tipe, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 10)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(modul.namaModul, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E293B)))),
            ],
          ),
          const Divider(height: 32),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (modul.isStrict) _badgeInfo("🚫 Strict Mode", Colors.red),
              if (modul.isAccumulated) _badgeInfo("⚠️ Akumulasi", Colors.orange),
              _badgeInfo("📌 KKM: ${modul.kkm}", Colors.blue),
              _badgeInfo("🎯 Target: ${modul.targetAmount} ${modul.targetAmountUnit}", color),
            ],
          ),
          const SizedBox(height: 24),
          if (isPreviousUlang) ...[
            Row(
              children: [
                const Icon(Icons.history, size: 14, color: Color(0xFFF57C00)),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    "Materi ini sedang diulang dari pertemuan sebelumnya.",
                    style: TextStyle(color: Color(0xFFE65100), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          if (modul.isExamRequired && _currentSiswa.isReadyForExam && _currentSiswa.readyModulId == mId) ...[
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: _currentSiswa.academicState == 'tasmi_mode'
                    ? const Color(0xFFF59E0B).withValues(alpha: 0.08)
                    : const Color(0xFF3B82F6).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _currentSiswa.academicState == 'tasmi_mode'
                      ? const Color(0xFFF59E0B).withValues(alpha: 0.2)
                      : const Color(0xFF3B82F6).withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _currentSiswa.academicState == 'tasmi_mode' ? Icons.lock_clock : Icons.stars_rounded,
                        color: _currentSiswa.academicState == 'tasmi_mode' ? const Color(0xFFF59E0B) : const Color(0xFF3B82F6),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _currentSiswa.academicState == 'tasmi_mode' ? "WAJIB TASMI' KELANCARAN" : "STATUS KELAYAKAN UJIAN",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: _currentSiswa.academicState == 'tasmi_mode' ? const Color(0xFFD97706) : const Color(0xFF3B82F6),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _currentSiswa.academicState == 'tasmi_mode'
                        ? "Santri telah menuntaskan target kuantitas materi harian. Input setoran harian dikunci sementara karena santri diwajibkan menempuh Ujian Tasmi' Kelancaran Sekali Duduk tanpa jeda hari terlebih dahulu."
                        : "Alhamdulillah, capaian materi pada modul ini telah tuntas. Silakan koordinasikan jadwal dengan Tim Penguji untuk pelaksanaan Ujian Tasmi' / UKL santri.",
                    style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade900, height: 1.5, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        if (_currentSiswa.academicState == 'tasmi_mode') {
                          await EvaluasiService().completeTasmiVolume(_currentSiswa.id!);
                          final updatedData = await _supabase.from('siswa').select().eq('id', _currentSiswa.id!).single();
                          if (mounted) {
                            setState(() {
                              _currentSiswa = SiswaModel.fromJson(updatedData);
                            });
                          }
                        } else {
                          context.push(
                            '/akademik/tasmi',
                            extra: {
                              'siswaId': _currentSiswa.id,
                              'namaSiswa': _currentSiswa.namaLengkap,
                              'modul': modul,
                              'tipeEvaluasi': modul.examType,
                            },
                          );
                        }
                      },
                      icon: Icon(
                        Icons.assignment_turned_in_rounded,
                        size: 16,
                        color: _currentSiswa.academicState == 'tasmi_mode' ? const Color(0xFFD97706) : const Color(0xFF3B82F6),
                      ),
                      label: Text(
                        _currentSiswa.academicState == 'tasmi_mode' ? "Validasi Kelancaran Tuntas → Buka Lembar Skor" : "Mulai Ujian Langsung (Otoritas Mandiri)",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: _currentSiswa.academicState == 'tasmi_mode' ? const Color(0xFFD97706) : const Color(0xFF3B82F6),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: _currentSiswa.academicState == 'tasmi_mode' ? const Color(0xFFF59E0B) : const Color(0xFF3B82F6),
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            if (modul.silabusSource == 'internal' || tipe == 'INTERNAL') ...[
              _buildInternalForm(modul, color),
            ] else if (isQuranic) ...[
              _buildTahfidzForm(modul, color),
            ] else ...[
              _buildAkademikForm(modul, color),
            ],
            const SizedBox(height: 24),
            const Text("CATATAN KHUSUS MODUL INI", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.grey)),
            const SizedBox(height: 8),
            TextField(
              controller: _catatanControllers[mId],
              maxLines: 2,
              decoration: InputDecoration(
                hintText: "Evaluasi detail...", filled: true, fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            const Text("KEPUTUSAN KEDISPLINAN (WAJIB)", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.red)),
            const SizedBox(height: 8),
            StatusSwitchButton(
              value: _switchStates[mId] ?? 0,
              onChanged: (val) {
                setState(() {
                  _switchStates[mId] = val;
                  if (modul.useRatingScale) {
                    if (val == -1) _nilaiControllers[mId]!.text = '1';
                    if (val == 1 && (int.tryParse(_nilaiControllers[mId]!.text) ?? 0) <= 1) _nilaiControllers[mId]!.text = '3';
                  }
                });
              },
            ),
            const SizedBox(height: 24),
            MutabaahProjectionBoard(siswaId: _currentSiswa.id!, modul: modul),
          ],
        ],
      ),
    );
  }

  Widget _buildCompletedModule(ModulModel modul, Color color) {
    final bool isExamRequired = modul.isExamRequired;
    final bool isReady = _currentSiswa.isReadyForExam && _currentSiswa.readyModulId == modul.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text("✓ MODUL SELESAI", style: TextStyle(color: Colors.green, fontWeight: FontWeight.w900, fontSize: 10)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(modul.namaModul, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E293B)))),
            ],
          ),
          const Divider(height: 32),
          const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 48),
          const SizedBox(height: 12),
          const Text(
            "Alhamdulillah, seluruh materi pada modul ini telah tuntas.",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
          ),
          if (isExamRequired && !isReady) ...[
            const SizedBox(height: 8),
            const Text(
              "Modul ini mewajibkan Ujian (UKL/Tasmi'). Silakan koordinasikan dengan Tim Penguji untuk pelaksanaan ujian.",
              style: TextStyle(fontSize: 12, color: Color(0xFF546E7A), height: 1.4),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  context.push(
                    '/akademik/tasmi',
                    extra: {
                      'siswaId': _currentSiswa.id,
                      'namaSiswa': _currentSiswa.namaLengkap,
                      'modul': modul,
                      'tipeEvaluasi': modul.examType,
                    },
                  );
                },
                icon: const Icon(Icons.assignment_turned_in_rounded, size: 16, color: Color(0xFF3B82F6)),
                label: const Text("BUKA LEMBAR UJIAN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF3B82F6))),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF3B82F6)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
          if (isExamRequired && isReady) ...[
            const SizedBox(height: 8),
            const Text(
              "Siswa sudah siap ujian. Silakan lanjutkan ke proses ujian.",
              style: TextStyle(fontSize: 12, color: Color(0xFF546E7A), height: 1.4),
            ),
          ],
          if (!isExamRequired) ...[
            const SizedBox(height: 8),
            const Text(
              "Siswa akan otomatis naik ke modul berikutnya setelah semua modul di level ini tuntas.",
              style: TextStyle(fontSize: 12, color: Color(0xFF546E7A), height: 1.4),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _infoBox(String text, Color color) => Container(padding: const EdgeInsets.all(8), margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(8)), child: Row(children: [Icon(Icons.info_outline, size: 14, color: color), const SizedBox(width: 8), Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold))]));

  Widget _pilarInput({required String label, required TextEditingController controller, required String hint}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)), const SizedBox(height: 6), TextField(controller: controller, keyboardType: TextInputType.number, decoration: InputDecoration(hintText: hint, filled: true, fillColor: const Color(0xFFF8FAFC), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)))]);

  Widget _summaryItemMutabaah(String label, String value, Color color, bool isBelow) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isBelow ? Colors.orange : color)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _badgeInfo(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }

  // ignore: unused_element
  Widget _penaltyRow(String title, List<String> keys, List<String> labels) => Row(children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), const SizedBox(width: 12), ...List.generate(keys.length, (i) => Padding(padding: const EdgeInsets.only(right: 8), child: ActionChip(label: Text("${labels[i]} ${_penaltyCounts[keys[i]]}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red)), onPressed: () => setState(() => _penaltyCounts[keys[i]] = (_penaltyCounts[keys[i]] ?? 0) + 1))))]);

  // ignore: unused_element
  Widget _buildPolicySection(ModulModel m) {
    return const SizedBox.shrink();
  }
}