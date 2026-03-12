class KurikulumModel {
  final String? id;
  final String lembagaId;
  final String namaKurikulum;
  final String? deskripsi;
  final String status;
  final bool isActive;
  final bool isLinear; // TAMBAHAN: Logika level tunggal
  final List<JenjangModel> jenjangs;

  KurikulumModel({
    this.id,
    required this.lembagaId,
    required this.namaKurikulum,
    this.deskripsi,
    this.status = 'aktif',
    this.isActive = true,
    this.isLinear = false, // TAMBAHAN
    this.jenjangs = const [],
  });

  // PERBAIKAN POIN 5: Getters Otomatis untuk Statistik
  int get totalLevels => jenjangs.fold(0, (sum, j) => sum + j.levels.length);

  int get totalModules {
    int count = 0;
    for (var j in jenjangs) {
      for (var l in j.levels) {
        count += l.modules.length;
      }
    }
    return count;
  }

  // PERBAIKAN: Nama disesuaikan menjadi totalTargets agar konsisten dengan ModulModel.targets
  int get totalTargets {
    int count = 0;
    for (var j in jenjangs) {
      for (var l in j.levels) {
        for (var m in l.modules) {
          count += m.targets.length;
        }
      }
    }
    return count;
  }

  factory KurikulumModel.fromJson(Map<String, dynamic> json) => KurikulumModel(
    id: json['id']?.toString(),
    lembagaId: json['lembaga_id']?.toString() ?? '',
    namaKurikulum: json['nama_kurikulum'] ?? '',
    deskripsi: json['deskripsi'],
    status: json['status'] ?? 'aktif',
    isActive: json['is_active'] ?? true,
    isLinear: json['is_linear'] ?? false, // TAMBAHAN: Mapping snake_case
    jenjangs: (json['jenjangs'] is List)
        ? (json['jenjangs'] as List)
        .whereType<Map<String, dynamic>>()
        .map((x) => JenjangModel.fromJson(x))
        .toList()
        : const [],
  );

  Map<String, dynamic> toJson() => {
    'lembaga_id': lembagaId,
    'nama_kurikulum': namaKurikulum,
    'deskripsi': deskripsi,
    'status': status,
    'is_active': isActive,
    'is_linear': isLinear, // TAMBAHAN: Mapping snake_case
    'jenjangs': List<dynamic>.from(jenjangs.map((x) => x.toJson())),
  };
}

class JenjangModel {
  final String? id;
  final String kurikulumId;
  final String namaJenjang;
  final String? deskripsi;
  final List<LevelModel> levels;

  JenjangModel({
    this.id,
    required this.kurikulumId,
    required this.namaJenjang,
    this.deskripsi,
    this.levels = const [],
  });

  factory JenjangModel.fromJson(Map<String, dynamic> json) => JenjangModel(
    id: json['id']?.toString(),
    kurikulumId: json['kurikulum_id']?.toString() ?? '',
    namaJenjang: json['nama_jenjang'] ?? '',
    deskripsi: json['deskripsi'],
    levels: (json['levels'] is List)
        ? (json['levels'] as List)
        .whereType<Map<String, dynamic>>()
        .map((x) => LevelModel.fromJson(x))
        .toList()
        : const [],
  );

