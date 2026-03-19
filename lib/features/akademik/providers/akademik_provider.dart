// Lokasi: lib/features/akademik/providers/akademik_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../program/models/program_model.dart';
import '../services/akademik_service.dart';
import '../kurikulum/models/kurikulum_model.dart'; // Ambil LevelModel yang sudah disatukan

class AkademikProvider extends ChangeNotifier {
  final AkademikService _akademikService = AkademikService();

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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Menggunakan Future.wait agar kedua data diambil dari Supabase secara paralel
      final results = await Future.wait([
        _akademikService.getProgram(), // PERBAIKAN: Singular
        _akademikService.getLevel(),   // PERBAIKAN: camelCase & Singular
      ]);

      _program = results[0] as List<ProgramModel>; // PERBAIKAN: Singular
      _level = results[1] as List<LevelModel>;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// Deklarasi Global Provider
final akademikProvider = ChangeNotifierProvider<AkademikProvider>((ref) => AkademikProvider());