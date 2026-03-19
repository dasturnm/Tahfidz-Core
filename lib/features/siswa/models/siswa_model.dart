// Lokasi: lib/features/siswa/models/siswa_model.dart

import '../../kelas/models/kelas_model.dart';
import '../../program/models/program_model.dart';
import 'package:tahfidz_core/shared/models/profile_model.dart';

class SiswaModel {
  final String? id;
  final String lembagaId;
  final String? cabangId;
  final String namaLengkap;
  final String? nisn;
  final String jenisKelamin; // 'L' atau 'P'
  final DateTime? tglLahir;
  final String? alamat;
  final String status; // 'aktif', 'nonaktif', 'lulus', 'pindah'

  final String? kelasId; // PERBAIKAN: Label Kelas
  final String? guruId;
  final String? programId;
  final String? currentLevelId;

  final String? lastSurah;
  final int? lastAyat;
  final double totalJuzHafalan;

  final KelasModel? kelas;
  final ProgramModel? program;
  final ProfileModel? guruPembimbing;

  SiswaModel({
    this.id,
    required this.lembagaId,
    this.cabangId,
    required this.namaLengkap,
    this.nisn,
    required this.jenisKelamin,
    this.tglLahir,
    this.alamat,
    this.status = 'aktif',
    this.kelasId, // PERBAIKAN: Label Kelas
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

  factory SiswaModel.fromJson(Map<String, dynamic> json) {
    return SiswaModel(
      id: json['id']?.toString(), // FIX: Safe UUID casting
      lembagaId: json['lembaga_id']?.toString() ?? '',
      cabangId: json['cabang_id']?.toString(),
      namaLengkap: json['nama_lengkap'] as String? ?? '',
      nisn: json['nisn'] as String?,
      jenisKelamin: json['jenis_kelamin'] as String? ?? 'L',
      tglLahir: json['tgl_lahir'] != null ? DateTime.parse(json['tgl_lahir'].toString()) : null,
      alamat: json['alamat'] as String?,
      status: json['status'] as String? ?? 'aktif',
      kelasId: json['kelas_id']?.toString(), // FIX: Safe UUID casting
      guruId: json['guru_id']?.toString(),
      programId: json['program_id']?.toString(),
      currentLevelId: json['current_level_id']?.toString(),
      lastSurah: json['last_surah'] as String?,
      lastAyat: json['last_ayat'] as int?,
      totalJuzHafalan: (json['total_juz_hafalan'] ?? 0).toDouble(),
      // Mapping JOIN query dari Supabase menggunakan alias singular
      kelas: json['kelas'] != null ? KelasModel.fromJson(json['kelas']) : null,
      program: json['program'] != null ? ProgramModel.fromJson(json['program']) : null,
      guruPembimbing: json['guru'] != null ? ProfileModel.fromJson(json['guru']) : null,
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
      'kelas_id': kelasId, // PERBAIKAN: Sync kolom kelas_id
      'guru_id': guruId,
      'program_id': programId,
      'current_level_id': currentLevelId,
      'last_surah': lastSurah,
      'last_ayat': lastAyat,
      'total_juz_hafalan': totalJuzHafalan,
    };
  }

  SiswaModel copyWith({
    String? id,
    String? lembagaId,
    String? cabangId,
    String? namaLengkap,
    String? nisn,
    String? jenisKelamin,
    DateTime? tglLahir,
    String? alamat,
    String? status,
    String? kelasId,
    String? guruId,
    String? programId,
    String? currentLevelId,
    String? lastSurah,
    int? lastAyat,
    double? totalJuzHafalan,
    KelasModel? kelas,
    ProgramModel? program,
    ProfileModel? guruPembimbing,
  }) {
    return SiswaModel(
      id: id ?? this.id,
      lembagaId: lembagaId ?? this.lembagaId,
      cabangId: cabangId ?? this.cabangId,
      namaLengkap: namaLengkap ?? this.namaLengkap,
      nisn: nisn ?? this.nisn,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      tglLahir: tglLahir ?? this.tglLahir,
      alamat: alamat ?? this.alamat,
      status: status ?? this.status,
      kelasId: kelasId ?? this.kelasId,
      guruId: guruId ?? this.guruId,
      programId: programId ?? this.programId,
      currentLevelId: currentLevelId ?? this.currentLevelId,
      lastSurah: lastSurah ?? this.lastSurah,
      lastAyat: lastAyat ?? this.lastAyat,
      totalJuzHafalan: totalJuzHafalan ?? this.totalJuzHafalan,
      kelas: kelas ?? this.kelas,
      program: program ?? this.program,
      guruPembimbing: guruPembimbing ?? this.guruPembimbing,
    );
  }
}