  Map<String, dynamic> toJson() => {
    'kurikulum_id': kurikulumId,
    'nama_jenjang': namaJenjang,
    'deskripsi': deskripsi,
    'levels': List<dynamic>.from(levels.map((x) => x.toJson())),
  };
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
  final List<ModulModel> modules;

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
    this.modules = const [],
  });

  factory LevelModel.fromJson(Map<String, dynamic> json) => LevelModel(
    id: json['id']?.toString(),
    kurikulumId: json['kurikulum_id']?.toString() ?? '',
    jenjangId: json['jenjang_id']?.toString() ?? '',
    namaLevel: json['nama_level'] ?? '',
    targetTotal: (json['target_total'] ?? 0).toDouble(),
    metrik: json['metrik'] ?? 'Juz',
    urutan: json['urutan'] ?? 0,
    kelasId: (json['classes'] is List && (json['classes'] as List).isNotEmpty)
        ? json['classes'][0]['id']?.toString()
        : (json['classes'] is Map) ? json['classes']['id']?.toString() : null,
    namaKelas: (json['classes'] is List && (json['classes'] as List).isNotEmpty)
        ? json['classes'][0]['name']?.toString()
        : (json['classes'] is Map) ? json['classes']['name']?.toString() : null,
    modules: (json['modules'] is List)
        ? (json['modules'] as List)
        .whereType<Map<String, dynamic>>()
        .map((x) => ModulModel.fromJson(x))
        .toList()
        : const [],
  );

  Map<String, dynamic> MapToJson() => {
    'kurikulum_id': kurikulumId,
    'jenjang_id': jenjangId,
    'nama_level': namaLevel,
    'target_total': targetTotal,
    'metrik': metrik,
    'urutan': urutan,
    'modules': List<dynamic>.from(modules.map((x) => x.toJson())),
  };

  Map<String, dynamic> toJson() => MapToJson();
}

class ModulModel {
  final String? id;
  final String levelId;
  final String namaModul;
  final String tipe;
  final int durasiHari;
  final List<TargetMetrikModel> targets;

  ModulModel({
    this.id,
    required this.levelId,
    required this.namaModul,
    required this.tipe,
    this.durasiHari = 30,
    this.targets = const [],
  });

  factory ModulModel.fromJson(Map<String, dynamic> json) => ModulModel(
    id: json['id']?.toString(),
    levelId: json['level_id']?.toString() ?? '',
    namaModul: json['nama_modul'] ?? '',
    tipe: json['tipe'] ?? 'HAFALAN',
    durasiHari: json['durasi_hari'] ?? 30,
    targets: (json['targets'] is List)
        ? (json['targets'] as List)
        .whereType<Map<String, dynamic>>()
        .map((x) => TargetMetrikModel.fromJson(x))
        .toList()
        : const [],
  );

  Map<String, dynamic> toJson() => {
    'level_id': levelId,
    'nama_modul': namaModul,
    'tipe': tipe,
    'durasi_hari': durasiHari,
    'targets': List<dynamic>.from(targets.map((x) => x.toJson())),
  };
}

class TargetMetrikModel {
  final String? id;
  final String modulId;
  final String jenisMetrik;
  final String inputType;
  final List<String> options;
  final bool isPrimary;
  final bool hasTarget;
  final String satuan;
  final String mulai;
  final String akhir;
  final double kkm;
  final double weight;

  TargetMetrikModel({
    this.id,
    required this.modulId,
    required this.jenisMetrik,
    this.inputType = 'NUMBER',
    this.options = const [],
    this.isPrimary = false,
    this.hasTarget = false,
    required this.satuan,
    required this.mulai,
    required this.akhir,
    this.kkm = 80,
    this.weight = 0.0,
  });

  factory TargetMetrikModel.fromJson(Map<String, dynamic> json) => TargetMetrikModel(
    id: json['id']?.toString(),
    modulId: json['modul_id']?.toString() ?? '',
    jenisMetrik: json['jenis_metrik'] ?? 'JUZ',
    inputType: json['input_type'] ?? 'NUMBER',
    options: json['options'] != null ? List<String>.from(json['options']) : const [],
    isPrimary: json['is_primary'] ?? false,
    hasTarget: json['has_target'] ?? false,
    satuan: json['satuan'] ?? '',
    mulai: json['mulai'] ?? '',
    akhir: json['akhir'] ?? '',
    kkm: (json['kkm'] ?? 80).toDouble(),
    weight: (json['weight'] ?? 0.0).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'modul_id': modulId,
    'jenis_metrik': jenisMetrik,
    'input_type': inputType,
    'options': options,
    'is_primary': isPrimary,
    'has_target': hasTarget,
    'satuan': satuan,
    'mulai': mulai,
    'akhir': akhir,
    'kkm': kkm,
    'weight': weight,
  };
}