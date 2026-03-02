// Lokasi: lib/features/kelas/models/kelas_model.dart

import '../../guru_staff/models/staff_model.dart';
import '../../program/models/program_model.dart'; // Sesuaikan foldernya

class KelasModel {
  final String? id;
  final String name;
  final String? level; // Untuk simpan teks level (opsional)
  final String? levelId; // Relasi ke kurikulum_level_id
  final String? teacherId; // ID dari profiles/gurus
  final String? programId; // Relasi ke program_id
  final String? waktuBelajar;
  final String? ruangan;
  final int? kapasitas;
  final DateTime? createdAt;

  // Objek lengkap hasil JOIN (Sangat berguna untuk UI)
  final StaffModel? waliKelas;
  final ProgramModel? program;

  KelasModel({
    this.id,
    required this.name,
    this.level,
    this.levelId,
    this.teacherId,
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
      id: json['id'],
      name: json['name'] ?? '',
      level: json['level'],
      levelId: json['level_id'],
      teacherId: json['teacher_id'],
      programId: json['program_id'],
      waktuBelajar: json['waktu_belajar'],
      ruangan: json['ruangan'],
      kapasitas: json['kapasitas'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,

      // Mapping JOIN query dari Supabase
      // json['profiles'] atau json['gurus'] tergantung alias di query-mu nanti
      waliKelas: json['profiles'] != null
          ? StaffModel.fromJson(json['profiles'])
          : null,

      program: json['program'] != null
          ? ProgramModel.fromJson(json['program'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'level': level,
      'level_id': levelId,
      'teacher_id': teacherId,
      'program_id': programId,
      'waktu_belajar': waktuBelajar,
      'ruangan': ruangan,
      'kapasitas': kapasitas,
    };
  }

  KelasModel copyWith({
    String? id,
    String? name,
    String? level,
    String? levelId,
    String? teacherId,
    String? programId,
    String? waktuBelajar,
    String? ruangan,
    int? kapasitas,
    StaffModel? waliKelas,
    ProgramModel? program,
  }) {
    return KelasModel(
      id: id ?? this.id,
      name: name ?? this.name,
      level: level ?? this.level,
      levelId: levelId ?? this.levelId,
      teacherId: teacherId ?? this.teacherId,
      programId: programId ?? this.programId,
      waktuBelajar: waktuBelajar ?? this.waktuBelajar,
      ruangan: ruangan ?? this.ruangan,
      kapasitas: kapasitas ?? this.kapasitas,
      waliKelas: waliKelas ?? this.waliKelas,
      program: program ?? this.program,
    );
  }
}