// Lokasi: lib/features/akademik/kurikulum/models/kurikulum_model.dart

// FIX: Import file modul yang baru dipisah
import 'modul_model.dart';
// FIX: Export agar file lain yang import kurikulum_model tidak error
export 'modul_model.dart';

// =============================================================================
// FILE: kurikulum_model.dart
// Berisi hierarki inti Kurikulum: Kurikulum -> Jenjang -> Level
// =============================================================================

// -----------------------------------------------------------------------------
// 1. KURIKULUM MODEL (Main Tenant Entity)
// -----------------------------------------------------------------------------
class KurikulumModel {
  final String? id;
  final String lembagaId;
  final String? tahunAjaranId; // Tambahan sesuai DB
  final String? programId; // Tambahan sesuai DB
  final String namaKurikulum;
  final String? deskripsi;
  final String status;
  final bool isActive;
  final bool isLinear;
  final String promotionPolicy; // TAMBAHAN: Tipe A (flexible) / B (strict)
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
    this.promotionPolicy = 'flexible', // TAMBAHAN
    this.jenjang = const [], // PERBAIKAN: Buang 's'
  });

  // Getters Otomatis untuk Statistik
  int get totalLevel => jenjang.fold(0, (sum, j) => sum + j.level.length);

  int get totalModul {
    int count = 0;
    for (var j in jenjang) {
      for (var l in j.level) {
        count += l.modul.length;
      }
    }
    return count;
  }

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
    id: (json['id'] == null || json['id'].toString() == 'null') ? null : json['id'].toString(),
    lembagaId: json['lembaga_id']?.toString() ?? '',
    tahunAjaranId: json['tahun_ajaran_id']?.toString(),
    programId: json['program_id']?.toString(),
    namaKurikulum: json['nama_kurikulum']?.toString() ?? '',
    deskripsi: json['deskripsi']?.toString(),
    status: json['status']?.toString() ?? 'aktif',
    isActive: json['is_active'] == true,
    isLinear: json['is_linear'] == true,
    promotionPolicy: json['promotion_policy']?.toString() ?? 'flexible',
    jenjang: (json['jenjang'] is List)
        ? (json['jenjang'] as List)
        .whereType<Map<String, dynamic>>()
        .map((x) => JenjangModel.fromJson(x))
        .toList()
        : const [],
  );

  Map<String, dynamic> toJson() => {
    if (id != null && id!.isNotEmpty) 'id': id,
    'lembaga_id': lembagaId,
    'tahun_ajaran_id': tahunAjaranId,
    'program_id': programId,
    'nama_kurikulum': namaKurikulum,
    'deskripsi': deskripsi,
    'status': status,
    'is_active': isActive,
    'is_linear': isLinear,
    'promotion_policy': promotionPolicy,
    'jenjang': List<dynamic>.from(jenjang.map((x) => x.toJson())),
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
    String? promotionPolicy,
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
      promotionPolicy: promotionPolicy ?? this.promotionPolicy,
      jenjang: jenjang ?? this.jenjang,
    );
  }
}

// -----------------------------------------------------------------------------
// 2. JENJANG MODEL (Level 1 Hierarchy)
// -----------------------------------------------------------------------------
class JenjangModel {
  final String? id;
  final String kurikulumId;
  final String namaJenjang;
  final String? deskripsi;
  final int urutan; // TAMBAHAN: Koordinat urutan jenjang
  final List<LevelModel> level;

  JenjangModel({
    this.id,
    required this.kurikulumId,
    required this.namaJenjang,
    this.deskripsi,
    this.urutan = 0, // TAMBAHAN
    this.level = const [],
  });

  factory JenjangModel.fromJson(Map<String, dynamic> json) => JenjangModel(
    id: (json['id'] == null || json['id'].toString() == 'null') ? null : json['id'].toString(),
    kurikulumId: json['kurikulum_id']?.toString() ?? '',
    namaJenjang: json['nama_jenjang']?.toString() ?? '',
    deskripsi: json['deskripsi']?.toString(),
    urutan: (json['urutan'] as num?)?.toInt() ?? 0, // TAMBAHAN
    level: (json['level'] is List)
        ? (json['level'] as List)
        .whereType<Map<String, dynamic>>()
        .map((x) => LevelModel.fromJson(x))
        .toList()
        : const [],
  );

  Map<String, dynamic> toJson() => {
    if (id != null && id!.isNotEmpty) 'id': id,
    'kurikulum_id': kurikulumId,
    'nama_jenjang': namaJenjang,
    'deskripsi': deskripsi,
    'urutan': urutan, // TAMBAHAN
    'level': List<dynamic>.from(level.map((x) => x.toJson())),
  };

  JenjangModel copyWith({
    String? id,
    String? kurikulumId,
    String? namaJenjang,
    String? deskripsi,
    int? urutan, // TAMBAHAN
    List<LevelModel>? level,
  }) {
    return JenjangModel(
      id: id ?? this.id,
      kurikulumId: kurikulumId ?? this.kurikulumId,
      namaJenjang: namaJenjang ?? this.namaJenjang,
      deskripsi: deskripsi ?? this.deskripsi,
      urutan: urutan ?? this.urutan, // TAMBAHAN
      level: level ?? this.level,
    );
  }
}

