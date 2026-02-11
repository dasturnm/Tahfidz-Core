class LembagaModel {
  final String id;
  final String namaLembaga;
  final String kodeLembaga;
  final String? alamat;
  final String? kontak;
  final String? emailOfficial;
  final String? visi;
  final String? misi;
  final String? logoUrl;
  final String? tahunAjaranAktifId;
  final String? timezone;
  final String? status;

  LembagaModel({
    required this.id,
    required this.namaLembaga,
    required this.kodeLembaga,
    this.alamat,
    this.kontak,
    this.emailOfficial,
    this.visi,
    this.misi,
    this.logoUrl,
    this.tahunAjaranAktifId,
    this.timezone,
    this.status,
  });

  LembagaModel copyWith({
    String? id,
    String? namaLembaga,
    String? kodeLembaga,
    String? alamat,
    String? kontak,
    String? emailOfficial,
    String? visi,
    String? misi,
    String? logoUrl,
    String? tahunAjaranAktifId,
    String? timezone,
    String? status,
  }) {
    return LembagaModel(
      id: id ?? this.id,
      namaLembaga: namaLembaga ?? this.namaLembaga,
      kodeLembaga: kodeLembaga ?? this.kodeLembaga,
      alamat: alamat ?? this.alamat,
      kontak: kontak ?? this.kontak,
      emailOfficial: emailOfficial ?? this.emailOfficial,
      visi: visi ?? this.visi,
      misi: misi ?? this.misi,
      logoUrl: logoUrl ?? this.logoUrl,
      tahunAjaranAktifId: tahunAjaranAktifId ?? this.tahunAjaranAktifId,
      timezone: timezone ?? this.timezone,
      status: status ?? this.status,
    );
  }

  factory LembagaModel.fromJson(Map<String, dynamic> json) => LembagaModel(
    id: json['id'],
    namaLembaga: json['nama_lembaga'] ?? '',
    kodeLembaga: json['kode_lembaga'] ?? '',
    alamat: json['alamat_pusat'],
    kontak: json['wa_official'],
    emailOfficial: json['email_official'],
    visi: json['visi'],
    misi: json['misi'],
    logoUrl: json['logo_url'],
    tahunAjaranAktifId: json['tahun_ajaran_aktif_id'],
    timezone: json['timezone'],
    status: json['status'],
  );

  Map<String, dynamic> toJson() => {
    'nama_lembaga': namaLembaga,
    'kode_lembaga': kodeLembaga,
    'alamat_pusat': alamat,
    'wa_official': kontak,
    'email_official': emailOfficial,
    'visi': visi,
    'misi': misi,
    'logo_url': logoUrl,
    'tahun_ajaran_aktif_id': tahunAjaranAktifId,
    'timezone': timezone,
    'status': status,
  };
}