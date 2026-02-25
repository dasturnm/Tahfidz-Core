import '../../guru_staff/models/staff_model.dart';

class KelasModel {
  final String? id;
  final String name;
  final String? level;
  final String? teacherId; // Relasi ke ID Guru
  final DateTime? createdAt;

  // Opsional: Jika ingin langsung menyertakan data Guru saat fetching (join query)
  final StaffModel? waliKelas;

  KelasModel({
    this.id,
    required this.name,
    this.level,
    this.teacherId,
    this.createdAt,
    this.waliKelas,
  });

  factory KelasModel.fromJson(Map<String, dynamic> json) {
    return KelasModel(
      id: json['id'],
      name: json['name'] ?? '',
      level: json['level'],
      teacherId: json['teacher_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      // Mapping jika data guru disertakan dalam query select ('*, gurus(*)')
      waliKelas: json['gurus'] != null
          ? StaffModel.fromJson(json['gurus'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'level': level,
      'teacher_id': teacherId,
    };
  }

  KelasModel copyWith({
    String? id,
    String? name,
    String? level,
    String? teacherId,
  }) {
    return KelasModel(
      id: id ?? this.id,
      name: name ?? this.name,
      level: level ?? this.level,
      teacherId: teacherId ?? this.teacherId,
    );
  }
}