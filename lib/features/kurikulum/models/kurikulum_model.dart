class KurikulumModel {
  final String? id;
  final String programId;
  final String namaKurikulum;
  final bool isActive;

  KurikulumModel({
    this.id,
    required this.programId,
    required this.namaKurikulum,
    this.isActive = true,
  });

  factory KurikulumModel.fromJson(Map<String, dynamic> json) => KurikulumModel(
    id: json['id'],
    programId: json['program_id'] ?? '',
    namaKurikulum: json['nama_kurikulum'] ?? '',
    isActive: json['is_active'] ?? true,
  );

  Map<String, dynamic> toJson() => {
    'program_id': programId,
    'nama_kurikulum': namaKurikulum,
    'is_active': isActive,
  };
}

class LevelModel {
  final String? id;
  final String kurikulumId;
  final String namaLevel;
  final int urutan; // Untuk menentukan Level 1, 2, 3...
  final String? targetHafalan;

  LevelModel({
    this.id,
    required this.kurikulumId,
    required this.namaLevel,
    required this.urutan,
    this.targetHafalan,
  });

  factory LevelModel.fromJson(Map<String, dynamic> json) => LevelModel(
    id: json['id'],
    kurikulumId: json['kurikulum_id'] ?? '',
    namaLevel: json['nama_level'] ?? '',
    urutan: json['urutan'] ?? 0,
    targetHafalan: json['target_hafalan'],
  );

  Map<String, dynamic> toJson() => {
    'kurikulum_id': kurikulumId,
    'nama_level': namaLevel,
    'urutan': urutan,
    'target_hafalan': targetHafalan,
  };
}