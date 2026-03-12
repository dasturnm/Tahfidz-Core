// Lokasi: lib/features/siswa/providers/student_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/student_model.dart';
import '../services/student_service.dart';

class StudentProvider extends ChangeNotifier {
  final StudentService _studentService = StudentService();

  // State
  List<StudentModel> _students = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
// Tambahkan variabel state filter baru
  String _statusFilter = 'Semua';
  String _genderFilter = 'Semua';
  // Getter
  List<StudentModel> get students {
    if (_searchQuery.isEmpty) return _students;
    final query = _searchQuery.toLowerCase();
    return _students.where((s) =>
    s.namaLengkap.toLowerCase().contains(query) ||
        (s.nisn ?? '').toLowerCase().contains(query)
    ).toList();
  }
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 1. MENGAMBIL SEMUA DATA SANTRI
  Future<void> fetchStudents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _students = await _studentService.getStudents();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. MENAMBAHKAN SANTRI
  Future<bool> addStudent(StudentModel newStudent) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _studentService.addStudent(newStudent);
      await fetchStudents(); // Refresh data otomatis
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 3. MEMPERBARUI DATA SANTRI
  Future<bool> updateStudent(StudentModel updatedStudent) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _studentService.updateStudent(updatedStudent);
      await fetchStudents(); // Refresh data
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 4. MENGHAPUS SANTRI
  Future<bool> deleteStudent(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _studentService.deleteStudent(id);
      await fetchStudents(); // Refresh data
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 5. FITUR PLOTTING: Memasukkan/mengeluarkan santri dari kelas
  Future<bool> assignStudentToClass(String studentId, String? classId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _studentService.assignStudentToClass(studentId, classId);
      await fetchStudents(); // Refresh data setelah plotting
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 6. BULK IMPORT: Menambahkan banyak santri sekaligus (CSV)
  Future<bool> bulkImportStudents(List<StudentModel> students) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _studentService.bulkAddStudents(students);
      await fetchStudents(); // Refresh data otomatis
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 7. BULK PLOTTING: Memasukkan banyak santri ke dalam satu kelas sekaligus
  Future<bool> bulkAssignToClass(List<String> studentIds, String? classId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _studentService.bulkAssignStudentsToClass(studentIds, classId);
      await fetchStudents(); // Refresh data setelah plotting masal
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
  List<StudentModel> get unassignedStudents {
    return _students.where((s) => s.classId == null).toList();
  }

  // Opsional: Filter lokal untuk mengambil siswa di kelas tertentu
  List<StudentModel> getStudentsInClass(String classId) {
    return _students.where((s) => s.classId == classId).toList();
  }

  // 8. PENCARIAN SISWA
  void searchStudents(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}

// Deklarasi Global Provider
final studentProvider = ChangeNotifierProvider<StudentProvider>((ref) => StudentProvider());