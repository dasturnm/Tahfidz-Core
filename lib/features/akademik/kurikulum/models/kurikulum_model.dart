// Lokasi: lib/features/akademik/kurikulum/models/kurikulum_model.dart

class KurikulumModel {
  final String? id;
  final String lembagaId;
  final String? tahunAjaranId; // Tambahan sesuai DB
  final String? programId; // Tambahan sesuai DB
  final String namaKurikulum;
  final String? deskripsi;
  final String status;
  final bool isActive;
  final bool isLinear; // TAMBAHAN: Logika level tunggal
  final List<JenjangModel> jenjang; // PERBAIKAN: Buang 's'

  KurikulumModel({
    this.id,
    required this.lembagaId,
    this.tahunAjaranId, // Tambahan
    this.programId, // Tambahan
    required this.namaKurikulum,
    this.deskripsi,
    this.status = 'aktif',
    this.isActive = true,
    this.isLinear = false, // TAMBAHAN
    this.jenjang = const [], // PERBAIKAN: Buang 's'
  });

  // PERBAIKAN POIN 5: Getters Otomatis untuk Statistik
  int get totalLevel => jenjang.fold(0, (sum, j) => sum + j.level.length);

  int get totalModul { // PERBAIKAN: Buang 's'
    int count = 0;
    for (var j in jenjang) {
      for (var l in j.level) {
        count += l.modul.length;
      }
    }
    return count;
  }

  // PERBAIKAN: Nama disesuaikan menjadi totalTarget agar konsisten dengan ModulModel.target
  int get totalTarget {
    int count = 0;
    for (var j in jenjang) {
      for (var l in j.level) {
        count += l.modul.length; // 1 Modul = 1 Target
      }
    }
    return count;
  }

  factory KurikulumModel.fromJson(Map<String, dynamic> json) => KurikulumModel(
    id: json['id']?.toString(),
    lembagaId: json['lembaga_id']?.toString() ?? '',
    tahunAjaranId: json['tahun_ajaran_id']?.toString(), // Tambahan
    programId: json['program_id']?.toString(), // Tambahan
    namaKurikulum: json['nama_kurikulum'] ?? '',
    deskripsi: json['deskripsi'],
    status: json['status'] ?? 'aktif',
    isActive: json['is_active'] ?? true,
    isLinear: json['is_linear'] ?? false, // TAMBAHAN: Mapping snake_case
    jenjang: (json['jenjang'] is List) // PERBAIKAN: Buang 's'
        ? (json['jenjang'] as List)
        .whereType<Map<String, dynamic>>()
        .map((x) => JenjangModel.fromJson(x))
        .toList()
        : const [],
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id, // FIX: Sertakan ID untuk sinkronisasi UUID
    'lembaga_id': lembagaId,
    'tahun_ajaran_id': tahunAjaranId, // Tambahan
    'program_id': programId, // Tambahan
    'nama_kurikulum': namaKurikulum,
    'deskripsi': deskripsi,
    'status': status,
    'is_active': isActive,
    'is_linear': isLinear, // TAMBAHAN: Mapping snake_case
    'jenjang': List<dynamic>.from(jenjang.map((x) => x.toJson())), // PERBAIKAN: Buang 's'
  };

  KurikulumModel copyWith({
    String? id,
    String? lembagaId,
    String? tahunAjaranId,
    String? programId,
    String? namaKurikulum,
    String? deskripsi,
    String? status,
    bool? isActive,
    bool? isLinear,
    List<JenjangModel>? jenjang,
  }) {
    return KurikulumModel(
      id: id ?? this.id,
      lembagaId: lembagaId ?? this.lembagaId,
      tahunAjaranId: tahunAjaranId ?? this.tahunAjaranId,
      programId: programId ?? this.programId,
      namaKurikulum: namaKurikulum ?? this.namaKurikulum,
      deskripsi: deskripsi ?? this.deskripsi,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      isLinear: isLinear ?? this.isLinear,
      jenjang: jenjang ?? this.jenjang,
    );
  }
}

