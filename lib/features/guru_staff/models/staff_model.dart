class StaffModel {
  final String? id; // Nullable karena saat create, ID dibuat oleh DB
  final String nama;
  final String? email;
  final String? nip;
  final String? kontak;
  final String? alamat;
  final String? jenisKelamin; // TAMBAHAN: Untuk logika warna Avatar (L/P)
  final bool isActive;
  final DateTime? createdAt;
  // Field tambahan untuk mendukung Hybrid & Global UI
  final String? namaDivisi;
  final String? namaCabang;
  final String? namaJabatan;
  final List<dynamic>? assignments;
  final String? role; // Tambahan: Membedakan Guru/Admin di tabel Semua Staf
  final Map<String, dynamic>? lastAttendance; // Tambahan: Data absensi hari ini

  // Getter untuk kompatibilitas UI yang mencari 'namaLengkap'
  String get namaLengkap => nama;

  StaffModel({
    this.id,
    required this.nama,
    this.email,
    this.nip,
    this.kontak,
    this.alamat,
    this.jenisKelamin, // TAMBAHAN
    this.isActive = true,
    this.createdAt,
    this.namaDivisi,
    this.namaCabang,
    this.namaJabatan,
    this.assignments,
    this.role,
    this.lastAttendance,
  });

  // Factory untuk konversi dari JSON (Supabase) ke Object
  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['id'],
      nama: json['nama'] ?? json['nama_lengkap'] ?? '', // Support nama_lengkap dari profiles
      email: json['email'],
      nip: json['nip'],
      kontak: json['kontak'] ?? json['no_hp'], // Support no_hp dari profiles
      alamat: json['alamat'],
      jenisKelamin: json['jenis_kelamin'], // TAMBAHAN
      isActive: json['is_active'] ?? (json['status'] == 'aktif'), // Map status ke isActive
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      namaDivisi: json['namaDivisi'],
      namaCabang: json['namaCabang'],
      namaJabatan: json['namaJabatan'],
      assignments: json['assignments'],
      role: json['role'],
      lastAttendance: json['last_attendance'],
    );
  }

  // Method untuk konversi dari Object ke JSON (untuk Insert/Update)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nama': nama,
      'email': email,
      'nip': nip,
      'kontak': kontak,
      'alamat': alamat,
      'jenis_kelamin': jenisKelamin, // TAMBAHAN
      'is_active': isActive,
      'namaDivisi': namaDivisi,
      'namaCabang': namaCabang,
      'namaJabatan': namaJabatan,
      'assignments': assignments,
      'role': role,
      'last_attendance': lastAttendance,
    };
  }

  // Mempermudah update data dengan method copyWith
  StaffModel copyWith({
    String? id,
    String? nama,
    String? email,
    String? nip,
    String? kontak,
    String? alamat,
    String? jenisKelamin, // TAMBAHAN
    bool? isActive,
    String? namaDivisi,
    String? namaCabang,
    String? namaJabatan,
    List<dynamic>? assignments,
    String? role,
    Map<String, dynamic>? lastAttendance,
  }) {
    return StaffModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      nip: nip ?? this.nip,
      kontak: kontak ?? this.kontak,
      alamat: alamat ?? this.alamat,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin, // TAMBAHAN
      isActive: isActive ?? this.isActive,
      namaDivisi: namaDivisi ?? this.namaDivisi,
      namaCabang: namaCabang ?? this.namaCabang,
      namaJabatan: namaJabatan ?? this.namaJabatan,
      assignments: assignments ?? this.assignments,
      role: role ?? this.role,
      lastAttendance: lastAttendance ?? this.lastAttendance,
    );
  }
}