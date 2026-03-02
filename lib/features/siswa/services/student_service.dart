// Lokasi: lib/features/siswa/services/student_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/student_model.dart'; // Pastikan path ini sesuai

class StudentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 1. READ: Mengambil semua data santri (Untuk Tab Database Santri)
  Future<List<StudentModel>> getStudents() async {
    try {
      // Mengambil data siswa beserta relasi kelas, program, dan levelnya
      final response = await _supabase
          .from('siswa')
          .select('''
            *,
            classes (*),
            program (*),
            kurikulum_level (*)
          ''')
          .order('nama_lengkap', ascending: true);

      return (response as List)
          .map((json) => StudentModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil data santri: $e');
    }
  }

  /// 2. READ BY CLASS: Mengambil santri berdasarkan Kelas (Untuk Detail Kelas)
  Future<List<StudentModel>> getStudentsByClass(String classId) async {
    try {
      final response = await _supabase
          .from('siswa')
          .select('''
            *,
            classes (*),
            program (*),
            kurikulum_level (*)
          ''')
          .eq('class_id', classId)
          .order('nama_lengkap', ascending: true);

      return (response as List)
          .map((json) => StudentModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil data santri di kelas ini: $e');
    }
  }

  /// 3. CREATE: Menambahkan santri baru
  Future<void> addStudent(StudentModel student) async {
    try {
      await _supabase.from('siswa').insert(student.toJson());
    } catch (e) {
      throw Exception('Gagal menambahkan santri baru: $e');
    }
  }

  /// 4. UPDATE: Memperbarui data santri
  Future<void> updateStudent(StudentModel student) async {
    if (student.id == null) throw Exception('ID Santri tidak ditemukan');

    try {
      await _supabase
          .from('siswa')
          .update(student.toJson())
          .eq('id', student.id!);
    } catch (e) {
      throw Exception('Gagal memperbarui data santri: $e');
    }
  }

  /// 5. DELETE: Menghapus santri
  Future<void> deleteStudent(String id) async {
    try {
      await _supabase.from('siswa').delete().eq('id', id);
    } catch (e) {
      throw Exception('Gagal menghapus data santri: $e');
    }
  }

  /// 6. PLOTTING: Memasukkan/Mengeluarkan santri dari Kelas
  /// Jika classId null, artinya santri dikeluarkan dari kelas (Unassigned)
  Future<void> assignStudentToClass(String studentId, String? classId) async {
    try {
      await _supabase
          .from('siswa')
          .update({'class_id': classId}) // Hanya mengupdate kolom class_id
          .eq('id', studentId);
    } catch (e) {
      throw Exception('Gagal melakukan plotting santri: $e');
    }
  }

  /// 7. BULK CREATE: Import santri dalam jumlah banyak (Untuk Import CSV)
  Future<void> bulkAddStudents(List<StudentModel> students) async {
    try {
      final data = students.map((s) => s.toJson()).toList();
      await _supabase.from('siswa').insert(data);
    } catch (e) {
      throw Exception('Gagal mengimpor data santri: $e');
    }
  }

  /// 8. BULK PLOTTING: Memasukkan banyak santri ke dalam satu Kelas sekaligus
  Future<void> bulkAssignStudentsToClass(List<String> studentIds, String? classId) async {
    try {
      await _supabase
          .from('siswa')
          .update({'class_id': classId})
          .inFilter('id', studentIds);
    } catch (e) {
      throw Exception('Gagal melakukan plotting masal santri: $e');
    }
  }
}