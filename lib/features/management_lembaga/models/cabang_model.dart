class CabangModel {
  final String id;
  final String lembagaId;
  final String namaCabang;
  final String kodeCabang;
  final String? alamat;
  final String? waCabang;
  final String? emailCabang;
  final String? kepalaCabangId;
  final String? status;
  final String? jamOperasional;
  final String? catatan;
  final String? tanggalBerdiri;

  CabangModel({
    required this.id,
    required this.lembagaId,
    required this.namaCabang,
    required this.kodeCabang,
    this.alamat,
    this.waCabang,
    this.emailCabang,
    this.kepalaCabangId,
    this.status,
    this.jamOperasional,
    this.catatan,
    this.tanggalBerdiri,
  });

  CabangModel copyWith({
    String? id,
    String? lembagaId,
    String? namaCabang,
    String? kodeCabang,
    String? alamat,
    String? waCabang,
    String? emailCabang,
    String? kepalaCabangId,
    String? status,
    String? jamOperasional,
    String? catatan,
    String? tanggalBerdiri,
  }) {
    return CabangModel(
      id: id ?? this.id,
      lembagaId: lembagaId ?? this.lembagaId,
      namaCabang: namaCabang ?? this.namaCabang,
      kodeCabang: kodeCabang ?? this.kodeCabang,
      alamat: alamat ?? this.alamat,
      waCabang: waCabang ?? this.waCabang,
      emailCabang: emailCabang ?? this.emailCabang,
      kepalaCabangId: kepalaCabangId ?? this.kepalaCabangId,
      status: status ?? this.status,
      jamOperasional: jamOperasional ?? this.jamOperasional,
      catatan: catatan ?? this.catatan,
      tanggalBerdiri: tanggalBerdiri ?? this.tanggalBerdiri,
    );
  }

  factory CabangModel.fromJson(Map<String, dynamic> json) => CabangModel(
    id: json['id'],
    lembagaId: json['lembaga_id'],
    namaCabang: json['nama_cabang'] ?? '',
    kodeCabang: json['kode_cabang'] ?? '',
    alamat: json['alamat'],
    waCabang: json['wa_cabang'],
    emailCabang: json['email_cabang'],
    kepalaCabangId: json['kepala_cabang_id'],
    status: json['status'],
    jamOperasional: json['jam_operasional'],
    catatan: json['catatan'],
    tanggalBerdiri: json['tanggal_berdiri']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'lembaga_id': lembagaId,
    'nama_cabang': namaCabang,
    'kode_cabang': kodeCabang,
    'alamat': alamat,
    'wa_cabang': waCabang,
    'email_cabang': emailCabang,
    'kepala_cabang_id': kepalaCabangId,
    'status': status,
    'jam_operasional': jamOperasional,
    'catatan': catatan,
    'tanggal_berdiri': tanggalBerdiri,
  };
}