class JenjangModel {
  final String? id;
  final String kurikulumId;
  final String namaJenjang;
  final String? deskripsi;
  final List<LevelModel> level;

  JenjangModel({
    this.id,
    required this.kurikulumId,
    required this.namaJenjang,
    this.deskripsi,
    this.level = const [],
  });

  factory JenjangModel.fromJson(Map<String, dynamic> json) => JenjangModel(
    id: json['id']?.toString(),
    kurikulumId: json['kurikulum_id']?.toString() ?? '',
    namaJenjang: json['nama_jenjang'] ?? '',
    deskripsi: json['deskripsi'],
    level: (json['level'] is List)
        ? (json['level'] as List)
        .whereType<Map<String, dynamic>>()
        .map((x) => LevelModel.fromJson(x))
        .toList()
        : const [],
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id, // FIX: Sertakan ID untuk sinkronisasi UUID
    'kurikulum_id': kurikulumId,
    'nama_jenjang': namaJenjang,
    'deskripsi': deskripsi,
    'level': List<dynamic>.from(level.map((x) => x.toJson())),
  };

  JenjangModel copyWith({
    String? id,
    String? kurikulumId,
    String? namaJenjang,
    String? deskripsi,
    List<LevelModel>? level,
  }) {
    return JenjangModel(
      id: id ?? this.id,
      kurikulumId: kurikulumId ?? this.kurikulumId,
      namaJenjang: namaJenjang ?? this.namaJenjang,
      deskripsi: deskripsi ?? this.deskripsi,
      level: level ?? this.level,
    );
  }
}

class LevelModel {
  final String? id;
  final String kurikulumId;
  final String jenjangId;
  final String namaLevel;
  final double targetTotal;
  final String metrik;
  final int urutan;
  final String? kelasId;
  final String? namaKelas;
  final List<ModulModel> modul; // PERBAIKAN: Buang 's'

  LevelModel({
    this.id,
    required this.kurikulumId,
    required this.jenjangId,
    required this.namaLevel,
    this.targetTotal = 0.0,
    this.metrik = 'Juz',
    required this.urutan,
    this.kelasId,
    this.namaKelas,
    this.modul = const [], // PERBAIKAN: Buang 's'
  });

  factory LevelModel.fromJson(Map<String, dynamic> json) => LevelModel(
    id: json['id']?.toString(),
    kurikulumId: json['kurikulum_id']?.toString() ?? '',
    jenjangId: json['jenjang_id']?.toString() ?? '',
    namaLevel: json['nama_level'] ?? '',
    targetTotal: (json['target_total'] ?? 0).toDouble(),
    metrik: json['metrik'] ?? 'Juz',
    urutan: json['urutan'] ?? 0,
    // FIX: Sinkronisasi dengan key 'kelas' atau 'classes'
    kelasId: (json['kelas'] != null)
        ? (json['kelas'] is List && (json['kelas'] as List).isNotEmpty ? json['kelas'][0]['id']?.toString() : json['kelas']['id']?.toString())
        : (json['classes'] != null)
        ? (json['classes'] is List && (json['classes'] as List).isNotEmpty ? json['classes'][0]['id']?.toString() : json['classes']['id']?.toString())
        : null,
    namaKelas: (json['kelas'] != null)
        ? (json['kelas'] is List && (json['kelas'] as List).isNotEmpty ? json['kelas'][0]['name']?.toString() : json['kelas']['name']?.toString())
        : (json['classes'] != null)
        ? (json['classes'] is List && (json['classes'] as List).isNotEmpty ? json['classes'][0]['name']?.toString() : json['classes']['name']?.toString())
        : null,
    modul: (json['modul'] is List) // PERBAIKAN: Buang 's'
        ? (json['modul'] as List)
        .whereType<Map<String, dynamic>>()
        .map((x) => ModulModel.fromJson(x))
        .toList()
        : const [],
  );

