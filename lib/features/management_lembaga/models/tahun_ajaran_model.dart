class TahunAjaranModel {
  final String id;
  final String lembagaId;
  final String labelTahun; // Contoh: 2023/2024
  final String semester; // Ganjil atau Genap
  final bool isAktif;

  TahunAjaranModel({
    required this.id,
    required this.lembagaId,
    required this.labelTahun,
    required this.semester,
    this.isAktif = false,
  });

  factory TahunAjaranModel.fromJson(Map<String, dynamic> json) => TahunAjaranModel(
    id: json['id'],
    lembagaId: json['lembaga_id'],
    labelTahun: json['label_tahun'] ?? '',
    semester: json['semester'] ?? 'Ganjil',
    isAktif: json['is_aktif'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'lembaga_id': lembagaId,
    'label_tahun': labelTahun,
    'semester': semester,
    'is_aktif': isAktif,
  };
}