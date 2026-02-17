class PenugasanStafModel {
  final String id;
  final String lembagaId;
  final String cabangId;
  final String profileId;
  final String? jabatanId;
  final String status;
  final String? tanggalMulai;

  // Data Relasi (Diambil otomatis pakai JOIN Supabase)
  final String? namaStaf;
  final String? emailStaf;
  final String? namaJabatan;
  final String? namaCabang;

  PenugasanStafModel({
    required this.id,
    required this.lembagaId,
    required this.cabangId,
    required this.profileId,
    this.jabatanId,
    this.status = 'aktif',
    this.tanggalMulai,
    this.namaStaf,
    this.emailStaf,
    this.namaJabatan,
    this.namaCabang,
  });

  factory PenugasanStafModel.fromJson(Map<String, dynamic> json) {
    // Mengekstrak data relasi jika ada (Supabase Nested JSON)
    final profile = json['profiles'] as Map<String, dynamic>?;
    final jabatan = json['jabatan'] as Map<String, dynamic>?;
    final cabang = json['cabang'] as Map<String, dynamic>?;

    return PenugasanStafModel(
      id: json['id'] ?? '',
      lembagaId: json['lembaga_id'] ?? '',
      cabangId: json['cabang_id'] ?? '',
      profileId: json['profile_id'] ?? '',
      jabatanId: json['jabatan_id'],
      status: json['status'] ?? 'aktif',
      tanggalMulai: json['tanggal_mulai'],
      // Ambil nama dari relasi, sesuaikan field 'nama_lengkap' dengan kolom di tabel profiles Anda
      namaStaf: profile?['nama_lengkap'] ?? profile?['full_name'] ?? 'Tanpa Nama',
      emailStaf: profile?['email'] ?? '-',
      namaJabatan: jabatan?['nama_jabatan'] ?? 'Belum ada jabatan',
      namaCabang: cabang?['nama_cabang'] ?? '-',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'lembaga_id': lembagaId,
      'cabang_id': cabangId,
      'profile_id': profileId,
      'jabatan_id': jabatanId,
      'status': status,
      'tanggal_mulai': tanggalMulai,
    };
  }

  PenugasanStafModel copyWith({
    String? id,
    String? lembagaId,
    String? cabangId,
    String? profileId,
    String? jabatanId,
    String? status,
    String? tanggalMulai,
    String? namaStaf,
    String? emailStaf,
    String? namaJabatan,
    String? namaCabang,
  }) {
    return PenugasanStafModel(
      id: id ?? this.id,
      lembagaId: lembagaId ?? this.lembagaId,
      cabangId: cabangId ?? this.cabangId,
      profileId: profileId ?? this.profileId,
      jabatanId: jabatanId ?? this.jabatanId,
      status: status ?? this.status,
      tanggalMulai: tanggalMulai ?? this.tanggalMulai,
      namaStaf: namaStaf ?? this.namaStaf,
      emailStaf: emailStaf ?? this.emailStaf,
      namaJabatan: namaJabatan ?? this.namaJabatan,
      namaCabang: namaCabang ?? this.namaCabang,
    );
  }
}