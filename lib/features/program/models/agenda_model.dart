class AgendaModel {
  final String id;
  final String lembagaId;
  final String namaAgenda; // Input teks di modal agenda
  final DateTime tanggalMulai; // Seleksi tanggal di modal
  final DateTime tanggalBerakhir; // Seleksi tanggal di modal
  final String statusHariBelajar; // EFEKTIF atau LIBUR (Hijau/Merah)
  final String scope; // GLOBAL atau PROG_SPESIFIK
  final String? programId; // Pilihan program jika scope spesifik

  AgendaModel({
    required this.id,
    required this.lembagaId,
    required this.namaAgenda,
    required this.tanggalMulai,
    required this.tanggalBerakhir,
    required this.statusHariBelajar,
    required this.scope,
    this.programId,
  });

  factory AgendaModel.fromJson(Map<String, dynamic> json) => AgendaModel(
    id: json['id'],
    lembagaId: json['lembaga_id'],
    namaAgenda: json['nama_agenda'] ?? '',
    tanggalMulai: DateTime.parse(json['tanggal_mulai']),
    tanggalBerakhir: DateTime.parse(json['tanggal_berakhir']),
    statusHariBelajar: json['status_hari_belajar'],
    scope: json['scope'],
    programId: json['program_id'],
  );
}