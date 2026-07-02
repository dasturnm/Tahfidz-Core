// Lokasi: lib/features/akademik/evaluasi/models/evaluasi_config_model.dart

class EvaluasiConfigModel {
  final double bobotItqon;
  final double bobotTajwid;
  final double bobotMakhraj;
  final double kkm; // Standar kelulusan
  final double pinaltiStt; // Pengurangan nilai jika Salah Tanpa Teguran
  final double pinaltiTeguran;
  final bool useGradingSystem;

  EvaluasiConfigModel({
    this.bobotItqon = 50.0,
    this.bobotTajwid = 25.0,
    this.bobotMakhraj = 25.0,
    this.kkm = 80.0,
    this.pinaltiStt = 2.0,
    this.pinaltiTeguran = 1.0,
    this.useGradingSystem = true,
  });

  factory EvaluasiConfigModel.fromJson(Map<String, dynamic> json) {
    return EvaluasiConfigModel(
      bobotItqon: (json['bobot_itqon'] as num?)?.toDouble() ?? 50.0,
      bobotTajwid: (json['bobot_tajwid'] as num?)?.toDouble() ?? 25.0,
      bobotMakhraj: (json['bobot_makhraj'] as num?)?.toDouble() ?? 25.0,
      kkm: (json['kkm'] as num?)?.toDouble() ?? 80.0,
      pinaltiStt: (json['pinalti_stt'] as num?)?.toDouble() ?? 2.0,
      pinaltiTeguran: (json['pinalti_teguran'] as num?)?.toDouble() ?? 1.0,
      useGradingSystem: json['use_grading_system'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bobot_itqon': bobotItqon,
      'bobot_tajwid': bobotTajwid,
      'bobot_makhraj': bobotMakhraj,
      'kkm': kkm,
      'pinalti_stt': pinaltiStt,
      'pinalti_teguran': pinaltiTeguran,
      'use_grading_system': useGradingSystem,
    };
  }

  EvaluasiConfigModel copyWith({
    double? bobotItqon,
    double? bobotTajwid,
    double? bobotMakhraj,
    double? kkm,
    double? pinaltiStt,
    double? pinaltiTeguran,
    bool? useGradingSystem,
  }) {
    return EvaluasiConfigModel(
      bobotItqon: bobotItqon ?? this.bobotItqon,
      bobotTajwid: bobotTajwid ?? this.bobotTajwid,
      bobotMakhraj: bobotMakhraj ?? this.bobotMakhraj,
      kkm: kkm ?? this.kkm,
      pinaltiStt: pinaltiStt ?? this.pinaltiStt,
      pinaltiTeguran: pinaltiTeguran ?? this.pinaltiTeguran,
      useGradingSystem: useGradingSystem ?? this.useGradingSystem,
    );
  }
}