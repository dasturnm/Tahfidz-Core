// Lokasi: lib/features/siswa/providers/siswa_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_context_provider.dart'; // Import context
import '../models/siswa_model.dart';
import '../services/siswa_service.dart';

class SiswaProvider extends ChangeNotifier {
  final SiswaService _siswaervice = SiswaService();
  final Ref _ref; // PERBAIKAN: Tambahkan Ref untuk akses konteks

  SiswaProvider(this._ref); // PERBAIKAN: Constructor menerima Ref

  // State
  List<SiswaModel> _siswa = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  // Getter
  List<SiswaModel> get siswa {
    if (_searchQuery.isEmpty) return _siswa;
    final query = _searchQuery.toLowerCase();
    return _siswa.where((s) =>
    s.namaLengkap.toLowerCase().contains(query) ||
        (s.nisn ?? '').toLowerCase().contains(query)
    ).toList();
  }
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 1. MENGAMBIL DATA SISWA (Berdasarkan Lembaga)
  Future<void> fetchSiswa() async {
    // FIX: Dapatkan lembagaId dari appContextProvider secara otomatis
    final appContext = _ref.read(appContextProvider);
    final lembagaId = appContext.lembaga?.id;

    if (lembagaId == null) {
      debugPrint("Warning: fetchSiswa dipanggil tapi lembagaId null");
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // FIX: Memanggil service dengan filter lembagaId agar data muncul
      _siswa = await _siswaervice.getSiswa(lembagaId: lembagaId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. MENAMBAHKAN SISWA
  Future<bool> addSiswa(SiswaModel newSiswa) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Injeksi lembaga_id & cabang_id dari konteks saat ini
      final appContext = _ref.read(appContextProvider);
      final validatedSiswa = newSiswa.copyWith(
        lembagaId: appContext.lembaga?.id,
        cabangId: appContext.currentCabang?.id,
      );

      await _siswaervice.addSiswa(validatedSiswa);
      await fetchSiswa(); // Refresh data otomatis
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 3. MEMPERBARUI DATA SISWA
  Future<bool> updateSiswa(SiswaModel updatedSiswa) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _siswaervice.updateSiswa(updatedSiswa);
      await fetchSiswa(); // Refresh data
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 4. MENGHAPUS SISWA
  Future<bool> deleteSiswa(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _siswaervice.deleteSiswa(id);
      await fetchSiswa(); // Refresh data
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 5. FITUR PLOTTING: Memasukkan/mengeluarkan siswa dari kelas
  Future<bool> assignSiswaToKelas(String siswaId, String? kelasId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _siswaervice.assignSiswaToKelas(siswaId, kelasId);
      await fetchSiswa(); // Refresh data setelah plotting
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 6. BULK IMPORT: Menambahkan banyak siswa sekaligus (CSV)
  Future<bool> bulkImportSiswa(List<SiswaModel> siswa) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _siswaervice.bulkAddSiswa(siswa);
      await fetchSiswa(); // Refresh data otomatis
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 7. BULK PLOTTING: Memasukkan banyak siswa ke dalam satu kelas sekaligus
  Future<bool> bulkAssignToKelas(List<String> siswaIds, String? kelasId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _siswaervice.bulkAssignSiswaToKelas(siswaIds, kelasId);
      await fetchSiswa(); // Refresh data setelah plotting masal
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Opsional: Filter lokal (hanya di memori) untuk mempermudah UI
  // Mengambil siswa yang belum punya kelas (Unassigned)
  List<SiswaModel> get unassignedSiswa {
    return _siswa.where((s) => s.kelasId == null).toList();
  }

  // Opsional: Filter lokal untuk mengambil siswa di kelas tertentu
  List<SiswaModel> getSiswaInKelas(String kelasId) {
    return _siswa.where((s) => s.kelasId == kelasId).toList();
  }

  // 8. PENCARIAN SISWA
  void searchSiswa(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}

// Deklarasi Global Provider
// PERBAIKAN: Menggunakan ref untuk inisialisasi SiswaProvider
final siswaProvider = ChangeNotifierProvider<SiswaProvider>((ref) => SiswaProvider(ref));