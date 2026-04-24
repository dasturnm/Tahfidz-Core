class PenugasanStafModel {
  final String id;
  final String lembagaId;
  final String cabangId;
  final String profileId;
  final String? jabatanId;
  final String status;
  final String? tanggalMulai;
  final bool isUtama;

  // Data Relasi (Diambil otomatis pakai JOIN Supabase)
  final String? namaStaf;
  final String? emailStaf;
  final String? nip; // TAMBAHAN: Sinkronisasi Form & CSV
  final String? noHp; // TAMBAHAN: Sinkronisasi Form & CSV
  final String? jenisKelamin; // TAMBAHAN: Sinkronisasi Form & CSV
  final String? tanggalBergabung; // TAMBAHAN: Sinkronisasi Form & CSV
  final String? passwordSementara; // TAMBAHAN: Khusus untuk kebutuhan Export/Import
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
    this.isUtama = false,
    this.namaStaf,
    this.emailStaf,
    this.nip,
    this.noHp,
    this.jenisKelamin,
    this.tanggalBergabung,
    this.passwordSementara,
    this.namaJabatan,
    this.namaCabang,
  });

  factory PenugasanStafModel.fromJson(Map<String, dynamic> json) {
    // Mengekstrak data relasi jika ada (Supabase Nested JSON)
    final profile = json['profiles'] as Map<String, dynamic>?;
    final jabatan = json['jabatan'] as Map<String, dynamic>?;
    final cabang = json['cabang'] as Map<String, dynamic>?;

    return PenugasanStafModel(
      id: json['id']?.toString() ?? '', // FIX: Robust UUID handling
      lembagaId: json['lembaga_id']?.toString() ?? '',
      cabangId: json['cabang_id']?.toString() ?? '',
      profileId: json['profile_id']?.toString() ?? '',
      jabatanId: json['jabatan_id']?.toString(),
      status: json['status'] ?? 'aktif',
      tanggalMulai: json['tanggal_mulai'],
      isUtama: json['is_utama'] ?? false,
      // Ambil nama dari relasi, sesuaikan field 'nama_lengkap' dengan kolom di tabel profiles Anda
      namaStaf: profile?['nama_lengkap'] ?? profile?['full_name'] ?? 'Tanpa Nama',
      emailStaf: profile?['email'] ?? '-',
      nip: profile?['nip'],
      noHp: profile?['no_hp'],
      jenisKelamin: profile?['jenis_kelamin'],
      tanggalBergabung: profile?['tanggal_bergabung'],
      passwordSementara: null, // Password tidak diambil dari DB untuk keamanan
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
      'is_utama': isUtama,
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
    bool? isUtama,
    String? namaStaf,
    String? emailStaf,
    String? nip,
    String? noHp,
    String? jenisKelamin,
    String? tanggalBergabung,
    String? passwordSementara,
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
      isUtama: isUtama ?? this.isUtama,
      namaStaf: namaStaf ?? this.namaStaf,
      emailStaf: emailStaf ?? this.emailStaf,
      nip: nip ?? this.nip,
      noHp: noHp ?? this.noHp,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      tanggalBergabung: tanggalBergabung ?? this.tanggalBergabung,
      passwordSementara: passwordSementara ?? this.passwordSementara,
      namaJabatan: namaJabatan ?? this.namaJabatan,
      namaCabang: namaCabang ?? this.namaCabang,
    );
  }
}