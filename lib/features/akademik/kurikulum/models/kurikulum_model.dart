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
    // FIX: Gunakan pengecekan string 'null' untuk UUID safety
    id: (json['id'] == null || json['id'].toString() == 'null') ? null : json['id'].toString(),
    lembagaId: json['lembaga_id']?.toString() ?? '',
    tahunAjaranId: json['tahun_ajaran_id']?.toString(), // Tambahan
    programId: json['program_id']?.toString(), // Tambahan
    namaKurikulum: json['nama_kurikulum']?.toString() ?? '',
    deskripsi: json['deskripsi']?.toString(),
    status: json['status']?.toString() ?? 'aktif',
    isActive: json['is_active'] == true,
    isLinear: json['is_linear'] == true, // TAMBAHAN: Mapping snake_case
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
    id: (json['id'] == null || json['id'].toString() == 'null') ? null : json['id'].toString(),
    kurikulumId: json['kurikulum_id']?.toString() ?? '',
    namaJenjang: json['nama_jenjang']?.toString() ?? '',
    deskripsi: json['deskripsi']?.toString(),
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
  final String? programId; // TAMBAHAN
  final String namaLevel;
  final double targetTotal;
  final String metrik;
  final int urutan;
  final List<ModulModel> modul; // PERBAIKAN: Buang 's'

  LevelModel({
    this.id,
    required this.kurikulumId,
    required this.jenjangId,
    this.programId, // TAMBAHAN
    required this.namaLevel,
    this.targetTotal = 0.0,
    this.metrik = 'Juz',
    required this.urutan,
    this.modul = const [], // PERBAIKAN: Buang 's'
  });

  factory LevelModel.fromJson(Map<String, dynamic> json) => LevelModel(
    id: (json['id'] == null || json['id'].toString() == 'null') ? null : json['id'].toString(),
    kurikulumId: json['kurikulum_id']?.toString() ?? '',
    jenjangId: json['jenjang_id']?.toString() ?? '',
    programId: json['program_id']?.toString(), // TAMBAHAN
    namaLevel: json['nama_level']?.toString() ?? '',
    targetTotal: (json['target_total'] as num?)?.toDouble() ?? 0.0,
    metrik: json['metrik']?.toString() ?? 'Juz',
    urutan: (json['urutan'] as num?)?.toInt() ?? 0,
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
    'program_id': programId, // TAMBAHAN
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
    String? programId, // TAMBAHAN
    String? namaLevel,
    double? targetTotal,
    String? metrik,
    int? urutan,
    List<ModulModel>? modul,
  }) {
    return LevelModel(
      id: id ?? this.id,
      kurikulumId: kurikulumId ?? this.kurikulumId,
      jenjangId: jenjangId ?? this.jenjangId,
      programId: programId ?? this.programId, // TAMBAHAN
      namaLevel: namaLevel ?? this.namaLevel,
      targetTotal: targetTotal ?? this.targetTotal,
      metrik: metrik ?? this.metrik,
      urutan: urutan ?? this.urutan,
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
  final double targetAmount; // Target per pertemuan (Contoh: 10 baris)
  final String? silabus;
  final List<SilabusItemModel> silabusContent;
  final bool isSystemGenerated;
  final String jenisMetrik;
  final String? mulaiKoordinat;
  final String? akhirKoordinat;
  final double kkm;
  // TAMBAHAN FINAL BLUEPRINT
  final String silabusSource; // 'mushaf' | 'internal'
  final bool isStrict; // 🛡️ Wajib Sesuai Target
  final bool isAllowBelowTarget; // 🔓 Toleransi Minimum
  final bool isAccumulated; // 📉 Akumulasi Hutang
  final bool isSingleBurden; // 🚫 Beban Tunggal (Tanpa Rapel)
  final int sabqiAmount; // Jumlah Murajaah Sabqi (Besaran)
  final String sabqiUnit; // TAMBAHAN: Satuan Sabqi
  final String manzilType; // 'fixed' | 'percentage'
  final double manzilAmount; // Angka atau % beban Manzil
  final String targetAmountUnit; // Satuan Pencapaian Harian (Poin 4)
  final bool isPlottingActive; // Toggle Plotting Materi (Poin 2)
  final bool showSabqiInMutabaah; // TAMBAHAN: Toggle visibilitas Sabqi Guru
  final bool showManzilInDashboard; // TAMBAHAN: Toggle checklist Manzil Siswa

  ModulModel({
    this.id,
    required this.levelId,
    required this.namaModul,
    required this.tipe,
    this.targetPertemuan = 30,
    this.targetAmount = 0.0,
    this.silabus,
    this.silabusContent = const [],
    this.isSystemGenerated = false,
    this.jenisMetrik = 'HALAMAN',
    this.mulaiKoordinat,
    this.akhirKoordinat,
    this.kkm = 80,
    // DEFAULTS FINAL BLUEPRINT
    this.silabusSource = 'mushaf',
    this.isStrict = false,
    this.isAllowBelowTarget = true,
    this.isAccumulated = false,
    this.isSingleBurden = true,
    this.sabqiAmount = 0,
    this.sabqiUnit = 'HALAMAN',
    this.manzilType = 'fixed',
    this.manzilAmount = 0.0,
    this.targetAmountUnit = 'HALAMAN',
    this.isPlottingActive = false,
    this.showSabqiInMutabaah = true,
    this.showManzilInDashboard = true,
  });

  factory ModulModel.fromJson(Map<String, dynamic> json) => ModulModel(
    id: (json['id'] == null || json['id'].toString() == 'null') ? null : json['id'].toString(),
    levelId: json['level_id']?.toString() ?? '',
    namaModul: json['nama_modul']?.toString() ?? '',
    tipe: json['tipe']?.toString() ?? 'HAFALAN',
    targetPertemuan: (json['target_pertemuan'] as num?)?.toInt() ?? 30,
    targetAmount: (json['target_amount'] as num?)?.toDouble() ?? 0.0,
    silabus: json['silabus']?.toString(),
    silabusContent: (json['silabus_content'] is List)
        ? (json['silabus_content'] as List)
        .whereType<Map<String, dynamic>>()
        .map((x) => SilabusItemModel.fromJson(x))
        .toList()
        : const [],
    isSystemGenerated: json['is_system_generated'] == true,
    jenisMetrik: json['jenis_metrik']?.toString() ?? 'HALAMAN',
    mulaiKoordinat: json['mulai_koordinat']?.toString(),
    akhirKoordinat: json['akhir_koordinat']?.toString(),
    kkm: (json['kkm'] as num?)?.toDouble() ?? 80.0,
    // MAPPING FINAL BLUEPRINT
    silabusSource: json['silabus_source']?.toString() ?? 'mushaf',
    isStrict: json['is_strict'] == true,
    isAllowBelowTarget: json['is_allow_below_target'] ?? true,
    isAccumulated: json['is_accumulated'] == true,
    isSingleBurden: json['is_single_burden'] ?? true,
    sabqiAmount: (json['sabqi_amount'] as num?)?.toInt() ?? 0,
    sabqiUnit: json['sabqi_unit']?.toString() ?? 'HALAMAN',
    manzilType: json['manzil_type']?.toString() ?? 'fixed',
    manzilAmount: (json['manzil_amount'] as num?)?.toDouble() ?? 0.0,
    targetAmountUnit: json['target_amount_unit']?.toString() ?? 'HALAMAN',
    isPlottingActive: json['is_plotting_active'] == true,
    showSabqiInMutabaah: json['show_sabqi_in_mutabaah'] ?? true,
    showManzilInDashboard: json['show_manzil_in_dashboard'] ?? true,
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'level_id': levelId,
    'nama_modul': namaModul,
    'tipe': tipe,
    'target_pertemuan': targetPertemuan,
    'target_amount': targetAmount,
    'silabus': silabus,
    'silabus_content': List<dynamic>.from(silabusContent.map((x) => x.toJson())),
    'is_system_generated': isSystemGenerated,
    'jenis_metrik': jenisMetrik,
    'mulai_koordinat': mulaiKoordinat,
    'akhir_koordinat': akhirKoordinat,
    'kkm': kkm,
    // JSON FINAL BLUEPRINT
    'silabus_source': silabusSource,
    'is_strict': isStrict,
    'is_allow_below_target': isAllowBelowTarget,
    'is_accumulated': isAccumulated,
    'is_single_burden': isSingleBurden,
    'sabqi_amount': sabqiAmount,
    'sabqi_unit': sabqiUnit,
    'manzil_type': manzilType,
    'manzil_amount': manzilAmount,
    'target_amount_unit': targetAmountUnit,
    'is_plotting_active': isPlottingActive,
    'show_sabqi_in_mutabaah': showSabqiInMutabaah,
    'show_manzil_in_dashboard': showManzilInDashboard,
  };

  ModulModel copyWith({
    String? id,
    String? levelId,
    String? namaModul,
    String? tipe,
    int? targetPertemuan,
    double? targetAmount,
    String? silabus,
    List<SilabusItemModel>? silabusContent,
    bool? isSystemGenerated,
    String? jenisMetrik,
    String? mulaiKoordinat,
    String? akhirKoordinat,
    double? kkm,
    String? silabusSource,
    bool? isStrict,
    bool? isAllowBelowTarget,
    bool? isAccumulated,
    bool? isSingleBurden,
    int? sabqiAmount,
    String? sabqiUnit,
    String? manzilType,
    double? manzilAmount,
    String? targetAmountUnit,
    bool? isPlottingActive,
    bool? showSabqiInMutabaah,
    bool? showManzilInDashboard,
  }) {
    return ModulModel(
      id: id ?? this.id,
      levelId: levelId ?? this.levelId,
      namaModul: namaModul ?? this.namaModul,
      tipe: tipe ?? this.tipe,
      targetPertemuan: targetPertemuan ?? this.targetPertemuan,
      targetAmount: targetAmount ?? this.targetAmount,
      silabus: silabus ?? this.silabus,
      silabusContent: silabusContent ?? this.silabusContent,
      isSystemGenerated: isSystemGenerated ?? this.isSystemGenerated,
      jenisMetrik: jenisMetrik ?? this.jenisMetrik,
      mulaiKoordinat: mulaiKoordinat ?? this.mulaiKoordinat,
      akhirKoordinat: akhirKoordinat ?? this.akhirKoordinat,
      kkm: kkm ?? this.kkm,
      silabusSource: silabusSource ?? this.silabusSource,
      isStrict: isStrict ?? this.isStrict,
      isAllowBelowTarget: isAllowBelowTarget ?? this.isAllowBelowTarget,
      isAccumulated: isAccumulated ?? this.isAccumulated,
      isSingleBurden: isSingleBurden ?? this.isSingleBurden,
      sabqiAmount: sabqiAmount ?? this.sabqiAmount,
      sabqiUnit: sabqiUnit ?? this.sabqiUnit,
      manzilType: manzilType ?? this.manzilType,
      manzilAmount: manzilAmount ?? this.manzilAmount,
      targetAmountUnit: targetAmountUnit ?? this.targetAmountUnit,
      isPlottingActive: isPlottingActive ?? this.isPlottingActive,
      showSabqiInMutabaah: showSabqiInMutabaah ?? this.showSabqiInMutabaah,
      showManzilInDashboard: showManzilInDashboard ?? this.showManzilInDashboard,
    );
  }
}

class SilabusItemModel {
  final int pertemuan;
  final String materi;
  final String? keterangan;

  SilabusItemModel({
    required this.pertemuan,
    required this.materi,
    this.keterangan,
  });

  factory SilabusItemModel.fromJson(Map<String, dynamic> json) => SilabusItemModel(
    pertemuan: (json['pertemuan'] as num?)?.toInt() ?? 0,
    materi: json['materi']?.toString() ?? '',
    keterangan: json['keterangan']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'pertemuan': pertemuan,
    'materi': materi,
    'keterangan': keterangan,
  };
}