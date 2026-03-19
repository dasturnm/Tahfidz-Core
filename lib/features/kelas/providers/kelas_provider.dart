// Lokasi: lib/features/kelas/providers/kelas_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../management_lembaga/providers/app_context_provider.dart'; // Import context
import '../models/kelas_model.dart';
import '../services/kelas_service.dart';

class KelasProvider extends ChangeNotifier {
  final KelasService _kelasService = KelasService();
  final Ref _ref; // PERBAIKAN: Tambahkan Ref untuk akses konteks

  KelasProvider(this._ref); // PERBAIKAN: Constructor menerima Ref

  // State (Kondisi) dari Provider ini
  List<KelasModel> _kelas = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  // Getter agar UI bisa membaca data ini dengan mudah
  List<KelasModel> get kelas {
    if (_searchQuery.isEmpty) return _kelas;
    final query = _searchQuery.toLowerCase();
    return _kelas.where((k) =>
    k.name.toLowerCase().contains(query) ||
        (k.waliKelas?.namaLengkap ?? '').toLowerCase().contains(query)
    ).toList();
  }
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Mengambil daftar kelas saat aplikasi atau layar dibuka
  Future<void> fetchKelas() async {
    // FIX: Dapatkan lembagaId dari appContextProvider secara otomatis
    final appContext = _ref.read(appContextProvider);
    final lembagaId = appContext.lembaga?.id;

    if (lembagaId == null) {
      debugPrint("Warning: fetchKelas dipanggil tapi lembagaId null");
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Memberitahu UI untuk menampilkan loading spinner

    try {
      // FIX: Memanggil service dengan filter lembagaId agar data muncul
      _kelas = await _kelasService.getKelas(lembagaId: lembagaId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners(); // Memberitahu UI untuk menghilangkan loading dan menampilkan data
    }
  }

  // Menambahkan kelas baru dan langsung merefresh daftar
  Future<bool> addKelas(KelasModel newKelas) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Injeksi lembaga_id & cabang_id dari konteks saat ini
      final appContext = _ref.read(appContextProvider);

      // Sekarang copyWith sudah mengenali lembagaId dan cabangId
      final validatedKelas = newKelas.copyWith(
        lembagaId: appContext.lembaga?.id,
        cabangId: appContext.currentCabang?.id,
      );

      await _kelasService.addKelas(validatedKelas);
      await fetchKelas(); // Refresh data otomatis setelah berhasil tambah
      return true; // Berhasil
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false; // Gagal
    }
  }

  // Memperbarui kelas (misal: ganti wali kelas)
  Future<bool> updateKelas(KelasModel updatedKelas) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _kelasService.updateKelas(updatedKelas);
      await fetchKelas(); // Refresh data
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Menghapus kelas
  Future<bool> deleteKelas(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _kelasService.deleteKelas(id);
      await fetchKelas(); // Refresh data setelah dihapus
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Fungsi untuk pencarian lokal
  void searchKelas(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}

// Deklarasi Global Provider
// PERBAIKAN: Menggunakan ref untuk inisialisasi KelasProvider
final kelasProvider = ChangeNotifierProvider<KelasProvider>((ref) => KelasProvider(ref));