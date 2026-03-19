
class ProfileModel {
  final String id;
  final String? lembagaId;
  final String namaLengkap;
  final String? email;
  final String? noHp;
  final String? nip;
  final String role; // admin_lembaga, guru, wali, staff
  final bool isNewUser;
  final String? status; // aktif, nonaktif
  final String? cabangId;
  final String? divisiId;
  final String? jenisKelamin; // L, P
  final String? alamat;
  final DateTime? tanggalBergabung;
  final Map<String, dynamic>? lastAttendance;

  // Field Relasi (Hasil Join dari Supabase)
  final String? namaCabang;
  final String? namaJabatan;
  final String? namaLembaga;

  ProfileModel({
    required this.id,
    this.lembagaId,
    required this.namaLengkap,
    this.email,
    this.noHp,
    this.nip,
    required this.role,
    this.isNewUser = true,
    this.status,
    this.cabangId,
    this.divisiId,
    this.jenisKelamin,
    this.alamat,
    this.tanggalBergabung,
    this.lastAttendance,
    this.namaCabang,
    this.namaJabatan,
    this.namaLembaga,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      lembagaId: json['lembaga_id'] as String?,
      namaLengkap: json['nama_lengkap'] as String? ?? 'Tanpa Nama',
      email: json['email'] as String?,
      noHp: json['no_hp'] as String?,
      nip: json['nip'] as String?,
      role: json['role'] as String? ?? 'staff',
      isNewUser: json['is_new_user'] as bool? ?? true,
      status: json['status'] as String?,
      cabangId: json['cabang_id'] as String?,
      divisiId: json['divisi_id'] as String?,
      jenisKelamin: json['jenis_kelamin'] as String?,
      alamat: json['alamat'] as String?,
      tanggalBergabung: json['tanggal_bergabung'] != null
          ? DateTime.tryParse(json['tanggal_bergabung'].toString())
          : null,
      lastAttendance: json['last_attendance'] as Map<String, dynamic>?,

      // Relasi handling
      namaCabang: json['cabang'] != null ? json['cabang']['nama_cabang']?.toString() : null,
      namaJabatan: json['jabatan'] != null ? json['jabatan']['nama_jabatan']?.toString() : null,
      namaLembaga: json['lembaga'] != null ? json['lembaga']['nama_lembaga']?.toString() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lembaga_id': lembagaId,
      'nama_lengkap': namaLengkap,
      'email': email,
      'no_hp': noHp,
      'nip': nip,
      'role': role,
      'is_new_user': isNewUser,
      'status': status,
      'cabang_id': cabangId,
      'divisi_id': divisiId,
      'jenis_kelamin': jenisKelamin,
      'alamat': alamat,
      'tanggal_bergabung': tanggalBergabung?.toIso8601String(),
      'last_attendance': lastAttendance,
    };
  }

  ProfileModel copyWith({
    String? id,
    String? lembagaId,
    String? namaLengkap,
    String? email,
    String? noHp,
    String? nip,
    String? role,
    bool? isNewUser,
    String? status,
    String? cabangId,
    String? divisiId,
    String? jenisKelamin,
    String? alamat,
    DateTime? tanggalBergabung,
    Map<String, dynamic>? lastAttendance,
    String? namaCabang,
    String? namaJabatan,
    String? namaLembaga,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      lembagaId: lembagaId ?? this.lembagaId,
      namaLengkap: namaLengkap ?? this.namaLengkap,
      email: email ?? this.email,
      noHp: noHp ?? this.noHp,
      nip: nip ?? this.nip,
      role: role ?? this.role,
      isNewUser: isNewUser ?? this.isNewUser,
      status: status ?? this.status,
      cabangId: cabangId ?? this.cabangId,
      divisiId: divisiId ?? this.divisiId,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      alamat: alamat ?? this.alamat,
      tanggalBergabung: tanggalBergabung ?? this.tanggalBergabung,
      lastAttendance: lastAttendance ?? this.lastAttendance,
      namaCabang: namaCabang ?? this.namaCabang,
      namaJabatan: namaJabatan ?? this.namaJabatan,
      namaLembaga: namaLembaga ?? this.namaLembaga,
    );
  }

  bool get isAdmin => role == 'admin_lembaga';
  bool get isGuru => role == 'guru';
  bool get isWali => role == 'wali';

  // JEMBATAN KOMPATIBILITAS (Agar kode lama tidak error)
  String get nama => namaLengkap;
  String? get kontak => noHp;
  bool get isActive => status == 'aktif';
  String? get namaDivisi => divisiId;
}