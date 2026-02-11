class ProgramModel {
  final String id;
  final String lembagaId;
  final String namaProgram;
  final String? tagKurikulum; // Muncul sebagai label hijau di prototype
  final String? deskripsi;
  final double biayaPendaftaran; // Ditampilkan di seksi Investasi
  final double biayaSpp; // Ditampilkan di seksi Investasi
  final List<String> hariAktif; // Digunakan untuk Template Jadwal
  final String status;

  ProgramModel({
    required this.id,
    required this.lembagaId,
    required this.namaProgram,
    this.tagKurikulum,
    this.deskripsi,
    this.biayaPendaftaran = 0,
    this.biayaSpp = 0,
    this.hariAktif = const [],
    this.status = 'aktif',
  });

  factory ProgramModel.fromJson(Map<String, dynamic> json) => ProgramModel(
    id: json['id'],
    lembagaId: json['lembaga_id'],
    namaProgram: json['nama_program'] ?? '',
    tagKurikulum: json['tag_kurikulum'],
    deskripsi: json['deskripsi'],
    biayaPendaftaran: (json['biaya_pendaftaran'] ?? 0).toDouble(),
    biayaSpp: (json['biaya_spp'] ?? 0).toDouble(),
    hariAktif: List<String>.from(json['hari_aktif'] ?? []),
    status: json['status'] ?? 'aktif',
  );

  Map<String, dynamic> toJson() => {
    'lembaga_id': lembagaId,
    'nama_program': namaProgram,
    'tag_kurikulum': tagKurikulum,
    'deskripsi': deskripsi,
    'biaya_pendaftaran': biayaPendaftaran,
    'biaya_spp': biayaSpp,
    'hari_aktif': hariAktif,
    'status': status,
  };
}