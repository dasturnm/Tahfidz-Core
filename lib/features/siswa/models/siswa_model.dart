// Lokasi: lib/features/siswa/models/siswa_model.dart

import '../../kelas/models/kelas_model.dart';
import '../../program/models/program_model.dart';
import '../../akademik/kurikulum/models/kurikulum_model.dart'; // Tambahan untuk LevelModel
import 'package:tahfidz_core/shared/models/profile_model.dart';

class SiswaModel {
  final String? id;
  final String lembagaId;
  final String? cabangId;
  final String namaLengkap;
  final String? nisn;
  final String? email; // TAMBAHAN: Untuk keperluan Auth/Import
  final String? noHp; // TAMBAHAN: Untuk keperluan Auth/Import
  final String? passwordSementara; // TAMBAHAN: Untuk kebutuhan Template CSV
  final String jenisKelamin; // 'L' atau 'P'
  final DateTime? tglLahir;
  final String? alamat;
  final String status; // 'aktif', 'nonaktif', 'lulus', 'pindah'

  final String? kelasId;
  final String? guruId;
  final String? programId;
  final String? levelId; // TAMBAHAN: Sinkron dengan kolom level_id di DB
  final String? currentLevelId;

  final String? lastSurah;
  final int? lastAyat;
  final double totalJuzHafalan;

  final KelasModel? kelas;
  final ProgramModel? program;
  final ProfileModel? guruPembimbing;
  final LevelModel? currentLevel; // TAMBAHAN: Untuk menampung hasil join kurikulum_level

  SiswaModel({
    this.id,
    required this.lembagaId,
    this.cabangId,
    required this.namaLengkap,
    this.nisn,
    this.email,
    this.noHp,
    this.passwordSementara,
    required this.jenisKelamin,
    this.tglLahir,
    this.alamat,
    this.status = 'aktif',
    this.kelasId,
    this.guruId,
    this.programId,
    this.levelId,
    this.currentLevelId,
    this.lastSurah,
    this.lastAyat,
    this.totalJuzHafalan = 0.0,
    this.kelas,
    this.program,
    this.guruPembimbing,
    this.currentLevel, // Tambahan
  });

  factory SiswaModel.fromJson(Map<String, dynamic> json) {
    return SiswaModel(
      id: (json['id'] == null || json['id'].toString() == 'null') ? null : json['id'].toString(),
      lembagaId: json['lembaga_id']?.toString() ?? '',
      cabangId: (json['cabang_id'] == null || json['cabang_id'].toString() == 'null') ? null : json['cabang_id'].toString(),
      namaLengkap: json['nama_lengkap']?.toString() ?? '',
      nisn: json['nisn']?.toString(),
      email: json['email']?.toString(),
      noHp: json['no_hp']?.toString(),
      passwordSementara: null, // Tidak disimpan di DB
      jenisKelamin: json['jenis_kelamin']?.toString() ?? 'L',
      tglLahir: json['tgl_lahir'] != null
          ? DateTime.tryParse(json['tgl_lahir'].toString())
          : null,
      alamat: json['alamat']?.toString(),
      status: json['status']?.toString() ?? 'aktif',
      kelasId: (json['kelas_id'] == null || json['kelas_id'].toString() == 'null') ? null : json['kelas_id'].toString(),
      guruId: (json['guru_id'] == null || json['guru_id'].toString() == 'null') ? null : json['guru_id'].toString(),
      programId: (json['program_id'] == null || json['program_id'].toString() == 'null') ? null : json['program_id'].toString(),
      levelId: (json['level_id'] == null || json['level_id'].toString() == 'null') ? null : json['level_id'].toString(),
      currentLevelId: (json['current_level_id'] == null || json['current_level_id'].toString() == 'null') ? null : json['current_level_id'].toString(),
      lastSurah: json['last_surah']?.toString(),
      lastAyat: json['last_ayat'] != null ? (json['last_ayat'] as num).toInt() : null,
      totalJuzHafalan: (json['total_juz_hafalan'] as num? ?? 0).toDouble(),
      kelas: json['kelas'] != null ? KelasModel.fromJson(json['kelas']) : null,
      program: json['program'] != null ? ProgramModel.fromJson(json['program']) : null,
      guruPembimbing: json['guru'] != null ? ProfileModel.fromJson(json['guru']) : null,
      // MAPPING: Mengambil data kurikulum_level (*) dari join service
      currentLevel: json['kurikulum_level'] != null ? LevelModel.fromJson(json['kurikulum_level']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'lembaga_id': lembagaId,
      'cabang_id': cabangId,
      'nama_lengkap': namaLengkap, // FIX: Typo namaLengkaap diperbaiki
      'nisn': nisn,
      'email': email,
      'no_hp': noHp,
      'jenis_kelamin': jenisKelamin,
      'tgl_lahir': tglLahir?.toIso8601String().split('T')[0],
      'alamat': alamat,
      'status': status,
      'kelas_id': kelasId,
      'guru_id': guruId,
      'program_id': programId,
      'level_id': levelId,
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
    String? email,
    String? noHp,
    String? passwordSementara,
    String? jenisKelamin,
    DateTime? tglLahir,
    String? alamat,
    String? status,
    String? kelasId,
    String? guruId,
    String? programId,
    String? levelId,
    String? currentLevelId,
    String? lastSurah,
    int? lastAyat,
    double? totalJuzHafalan,
    KelasModel? kelas,
    ProgramModel? program,
    ProfileModel? guruPembimbing,
    LevelModel? currentLevel,
  }) {
    return SiswaModel(
      id: id ?? this.id,
      lembagaId: lembagaId ?? this.lembagaId,
      cabangId: cabangId ?? this.cabangId,
      namaLengkap: namaLengkap ?? this.namaLengkap,
      nisn: nisn ?? this.nisn,
      email: email ?? this.email,
      noHp: noHp ?? this.noHp,
      passwordSementara: passwordSementara ?? this.passwordSementara,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      tglLahir: tglLahir ?? this.tglLahir,
      alamat: alamat ?? this.alamat,
      status: status ?? this.status,
      kelasId: kelasId ?? this.kelasId,
      guruId: guruId ?? this.guruId,
      programId: programId ?? this.programId,
      levelId: levelId ?? this.levelId,
      currentLevelId: currentLevelId ?? this.currentLevelId,
      lastSurah: lastSurah ?? this.lastSurah,
      lastAyat: lastAyat ?? this.lastAyat,
      totalJuzHafalan: totalJuzHafalan ?? this.totalJuzHafalan,
      kelas: kelas ?? this.kelas,
      program: program ?? this.program,
      guruPembimbing: guruPembimbing ?? this.guruPembimbing,
      currentLevel: currentLevel ?? this.currentLevel,
    );
  }
}