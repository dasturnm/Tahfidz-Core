class JabatanModel {
  final String id;
  final String lembagaId; // Ditambahkan agar data tidak jadi hantu
  final String divisiId;
  final String namaJabatan;
  final String defaultRole; // ADMIN_PUSAT, ADMIN_CABANG, GURU, STAFF
  final String? status;
  final int? levelJabatan;
  final String? catatanJabatan;

  JabatanModel({
    required this.id,
    required this.lembagaId, // Wajib diisi
    required this.divisiId,
    required this.namaJabatan,
    required this.defaultRole,
    this.status,
    this.levelJabatan,
    this.catatanJabatan,
  });

  JabatanModel copyWith({
    String? id,
    String? lembagaId,
    String? divisiId,
    String? namaJabatan,
    String? defaultRole,
    String? status,
    int? levelJabatan,
    String? catatanJabatan,
  }) {
    return JabatanModel(
      id: id ?? this.id,
      lembagaId: lembagaId ?? this.lembagaId,
      divisiId: divisiId ?? this.divisiId,
      namaJabatan: namaJabatan ?? this.namaJabatan,
      defaultRole: defaultRole ?? this.defaultRole,
      status: status ?? this.status,
      levelJabatan: levelJabatan ?? this.levelJabatan,
      catatanJabatan: catatanJabatan ?? this.catatanJabatan,
    );
  }

  factory JabatanModel.fromJson(Map<String, dynamic> json) => JabatanModel(
    id: json['id'],
    lembagaId: json['lembaga_id'] ?? '',
    divisiId: json['divisi_id'] ?? '',
    namaJabatan: json['nama_jabatan'] ?? '',
    defaultRole: json['default_role'] ?? 'GURU',
    status: json['status'],
    levelJabatan: json['level_jabatan'],
    catatanJabatan: json['catatan_jabatan'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'lembaga_id': lembagaId,
    'divisi_id': divisiId,
    'nama_jabatan': namaJabatan,
    'default_role': defaultRole,
    'status': status,
    'level_jabatan': levelJabatan,
    'catatan_jabatan': catatanJabatan,
  };
}