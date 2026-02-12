class KurikulumModel {
  final String? id;
  final String programId;
  final String lembagaId; // Penambahan lembagaId
  final String namaKurikulum;
  final String? deskripsi; // Penambahan deskripsi
  final String status; // Penambahan status untuk sinkronisasi screen
  final bool isActive;
  final List<JenjangModel> jenjangs;

  KurikulumModel({
    this.id,
    required this.programId,
    required this.lembagaId,
    required this.namaKurikulum,
    this.deskripsi,
    this.status = 'aktif',
    this.isActive = true,
    this.jenjangs = const [],
  });

  factory KurikulumModel.fromJson(Map<String, dynamic> json) => KurikulumModel(
    id: json['id'],
    programId: json['program_id'] ?? '',
    lembagaId: json['lembaga_id'] ?? '',
    namaKurikulum: json['nama_kurikulum'] ?? '',
    deskripsi: json['deskripsi'],
    status: json['status'] ?? 'aktif',
    isActive: json['is_active'] ?? true,
    jenjangs: json['jenjangs'] != null
        ? List<JenjangModel>.from(json['jenjangs'].map((x) => JenjangModel.fromJson(x)))
        : const [],
  );

  Map<String, dynamic> toJson() => {
    'program_id': programId,
    'lembaga_id': lembagaId,
    'nama_kurikulum': namaKurikulum,
    'deskripsi': deskripsi,
    'status': status,
    'is_active': isActive,
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
    id: json['id'],
    kurikulumId: json['kurikulum_id'] ?? '',
    namaJenjang: json['nama_jenjang'] ?? '',
    deskripsi: json['deskripsi'],
    levels: json['levels'] != null
        ? List<LevelModel>.from(json['levels'].map((x) => LevelModel.fromJson(x)))
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
  final String jenjangId; // Berubah dari kurikulumId ke jenjangId sesuai hierarki
  final String namaLevel;
  final int urutan;
  final List<ModulModel> modules;

  LevelModel({
    this.id,
    required this.jenjangId,
    required this.namaLevel,
    required this.urutan,
    this.modules = const [],
  });

  factory LevelModel.fromJson(Map<String, dynamic> json) => LevelModel(
    id: json['id'],
    jenjangId: json['jenjang_id'] ?? '',
    namaLevel: json['nama_level'] ?? '',
    urutan: json['urutan'] ?? 0,
    modules: json['modules'] != null
        ? List<ModulModel>.from(json['modules'].map((x) => ModulModel.fromJson(x)))
        : const [],
  );

  Map<String, dynamic> toJson() => {
    'jenjang_id': jenjangId,
    'nama_level': namaLevel,
    'urutan': urutan,
    'modules': List<dynamic>.from(modules.map((x) => x.toJson())),
  };
}

class ModulModel {
  final String? id;
  final String levelId;
  final String namaModul;
  final String tipe; // HAFALAN, TAHSIN, TEORI, UJIAN
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
    id: json['id'],
    levelId: json['level_id'] ?? '',
    namaModul: json['nama_modul'] ?? '',
    tipe: json['tipe'] ?? 'HAFALAN',
    durasiHari: json['durasi_hari'] ?? 30,
    targets: json['targets'] != null
        ? List<TargetMetrikModel>.from(json['targets'].map((x) => TargetMetrikModel.fromJson(x)))
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
  final String jenisMetrik; // JUZ, HALAMAN, AYAT, SURAH
  final String satuan;
  final String mulai;
  final String akhir;
  final double kkm;

  TargetMetrikModel({
    this.id,
    required this.modulId,
    required this.jenisMetrik,
    required this.satuan,
    required this.mulai,
    required this.akhir,
    this.kkm = 80,
  });

  factory TargetMetrikModel.fromJson(Map<String, dynamic> json) => TargetMetrikModel(
    id: json['id'],
    modulId: json['modul_id'] ?? '',
    jenisMetrik: json['jenis_metrik'] ?? 'JUZ',
    satuan: json['satuan'] ?? '',
    mulai: json['mulai'] ?? '',
    akhir: json['akhir'] ?? '',
    kkm: (json['kkm'] ?? 80).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'modul_id': modulId,
    'jenis_metrik': jenisMetrik,
    'satuan': satuan,
    'mulai': mulai,
    'akhir': akhir,
    'kkm': kkm,
  };
}