// Lokasi: lib/features/siswa/models/student_model.dart

import '../../kelas/models/kelas_model.dart';
import '../../program/models/program_model.dart';
import '../../guru_staff/models/staff_model.dart';

class StudentModel {
  final String? id;
  final String lembagaId;
  final String? cabangId;
  final String namaLengkap;
  final String? nisn;
  final String jenisKelamin; // 'L' atau 'P'
  final DateTime? tglLahir;
  final String? alamat;
  final String status; // 'aktif', 'nonaktif', 'lulus', 'pindah'

  final String? classId;
  final String? guruId;
  final String? programId;
  final String? currentLevelId;

  final String? lastSurah;
  final int? lastAyat;
  final double totalJuzHafalan;

  final KelasModel? kelas;
  final ProgramModel? program;
  final StaffModel? guruPembimbing;

  StudentModel({
    this.id,
    required this.lembagaId,
    this.cabangId,
    required this.namaLengkap,
    this.nisn,
    required this.jenisKelamin,
    this.tglLahir,
    this.alamat,
    this.status = 'aktif',
    this.classId,
    this.guruId,
    this.programId,
    this.currentLevelId,
    this.lastSurah,
    this.lastAyat,
    this.totalJuzHafalan = 0,
    this.kelas,
    this.program,
    this.guruPembimbing,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'],
      lembagaId: json['lembaga_id'] ?? '',
      cabangId: json['cabang_id'],
      namaLengkap: json['nama_lengkap'] ?? '',
      nisn: json['nisn'],
      jenisKelamin: json['jenis_kelamin'] ?? 'L',
      tglLahir: json['tgl_lahir'] != null ? DateTime.parse(json['tgl_lahir']) : null,
      alamat: json['alamat'],
      status: json['status'] ?? 'aktif',
      classId: json['class_id'],
      guruId: json['guru_id'],
      programId: json['program_id'],
      currentLevelId: json['current_level_id'],
      lastSurah: json['last_surah'],
      lastAyat: json['last_ayat'],
      totalJuzHafalan: (json['total_juz_hafalan'] ?? 0).toDouble(),
      kelas: json['classes'] != null ? KelasModel.fromJson(json['classes']) : null,
      program: json['program'] != null ? ProgramModel.fromJson(json['program']) : null,
      guruPembimbing: json['profiles'] != null ? StaffModel.fromJson(json['profiles']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'lembaga_id': lembagaId,
      'cabang_id': cabangId,
      'nama_lengkap': namaLengkap,
      'nisn': nisn,
      'jenis_kelamin': jenisKelamin,
      'tgl_lahir': tglLahir?.toIso8601String(),
      'alamat': alamat,
      'status': status,
      'class_id': classId,
      'guru_id': guruId,
      'program_id': programId,
      'current_level_id': currentLevelId,
      'last_surah': lastSurah,
      'last_ayat': lastAyat,
      'total_juz_hafalan': totalJuzHafalan,
    };
  }

  StudentModel copyWith({
    String? id,
    String? namaLengkap,
    String? status,
    String? classId,
    String? programId,
    double? totalJuzHafalan,
    String? lastSurah,
    int? lastAyat,
  }) {
    return StudentModel(
      // 'this.' tetap dipakai di sini karena ada parameter 'id' yang membayangi properti 'id'
      id: id ?? this.id,
      // 'this.' dihapus di bawah karena tidak ada parameter yang membayanginya
      lembagaId: lembagaId,
      cabangId: cabangId,
      namaLengkap: namaLengkap ?? this.namaLengkap,
      nisn: nisn,
      jenisKelamin: jenisKelamin,
      tglLahir: tglLahir,
      alamat: alamat,
      status: status ?? this.status,
      classId: classId ?? this.classId,
      guruId: guruId,
      programId: programId ?? this.programId,
      currentLevelId: currentLevelId,
      lastSurah: lastSurah ?? this.lastSurah,
      lastAyat: lastAyat ?? this.lastAyat,
      totalJuzHafalan: totalJuzHafalan ?? this.totalJuzHafalan,
      kelas: kelas,
      program: program,
      guruPembimbing: guruPembimbing,
    );
  }
}