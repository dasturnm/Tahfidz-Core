// Lokasi: lib/features/siswa/models/siswa_model.dart

import '../../kelas/models/kelas_model.dart';
import '../../program/models/program_model.dart';
import '../../management_lembaga/models/cabang_model.dart'; // TAMBAHAN
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
  final String? kurikulumId; // TAMBAHAN: Referensi Kurikulum
  final String? levelId; // TAMBAHAN: Sinkron dengan kolom level_id di DB
  final String? currentLevelId;
  final String? currentModulId; // TAMBAHAN: Referensi Modul Awal
  final bool isReadyForExam; // TAMBAHAN SINKRONISASI SUPABASE (Opsi B)
  final String? readyModulId; // TAMBAHAN SINKRONISASI SUPABASE (Opsi B)
  final String academicState; // TAMBAHAN: Menyimpan status posisi santri ('daily', 'tasmi_mode', 'exam_ready')

  final String? lastSurah;
  final int? lastAyah;
  final double totalJuzHafalan;

  final CabangModel? cabang; // TAMBAHAN
  final KelasModel? kelas;
  final ProgramModel? program;
  final ProfileModel? guruPembimbing;
  final LevelModel? currentLevel; // TAMBAHAN: Untuk menampung hasil join kurikulum_level

  // FIX: Compatibility Bridge (Aturan v2026.03.22) untuk memetakan flag boolean lama agar reaktif & tidak memecahkan modul lain
  bool get isReadyForExamCompat => academicState == 'exam_ready' || isReadyForExam;

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
    this.kurikulumId,
    this.levelId,
    this.currentLevelId,
    this.currentModulId,
    this.isReadyForExam = false, // TAMBAHAN SINKRONISASI SUPABASE (Opsi B)
    this.readyModulId, // TAMBAHAN SINKRONISASI SUPABASE (Opsi B)
    this.academicState = 'daily', // TAMBAHAN
    this.lastSurah,
    this.lastAyah,
    this.totalJuzHafalan = 0.0,
    this.cabang, // TAMBAHAN
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
      kurikulumId: (json['kurikulum_id'] == null || json['kurikulum_id'].toString() == 'null') ? null : json['kurikulum_id'].toString(),
      levelId: (json['level_id'] == null || json['level_id'].toString() == 'null') ? null : json['level_id'].toString(),
      currentLevelId: (json['current_level_id'] == null || json['current_level_id'].toString() == 'null') ? null : json['current_level_id'].toString(),
      currentModulId: (json['current_modul_id'] == null || json['current_modul_id'].toString() == 'null') ? null : json['current_modul_id'].toString(),
      isReadyForExam: json['is_ready_for_exam'] == true, // TAMBAHAN SINKRONISASI SUPABASE (Opsi B)
      readyModulId: (json['ready_modul_id'] == null || json['ready_modul_id'].toString() == 'null') ? null : json['ready_modul_id'].toString(), // TAMBAHAN SINKRONISASI SUPABASE (Opsi B)
      academicState: json['academic_state']?.toString() ?? 'daily', // TAMBAHAN
      lastSurah: json['last_surah']?.toString(),
      lastAyah: json['last_ayah'] != null ? (json['last_ayah'] as num).toInt() : null,
      totalJuzHafalan: (json['total_juz_hafalan'] as num? ?? 0).toDouble(),
      cabang: json['cabang'] != null ? CabangModel.fromJson(json['cabang']) : null, // TAMBAHAN
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
      'kurikulum_id': kurikulumId,
      'level_id': levelId,
      'current_level_id': currentLevelId,
      'current_modul_id': currentModulId,
      'is_ready_for_exam': isReadyForExam, // TAMBAHAN SINKRONISASI SUPABASE (Opsi B)
      'ready_modul_id': readyModulId, // TAMBAHAN SINKRONISASI SUPABASE (Opsi B)
      'academic_state': academicState, // TAMBAHAN
      'last_surah': lastSurah,
      'last_ayah': lastAyah,
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
    String? kurikulumId,
    String? levelId,
    String? currentLevelId,
    String? currentModulId,
    bool? isReadyForExam, // TAMBAHAN SINKRONISASI SUPABASE (Opsi B)
    String? readyModulId, // TAMBAHAN SINKRONISASI SUPABASE (Opsi B)
    String? academicState, // TAMBAHAN
    String? lastSurah,
    int? lastAyah,
    double? totalJuzHafalan,
    CabangModel? cabang, // TAMBAHAN
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
      kurikulumId: kurikulumId ?? this.kurikulumId,
      levelId: levelId ?? this.levelId,
      currentLevelId: currentLevelId ?? this.currentLevelId,
      currentModulId: currentModulId ?? this.currentModulId,
      isReadyForExam: isReadyForExam ?? this.isReadyForExam, // TAMBAHAN SINKRONISASI SUPABASE (Opsi B)
      readyModulId: readyModulId ?? this.readyModulId, // TAMBAHAN SINKRONISASI SUPABASE (Opsi B)
      academicState: academicState ?? this.academicState, // TAMBAHAN
      lastSurah: lastSurah ?? this.lastSurah,
      lastAyah: lastAyah ?? this.lastAyah,
      totalJuzHafalan: totalJuzHafalan ?? this.totalJuzHafalan,
      cabang: cabang ?? this.cabang, // TAMBAHAN
      kelas: kelas ?? this.kelas,
      program: program ?? this.program,
      guruPembimbing: guruPembimbing ?? this.guruPembimbing,
      currentLevel: currentLevel ?? this.currentLevel,
    );
  }
}