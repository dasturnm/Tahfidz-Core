// Lokasi: lib/features/akademik/evaluasi/models/evaluasi_record_model.dart

class EvaluasiRecordModel {
  final String? id;
  final String lembagaId;
  final String siswaId;
  final String guruId;
  final String modulId;
  final String tipeEvaluasi; // Contoh: 'TASMI', 'UKL'
  final double nilaiAkhir;
  final bool isLulus;
  final DateTime? tanggalEvaluasi;
  final String? catatan;

  // Untuk menyimpan detail dinamis seperti jumlah pinalti STT, skor Itqon, dsb
  final Map<String, dynamic> detailPenilaian;

  // Field Relasi (Opsional untuk tampilan UI)
  final String? namaSiswa;
  final String? namaGuru;
  final String? namaModul;

  EvaluasiRecordModel({
    this.id,
    required this.lembagaId,
    required this.siswaId,
    required this.guruId,
    required this.modulId,
    required this.tipeEvaluasi,
    required this.nilaiAkhir,
    required this.isLulus,
    this.tanggalEvaluasi,
    this.catatan,
    this.detailPenilaian = const {},
    this.namaSiswa,
    this.namaGuru,
    this.namaModul,
  });

  factory EvaluasiRecordModel.fromJson(Map<String, dynamic> json) {
    return EvaluasiRecordModel(
      id: json['id']?.toString(),
      lembagaId: json['lembaga_id']?.toString() ?? '',
      siswaId: json['siswa_id']?.toString() ?? '',
      guruId: json['guru_id']?.toString() ?? '',
      modulId: json['modul_id']?.toString() ?? '',
      tipeEvaluasi: json['tipe_evaluasi']?.toString() ?? 'TASMI',
      // Explicit Casting sesuai AGENTS.md
      nilaiAkhir: (json['nilai_akhir'] as num?)?.toDouble() ?? 0.0,
      isLulus: json['is_lulus'] == true, // Boolean mapping
      // Safe Date Parsing
      tanggalEvaluasi: json['tanggal_evaluasi'] != null
          ? DateTime.tryParse(json['tanggal_evaluasi'].toString())
          : null,
      catatan: json['catatan']?.toString(),
      detailPenilaian: json['detail_penilaian'] as Map<String, dynamic>? ?? {},

      // Relasi (jika di-join dengan tabel lain)
      namaSiswa: json['siswa']?['nama_lengkap']?.toString(),
      namaGuru: json['guru']?['nama_lengkap']?.toString(),
      namaModul: json['modul']?['nama_modul']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'lembaga_id': lembagaId,
      'siswa_id': siswaId,
      'guru_id': guruId,
      'modul_id': modulId,
      'tipe_evaluasi': tipeEvaluasi,
      'nilai_akhir': nilaiAkhir,
      'is_lulus': isLulus,
      'tanggal_evaluasi': tanggalEvaluasi?.toIso8601String(),
      'catatan': catatan,
      'detail_penilaian': detailPenilaian,
    };
  }

  EvaluasiRecordModel copyWith({
    String? id,
    String? lembagaId,
    String? siswaId,
    String? guruId,
    String? modulId,
    String? tipeEvaluasi,
    double? nilaiAkhir,
    bool? isLulus,
    DateTime? tanggalEvaluasi,
    String? catatan,
    Map<String, dynamic>? detailPenilaian,
    String? namaSiswa,
    String? namaGuru,
    String? namaModul,
  }) {
    return EvaluasiRecordModel(
      id: id ?? this.id,
      lembagaId: lembagaId ?? this.lembagaId,
      siswaId: siswaId ?? this.siswaId,
      guruId: guruId ?? this.guruId,
      modulId: modulId ?? this.modulId,
      tipeEvaluasi: tipeEvaluasi ?? this.tipeEvaluasi,
      nilaiAkhir: nilaiAkhir ?? this.nilaiAkhir,
      isLulus: isLulus ?? this.isLulus,
      tanggalEvaluasi: tanggalEvaluasi ?? this.tanggalEvaluasi,
      catatan: catatan ?? this.catatan,
      detailPenilaian: detailPenilaian ?? this.detailPenilaian,
      namaSiswa: namaSiswa ?? this.namaSiswa,
      namaGuru: namaGuru ?? this.namaGuru,
      namaModul: namaModul ?? this.namaModul,
    );
  }
}