// -----------------------------------------------------------------------------
// 3. LEVEL MODEL (Level 2 Hierarchy)
// -----------------------------------------------------------------------------
class LevelModel {
  final String? id;
  final String kurikulumId;
  final String jenjangId;
  final String? programId; // TAMBAHAN
  final String namaLevel;
  final int urutan;
  final List<ModulModel> modul;
  final bool isExamRequired; // TAMBAHAN: Logika Kenaikan Level
  final LevelExamConfig? examConfig; // TAMBAHAN: Detail Konfigurasi Ujian

  LevelModel({
    this.id,
    required this.kurikulumId,
    required this.jenjangId,
    this.programId,
    required this.namaLevel,
    required this.urutan,
    this.modul = const [],
    this.isExamRequired = false, // TAMBAHAN
    this.examConfig, // TAMBAHAN
  });

  factory LevelModel.fromJson(Map<String, dynamic> json) => LevelModel(
    id: (json['id'] == null || json['id'].toString() == 'null') ? null : json['id'].toString(),
    kurikulumId: json['kurikulum_id']?.toString() ?? '',
    jenjangId: json['jenjang_id']?.toString() ?? '',
    programId: json['program_id']?.toString(),
    namaLevel: json['nama_level']?.toString() ?? '',
    urutan: (json['urutan'] as num?)?.toInt() ?? 0,
    isExamRequired: json['is_exam_required'] == true, // TAMBAHAN
    examConfig: json['exam_config'] != null
        ? LevelExamConfig.fromJson(json['exam_config'])
        : null, // TAMBAHAN
    modul: (json['modul'] is List)
        ? (json['modul'] as List)
        .whereType<Map<String, dynamic>>()
        .map((x) => ModulModel.fromJson(x))
        .toList()
        : const [],
  );

  Map<String, dynamic> mapToJson() => {
    if (id != null && id!.isNotEmpty) 'id': id,
    'kurikulum_id': kurikulumId,
    'jenjang_id': jenjangId,
    'program_id': programId,
    'nama_level': namaLevel,
    'urutan': urutan,
    'is_exam_required': isExamRequired,
    if (examConfig != null) 'exam_config': examConfig?.toJson(),
  };

  Map<String, dynamic> toJson() => mapToJson();

  LevelModel copyWith({
    String? id,
    String? kurikulumId,
    String? jenjangId,
    String? programId,
    String? namaLevel,
    int? urutan,
    List<ModulModel>? modul,
    bool? isExamRequired,
    LevelExamConfig? examConfig,
  }) {
    return LevelModel(
      id: id ?? this.id,
      kurikulumId: kurikulumId ?? this.kurikulumId,
      jenjangId: jenjangId ?? this.jenjangId,
      programId: programId ?? this.programId,
      namaLevel: namaLevel ?? this.namaLevel,
      urutan: urutan ?? this.urutan,
      modul: modul ?? this.modul,
      isExamRequired: isExamRequired ?? this.isExamRequired,
      examConfig: examConfig ?? this.examConfig,
    );
  }
}

// -----------------------------------------------------------------------------
// 4. LEVEL EXAM CONFIG
// -----------------------------------------------------------------------------
class LevelExamConfig {
  final String type; // 'tasmi' | 'checklist'
  final double volume;
  final String unit; // 'JUZ' | 'HALAMAN' | 'MATERI'
  final bool isCumulative;
  final int cumulativeRange;
  final String direction; // 'forward' | 'backward'

  LevelExamConfig({
    this.type = 'tasmi',
    this.volume = 1.0,
    this.unit = 'JUZ',
    this.isCumulative = false,
    this.cumulativeRange = 5,
    this.direction = 'forward',
  });

  factory LevelExamConfig.fromJson(Map<String, dynamic> json) => LevelExamConfig(
    type: json['type']?.toString() ?? 'tasmi',
    volume: (json['volume'] as num?)?.toDouble() ?? 1.0,
    unit: json['unit']?.toString() ?? 'JUZ',
    isCumulative: json['is_cumulative'] == true,
    cumulativeRange: (json['cumulative_range'] as num?)?.toInt() ?? 5,
    direction: json['direction']?.toString() ?? 'forward',
  );

  Map<String, dynamic> toJson() => {
    'type': type,
    'volume': volume,
    'unit': unit,
    'is_cumulative': isCumulative,
    'cumulative_range': cumulativeRange,
    'direction': direction,
  };

  LevelExamConfig copyWith({
    String? type,
    double? volume,
    String? unit,
    bool? isCumulative,
    int? cumulativeRange,
    String? direction,
  }) {
    return LevelExamConfig(
      type: type ?? this.type,
      volume: volume ?? this.volume,
      unit: unit ?? this.unit,
      isCumulative: isCumulative ?? this.isCumulative,
      cumulativeRange: cumulativeRange ?? this.cumulativeRange,
      direction: direction ?? this.direction,
    );
  }
}