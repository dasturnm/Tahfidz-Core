// Lokasi: lib/features/akademik/providers/akademik_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../program/models/program_model.dart';
import '../services/akademik_service.dart'; // Import service beserta LevelModel-nya

class AkademikProvider extends ChangeNotifier {
  final AkademikService _akademikService = AkademikService();

  // State untuk menyimpan data
  List<ProgramModel> _programs = [];
  List<LevelModel> _levels = [];

  bool _isLoading = false;
  String? _errorMessage;

  // Getter untuk UI
  List<ProgramModel> get programs => _programs;
  List<LevelModel> get levels => _levels;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Mengambil data Program dan Level secara bersamaan
  Future<void> fetchMasterData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Menggunakan Future.wait agar kedua data diambil dari Supabase secara paralel (lebih cepat!)
      final results = await Future.wait([
        _akademikService.getPrograms(),
        _akademikService.getLevels(),
      ]);

      _programs = results[0] as List<ProgramModel>;
      _levels = results[1] as List<LevelModel>;
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