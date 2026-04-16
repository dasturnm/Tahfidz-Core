// Lokasi: lib/features/program/models/program_model.dart

class ProgramModel {
  final String id;
  final String lembagaId;
  final String? cabangId; // Baru: Menggantikan tagKurikulum untuk relasi cabang
  final String namaProgram;
  final String? deskripsi;
  final double biayaPendaftaran; // Ditampilkan di seksi Investasi
  final double biayaSpp; // Ditampilkan di seksi Investasi
  final List<String> hariAktif; // Digunakan untuk Template Jadwal
  List<String> get hari => hariAktif; // FIX: Alias untuk sinkronisasi dengan program_provider.dart
  final String status;
  final bool hasKurikulum; // 🔥 FIX: Penanda apakah sudah ada kurikulum terhubung

  ProgramModel({
    required this.id,
    required this.lembagaId,
    this.cabangId,
    required this.namaProgram,
    this.deskripsi,
    this.biayaPendaftaran = 0,
    this.biayaSpp = 0,
    this.hariAktif = const [],
    this.status = 'aktif',
    this.hasKurikulum = false,
  });

  factory ProgramModel.fromJson(Map<String, dynamic> json) => ProgramModel(
    id: json['id']?.toString() ?? '',
    lembagaId: json['lembaga_id']?.toString() ?? '',
    cabangId: json['cabang_id']?.toString(),
    namaProgram: json['nama_program']?.toString() ?? '',
    deskripsi: json['deskripsi']?.toString(),
    biayaPendaftaran: (json['biaya_pendaftaran'] as num?)?.toDouble() ?? 0,
    biayaSpp: (json['biaya_spp'] as num?)?.toDouble() ?? 0,
    hariAktif: json['hari_aktif'] is List
        ? List<String>.from(json['hari_aktif'])
        : [],
    status: json['status']?.toString() ?? 'aktif',
    // 🔥 FIX: Deteksi keberadaan kurikulum dari hasil join Supabase
    hasKurikulum: json['kurikulum'] != null && (json['kurikulum'] as List).isNotEmpty,
  );

  Map<String, dynamic> toJson() => {
    'lembaga_id': lembagaId,
    'cabang_id': cabangId,
    'nama_program': namaProgram,
    'deskripsi': deskripsi,
    'biaya_pendaftaran': biayaPendaftaran,
    'biaya_spp': biayaSpp,
    'hari_aktif': hariAktif,
    'status': status,
  };

  // Method WAJIB sesuai Rule 6.5
  ProgramModel copyWith({
    String? id,
    String? lembagaId,
    String? cabangId,
    String? namaProgram,
    String? deskripsi,
    double? biayaPendaftaran,
    double? biayaSpp,
    List<String>? hariAktif,
    String? status,
    bool? hasKurikulum, // 🔥 FIX: Tambahkan hasKurikulum
  }) {
    return ProgramModel(
      id: id ?? this.id,
      lembagaId: lembagaId ?? this.lembagaId,
      cabangId: cabangId ?? this.cabangId,
      namaProgram: namaProgram ?? this.namaProgram,
      deskripsi: deskripsi ?? this.deskripsi,
      biayaPendaftaran: biayaPendaftaran ?? this.biayaPendaftaran,
      biayaSpp: biayaSpp ?? this.biayaSpp,
      hariAktif: hariAktif ?? this.hariAktif,
      status: status ?? this.status,
      hasKurikulum: hasKurikulum ?? this.hasKurikulum,
    );
  }
}