  Map<String, dynamic> mapToJson() => { // PERBAIKAN: lowerCamelCase
    if (id != null) 'id': id, // FIX: Sertakan ID untuk sinkronisasi UUID
    'kurikulum_id': kurikulumId,
    'jenjang_id': jenjangId,
    'nama_level': namaLevel,
    'target_total': targetTotal,
    'metrik': metrik,
    'urutan': urutan,
    'modul': List<dynamic>.from(modul.map((x) => x.toJson())), // PERBAIKAN: Buang 's'
  };

  Map<String, dynamic> toJson() => mapToJson();

  LevelModel copyWith({
    String? id,
    String? kurikulumId,
    String? jenjangId,
    String? namaLevel,
    double? targetTotal,
    String? metrik,
    int? urutan,
    String? kelasId,
    String? namaKelas,
    List<ModulModel>? modul,
  }) {
    return LevelModel(
      id: id ?? this.id,
      kurikulumId: kurikulumId ?? this.kurikulumId,
      jenjangId: jenjangId ?? this.jenjangId,
      namaLevel: namaLevel ?? this.namaLevel,
      targetTotal: targetTotal ?? this.targetTotal,
      metrik: metrik ?? this.metrik,
      urutan: urutan ?? this.urutan,
      kelasId: kelasId ?? this.kelasId,
      namaKelas: namaKelas ?? this.namaKelas,
      modul: modul ?? this.modul,
    );
  }
}

class ModulModel {
  final String? id;
  final String levelId;
  final String namaModul;
  final String tipe;
  final int targetPertemuan;
  final String? silabus;
  final bool isSystemGenerated;
  final String jenisMetrik;
  final String? mulaiKoordinat;
  final String? akhirKoordinat;
  final double kkm;

  ModulModel({
    this.id,
    required this.levelId,
    required this.namaModul,
    required this.tipe,
    this.targetPertemuan = 30,
    this.silabus,
    this.isSystemGenerated = false,
    this.jenisMetrik = 'HALAMAN',
    this.mulaiKoordinat,
    this.akhirKoordinat,
    this.kkm = 80,
  });

  factory ModulModel.fromJson(Map<String, dynamic> json) => ModulModel(
    id: json['id']?.toString(),
    levelId: json['level_id']?.toString() ?? '',
    namaModul: json['nama_modul'] ?? '',
    tipe: json['tipe'] ?? 'HAFALAN',
    targetPertemuan: json['target_pertemuan'] ?? 30,
    silabus: json['silabus'],
    isSystemGenerated: json['is_system_generated'] ?? false,
    jenisMetrik: json['jenis_metrik'] ?? 'HALAMAN',
    mulaiKoordinat: json['mulai_koordinat'],
    akhirKoordinat: json['akhir_koordinat'],
    kkm: (json['kkm'] ?? 80).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'level_id': levelId,
    'nama_modul': namaModul,
    'tipe': tipe,
    'target_pertemuan': targetPertemuan,
    'silabus': silabus,
    'is_system_generated': isSystemGenerated,
    'jenis_metrik': jenisMetrik,
    'mulai_koordinat': mulaiKoordinat,
    'akhir_koordinat': akhirKoordinat,
    'kkm': kkm,
  };

  ModulModel copyWith({
    String? id,
    String? levelId,
    String? namaModul,
    String? tipe,
    int? targetPertemuan,
    String? silabus,
    bool? isSystemGenerated,
    String? jenisMetrik,
    String? mulaiKoordinat,
    String? akhirKoordinat,
    double? kkm,
  }) {
    return ModulModel(
      id: id ?? this.id,
      levelId: levelId ?? this.levelId,
      namaModul: namaModul ?? this.namaModul,
      tipe: tipe ?? this.tipe,
      targetPertemuan: targetPertemuan ?? this.targetPertemuan,
      silabus: silabus ?? this.silabus,
      isSystemGenerated: isSystemGenerated ?? this.isSystemGenerated,
      jenisMetrik: jenisMetrik ?? this.jenisMetrik,
      mulaiKoordinat: mulaiKoordinat ?? this.mulaiKoordinat,
      akhirKoordinat: akhirKoordinat ?? this.akhirKoordinat,
      kkm: kkm ?? this.kkm,
    );
  }
}