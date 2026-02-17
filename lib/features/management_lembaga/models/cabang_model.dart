class CabangModel {
  final String id;
  final String lembagaId;
  final String namaCabang;
  final String kodeCabang;
  final String? alamat;
  final String? waCabang;
  final String? emailCabang;
  final String? kepalaCabangId;
  final String? kepalaCabang; // Ditambahkan untuk nama display
  final String? status;
  final String? jamOperasional;
  final String? catatan;
  final String? tanggalBerdiri;

  CabangModel({
    required this.id,
    required this.lembagaId,
    this.namaCabang = '', // Dibuat optional dengan default untuk inisialisasi baru
    this.kodeCabang = '', // Dibuat optional dengan default untuk inisialisasi baru
    this.alamat,
    this.waCabang,
    this.emailCabang,
    this.kepalaCabangId,
    this.kepalaCabang, // Ditambahkan ke constructor
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
    String? kepalaCabang, // Ditambahkan ke copyWith
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
      kepalaCabang: kepalaCabang ?? this.kepalaCabang, // Mapping copyWith
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
    kepalaCabang: json['kepala_cabang'], // Mapping dari JSON (biasanya hasil join)
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