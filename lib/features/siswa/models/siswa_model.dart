class SiswaModel {
  final String? id;
  final String? lembagaId;
  final String namaLengkap;
  final String jenisKelamin;
  final String? nisn;
  final String? alamat;
  final String? guruId;
  final String? classId;
  // Field hasil join
  final String? namaWaliKelas;
  final String? namaKelas;

  SiswaModel({
    this.id,
    this.lembagaId,
    required this.namaLengkap,
    required this.jenisKelamin,
    this.nisn,
    this.alamat,
    this.guruId,
    this.classId,
    this.namaWaliKelas,
    this.namaKelas,
  });

  factory SiswaModel.fromJson(Map<String, dynamic> json) {
    return SiswaModel(
      id: json['id'],
      lembagaId: json['lembaga_id'],
      namaLengkap: json['nama_lengkap'] ?? '',
      jenisKelamin: json['jenis_kelamin'] ?? 'L',
      nisn: json['nisn'],
      alamat: json['alamat'],
      guruId: json['guru_id'],
      classId: json['class_id'],
      // Mapping join dari profiles (wali_kelas) dan classes (kelas)
      namaWaliKelas: json['wali_kelas'] != null ? json['wali_kelas']['nama_lengkap'] : null,
      namaKelas: json['kelas'] != null ? json['kelas']['name'] : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'lembaga_id': lembagaId,
    'nama_lengkap': namaLengkap,
    'jenis_kelamin': jenisKelamin,
    'nisn': nisn,
    'alamat': alamat,
    'guru_id': guruId,
    'class_id': classId,
  };
}