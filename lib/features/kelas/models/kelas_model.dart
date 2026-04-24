// Lokasi: lib/features/kelas/models/kelas_model.dart

import 'package:tahfidz_core/shared/models/profile_model.dart';
import '../../program/models/program_model.dart'; // Sesuaikan foldernya

class KelasModel {
  final String? id;
  final String? lembagaId; // FIX: Tambahkan lembagaId
  final String namaKelas; // FIX: Label Kelas (Sebelumnya name)
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
    required this.namaKelas, // FIX: Menggunakan namaKelas
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
      id: (json['id'] == null || json['id'].toString() == 'null') ? null : json['id'].toString(),
      lembagaId: (json['lembaga_id'] == null || json['lembaga_id'].toString() == 'null') ? null : json['lembaga_id'].toString(),
      namaKelas: json['nama_kelas']?.toString() ?? '', // FIX: Sinkron dengan kolom nama_kelas
      guruId: (json['guru_id'] == null || json['guru_id'].toString() == 'null') ? null : json['guru_id'].toString(),
      programId: (json['program_id'] == null || json['program_id'].toString() == 'null') ? null : json['program_id'].toString(),
      waktuBelajar: (json['waktu_belajar'] == null || json['waktu_belajar'].toString() == 'null') ? null : json['waktu_belajar'].toString(),
      ruangan: (json['ruangan'] == null || json['ruangan'].toString() == 'null') ? null : json['ruangan'].toString(),
      kapasitas: json['kapasitas'] != null ? (json['kapasitas'] as num).toInt() : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,

      // Relasi (Null check wajib sesuai protokol v2026.03.22)
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
      'nama_kelas': namaKelas, // FIX: Simpan ke kolom nama_kelas
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
    String? namaKelas, // FIX: Parameter namaKelas
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
      namaKelas: namaKelas ?? this.namaKelas, // FIX: Update namaKelas
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