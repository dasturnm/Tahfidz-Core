class TahunAjaranModel {
  final String id;
  final String lembagaId;
  final String labelTahun; // Contoh: 2023/2024
  final String semester; // Ganjil atau Genap
  final bool isAktif;
  final DateTime tanggalMulai;
  final DateTime tanggalSelesai;

  TahunAjaranModel({
    required this.id,
    required this.lembagaId,
    required this.labelTahun,
    required this.semester,
    this.isAktif = false,
    required this.tanggalMulai,
    required this.tanggalSelesai,
  });

  factory TahunAjaranModel.fromJson(Map<String, dynamic> json) => TahunAjaranModel(
    id: json['id'],
    lembagaId: json['lembaga_id'],
    labelTahun: json['label_tahun'] ?? '',
    semester: json['semester'] ?? 'Ganjil',
    isAktif: json['is_aktif'] ?? false,
    tanggalMulai: DateTime.parse(json['tanggal_mulai']),
    tanggalSelesai: DateTime.parse(json['tanggal_selesai']),
  );

  Map<String, dynamic> toJson() => {
    'lembaga_id': lembagaId,
    'label_tahun': labelTahun,
    'semester': semester,
    'is_aktif': isAktif,
    'tanggal_mulai': tanggalMulai.toIso8601String(),
    'tanggal_selesai': tanggalSelesai.toIso8601String(),
  };
}