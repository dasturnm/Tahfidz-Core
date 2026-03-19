class AgendaModel {
  final String id;
  final String lembagaId;
  final String tahunAjaranId; // Baru: Untuk menghubungkan agenda dengan periode akademik
  final String namaAgenda; // Input teks di modal agenda
  final DateTime tanggalMulai; // Seleksi tanggal di modal
  final DateTime tanggalBerakhir; // Seleksi tanggal di modal
  final String statusHariBelajar; // EFEKTIF atau LIBUR (Hijau/Merah)
  final String scope; // GLOBAL atau PROG_SPESIFIK
  final String? programId; // Pilihan program jika scope spesifik
  final String? keterangan; // Detail agenda (Opsional)
  final bool isSiswaLibur; // Status libur siswa
  final bool isGuruMasuk; // Status kehadiran guru/staff

  AgendaModel({
    required this.id,
    required this.lembagaId,
    required this.tahunAjaranId, // Baru
    required this.namaAgenda,
    required this.tanggalMulai,
    required this.tanggalBerakhir,
    required this.statusHariBelajar,
    required this.scope,
    this.programId,
    this.keterangan,
    required this.isSiswaLibur,
    required this.isGuruMasuk,
  });

  factory AgendaModel.fromJson(Map<String, dynamic> json) => AgendaModel(
    id: json['id']?.toString() ?? '',
    lembagaId: json['lembaga_id']?.toString() ?? '',
    tahunAjaranId: json['tahun_ajaran_id']?.toString() ?? '', // Baru
    namaAgenda: json['nama_agenda'] ?? '',
    tanggalMulai: json['tanggal_mulai'] != null
        ? DateTime.parse(json['tanggal_mulai'])
        : DateTime.now(),
    tanggalBerakhir: json['tanggal_berakhir'] != null
        ? DateTime.parse(json['tanggal_berakhir'])
        : DateTime.now(),
    statusHariBelajar: json['status_hari_belajar'] ?? 'EFEKTIF',
    scope: json['scope'] ?? 'GLOBAL',
    programId: json['program_id']?.toString(),
    keterangan: json['keterangan'],
    isSiswaLibur: json['is_siswa_libur'] ?? false,
    isGuruMasuk: json['is_guru_masuk'] ?? true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'lembaga_id': lembagaId,
    'tahun_ajaran_id': tahunAjaranId,
    'nama_agenda': namaAgenda,
    'tanggal_mulai': tanggalMulai.toIso8601String(),
    'tanggal_berakhir': tanggalBerakhir.toIso8601String(),
    'status_hari_belajar': statusHariBelajar,
    'scope': scope,
    'program_id': programId,
    'keterangan': keterangan,
    'is_siswa_libur': isSiswaLibur,
    'is_guru_masuk': isGuruMasuk,
  };

  AgendaModel copyWith({
    String? id,
    String? lembagaId,
    String? tahunAjaranId,
    String? namaAgenda,
    DateTime? tanggalMulai,
    DateTime? tanggalBerakhir,
    String? statusHariBelajar,
    String? scope,
    String? programId,
    String? keterangan,
    bool? isSiswaLibur,
    bool? isGuruMasuk,
  }) {
    return AgendaModel(
      id: id ?? this.id,
      lembagaId: lembagaId ?? this.lembagaId,
      tahunAjaranId: tahunAjaranId ?? this.tahunAjaranId,
      namaAgenda: namaAgenda ?? this.namaAgenda,
      tanggalMulai: tanggalMulai ?? this.tanggalMulai,
      tanggalBerakhir: tanggalBerakhir ?? this.tanggalBerakhir,
      statusHariBelajar: statusHariBelajar ?? this.statusHariBelajar,
      scope: scope ?? this.scope,
      programId: programId ?? this.programId,
      keterangan: keterangan ?? this.keterangan,
      isSiswaLibur: isSiswaLibur ?? this.isSiswaLibur,
      isGuruMasuk: isGuruMasuk ?? this.isGuruMasuk,
    );
  }
}