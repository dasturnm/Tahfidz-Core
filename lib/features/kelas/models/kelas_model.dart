// Lokasi: lib/features/kelas/models/kelas_model.dart

import 'package:tahfidz_core/shared/models/profile_model.dart';
import '../../program/models/program_model.dart'; // Sesuaikan foldernya

class KelasModel {
  final String? id;
  final String? lembagaId; // FIX: Tambahkan lembagaId
  final String? cabangId;  // FIX: Tambahkan cabangId
  final String name;
  final String? level; // Untuk simpan teks level (opsional)
  final String? levelId; // Relasi ke kurikulum_level_id
  final String? guruId; // PERBAIKAN: Label Guru (Sebelumnya teacherId)
  final String? programId; // Relasi ke program_id
  final String? waktuBelajar;
  final String? ruangan;
  final int? kapasitas;
  final DateTime? createdAt;

  // Objek lengkap hasil JOIN (Sangat berguna untuk UI)
  final ProfileModel? waliKelas;
  final ProgramModel? program;

  KelasModel({
    this.id,
    this.lembagaId, // FIX: Inisialisasi lembagaId
    this.cabangId,  // FIX: Inisialisasi cabangId
    required this.name,
    this.level,
    this.levelId,
    this.guruId,
    this.programId,
    this.waktuBelajar,
    this.ruangan,
    this.kapasitas,
    this.createdAt,
    this.waliKelas,
    this.program,
  });

  factory KelasModel.fromJson(Map<String, dynamic> json) {
    return KelasModel(
      id: json['id'] as String?,
      lembagaId: json['lembaga_id'] as String?, // FIX: Ambil dari JSON
      cabangId: json['cabang_id'] as String?,   // FIX: Ambil dari JSON
      name: json['name'] as String? ?? '',
      level: json['level'] as String?,
      levelId: json['level_id'] as String?,
      guruId: json['guru_id'] as String?, // PERBAIKAN: Sync dengan kolom guru_id
      programId: json['program_id'] as String?,
      waktuBelajar: json['waktu_belajar'] as String?,
      ruangan: json['ruangan'] as String?,
      kapasitas: json['kapasitas'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,

      // Mapping JOIN query dari Supabase menggunakan alias 'guru'
      waliKelas: json['guru'] != null
          ? ProfileModel.fromJson(json['guru'] as Map<String, dynamic>)
          : null,

      program: json['program'] != null
          ? ProgramModel.fromJson(json['program'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'lembaga_id': lembagaId, // FIX: Simpan lembagaId
      'cabang_id': cabangId,   // FIX: Simpan cabangId
      'name': name,
      'level': level,
      'level_id': levelId,
      'guru_id': guruId, // PERBAIKAN: Sync dengan kolom guru_id
      'program_id': programId,
      'waktu_belajar': waktuBelajar,
      'ruangan': ruangan,
      'kapasitas': kapasitas,
    };
  }

  KelasModel copyWith({
    String? id,
    String? lembagaId, // FIX: Parameter lembagaId
    String? cabangId,  // FIX: Parameter cabangId
    String? name,
    String? level,
    String? levelId,
    String? guruId,
    String? programId,
    String? waktuBelajar,
    String? ruangan,
    int? kapasitas,
    DateTime? createdAt,
    ProfileModel? waliKelas,
    ProgramModel? program,
  }) {
    return KelasModel(
      id: id ?? this.id,
      lembagaId: lembagaId ?? this.lembagaId, // FIX: Update lembagaId
      cabangId: cabangId ?? this.cabangId,   // FIX: Update cabangId
      name: name ?? this.name,
      level: level ?? this.level,
      levelId: levelId ?? this.levelId,
      guruId: guruId ?? this.guruId,
      programId: programId ?? this.programId,
      waktuBelajar: waktuBelajar ?? this.waktuBelajar,
      ruangan: ruangan ?? this.ruangan,
      kapasitas: kapasitas ?? this.kapasitas,
      createdAt: createdAt ?? this.createdAt,
      waliKelas: waliKelas ?? this.waliKelas,
      program: program ?? this.program,
    );
  }
}