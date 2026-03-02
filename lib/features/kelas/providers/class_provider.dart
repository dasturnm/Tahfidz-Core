// Lokasi: lib/features/kelas/providers/class_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/kelas_model.dart';
import '../services/class_service.dart';

class ClassProvider extends ChangeNotifier {
  final ClassService _classService = ClassService();

  // State (Kondisi) dari Provider ini
  List<KelasModel> _classes = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  // Getter agar UI bisa membaca data ini dengan mudah
  List<KelasModel> get classes {
    if (_searchQuery.isEmpty) return _classes;
    final query = _searchQuery.toLowerCase();
    return _classes.where((k) =>
    k.name.toLowerCase().contains(query) ||
        (k.waliKelas?.namaLengkap ?? '').toLowerCase().contains(query)
    ).toList();
  }
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Mengambil daftar kelas saat aplikasi atau layar dibuka
  Future<void> fetchClasses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Memberitahu UI untuk menampilkan loading spinner

    try {
      _classes = await _classService.getClasses();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners(); // Memberitahu UI untuk menghilangkan loading dan menampilkan data
    }
  }

  // Menambahkan kelas baru dan langsung merefresh daftar
  Future<bool> addClass(KelasModel newClass) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _classService.addClass(newClass);
      await fetchClasses(); // Refresh data otomatis setelah berhasil tambah
      return true; // Berhasil
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false; // Gagal
    }
  }

  // Memperbarui kelas (misal: ganti wali kelas)
  Future<bool> updateClass(KelasModel updatedClass) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _classService.updateClass(updatedClass);
      await fetchClasses(); // Refresh data
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Menghapus kelas
  Future<bool> deleteClass(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _classService.deleteClass(id);
      await fetchClasses(); // Refresh data setelah dihapus
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Fungsi untuk pencarian lokal
  void searchClasses(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}

// Deklarasi Global Provider
final classProvider = ChangeNotifierProvider<ClassProvider>((ref) => ClassProvider());