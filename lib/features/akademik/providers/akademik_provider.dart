// Lokasi: lib/features/akademik/providers/akademik_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../program/models/program_model.dart';
import '../services/akademik_service.dart';
import '../kurikulum/models/kurikulum_model.dart'; // Ambil LevelModel yang sudah disatukan
import 'package:tahfidz_core/core/providers/app_context_provider.dart';

class AkademikProvider extends ChangeNotifier {
  final AkademikService _akademikService = AkademikService();
  final Ref _ref; // PERBAIKAN: Tambahkan Ref untuk akses konteks

  AkademikProvider(this._ref); // PERBAIKAN: Constructor menerima Ref

  // State untuk menyimpan data
  List<ProgramModel> _program = []; // PERBAIKAN: Singular
  List<LevelModel> _level = [];

  bool _isLoading = false;
  String? _errorMessage;

  // Getter untuk UI
  List<ProgramModel> get program => _program; // PERBAIKAN: Singular
  List<LevelModel> get level => _level;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Mengambil data Program dan Level secara bersamaan
  Future<void> fetchMasterData() async {
    // 1. Ambil lembagaId dari context (Provider sebagai Otak)
    final lembagaId = _ref.read(appContextProvider).lembaga?.id;

    if (lembagaId == null) {
      debugPrint("Warning: fetchMasterData dipanggil tapi lembagaId null");
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 2. FIX: Gunakan currentCabang (sesuai AppContextState)
      final cabangId = _ref.read(appContextProvider).currentCabang?.id;

      // 3. Ambil data dari Service
      // Menggunakan Future.wait agar kedua data diambil dari Supabase secara paralel
      final results = await Future.wait([
        _akademikService.getProgram(lembagaId: lembagaId, cabangId: cabangId),
        _akademikService.getLevel(lembagaId: lembagaId),
      ]);

      // 4. Update state (Data sudah di-map ke model oleh Service, hindari mapping ulang agar tidak error)
      _program = results[0] as List<ProgramModel>;
      _level = results[1] as List<LevelModel>;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("Error fetchMasterData: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// Deklarasi Global Provider
// FIX: Teruskan 'ref' ke dalam constructor provider
final akademikProvider = ChangeNotifierProvider<AkademikProvider>((ref) => AkademikProvider(ref));