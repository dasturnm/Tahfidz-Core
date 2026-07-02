// COPY-SAFE: lib/features/akademik/kurikulum/models/evaluation_kriteria_model.dart
class EvaluationKriteria {
  final String id;
  final String aspek;
  final String indikator;
  final double nilai;

  EvaluationKriteria({
    required this.id,
    required this.aspek,
    required this.indikator,
    this.nilai = 0.0,
  });

  factory EvaluationKriteria.fromJson(Map<String, dynamic> json) {
    return EvaluationKriteria(
      id: json['id'] ?? '',
      aspek: json['aspek'] ?? '',
      indikator: json['indikator'] ?? '',
      nilai: (json['nilai'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'aspek': aspek,
      'indikator': indikator,
      'nilai': nilai,
    };
  }

  EvaluationKriteria copyWith({double? nilai}) {
    return EvaluationKriteria(
      id: id,
      aspek: aspek,
      indikator: indikator,
      nilai: nilai ?? this.nilai,
    );
  }
}