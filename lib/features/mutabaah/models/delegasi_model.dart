// Lokasi: lib/features/mutabaah/models/delegasi_model.dart

class DelegasiModel {
  final String? id;
  final String lembagaId;
  final String pemberiIzinId; // Guru Tetap (Wali Bimbingan)
  final String penerimaIzinId; // Guru Pengganti (Actual Inputter)
  final String kelasId; // Lingkup delegasi per kelas sesuai kesepakatan
  final DateTime tanggalIzin; // Tanggal berlakunya delegasi
  final bool isActive; // Status izin (bisa dicabut manual)
  final String? catatan;
  final DateTime createdAt;

  DelegasiModel({
    this.id,
    required this.lembagaId,
    required this.pemberiIzinId,
    required this.penerimaIzinId,
    required this.kelasId,
    required this.tanggalIzin,
    this.isActive = true,
    this.catatan,
    required this.createdAt,
  });

  // factory untuk konversi dari JSON Supabase dengan UUID Safety
  factory DelegasiModel.fromJson(Map<String, dynamic> json) {
    return DelegasiModel(
      id: (json['id'] == null || json['id'].toString() == 'null') ? null : json['id'].toString(),
      lembagaId: json['lembaga_id']?.toString() ?? '',
      pemberiIzinId: (json['pemberi_izin_id'] == null || json['pemberi_izin_id'].toString() == 'null') ? '' : json['pemberi_izin_id'].toString(),
      penerimaIzinId: (json['penerima_izin_id'] == null || json['penerima_izin_id'].toString() == 'null') ? '' : json['penerima_izin_id'].toString(),
      kelasId: (json['kelas_id'] == null || json['kelas_id'].toString() == 'null') ? '' : json['kelas_id'].toString(),
      tanggalIzin: json['tanggal_izin'] != null
          ? DateTime.tryParse(json['tanggal_izin'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isActive: json['is_active'] ?? true,
      catatan: json['catatan']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  // Konversi ke Map untuk insert/update ke Supabase
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'lembaga_id': lembagaId,
      'pemberi_izin_id': pemberiIzinId,
      'penerima_izin_id': penerimaIzinId,
      'kelas_id': kelasId,
      // Sinkronisasi dengan tipe data 'date' di SQL
      'tanggal_izin': tanggalIzin.toIso8601String().split('T')[0],
      'is_active': isActive,
      'catatan': catatan,
      'created_at': createdAt.toIso8601String(),
    };
  }

  DelegasiModel copyWith({
    String? id,
    String? lembagaId,
    String? pemberiIzinId,
    String? penerimaIzinId,
    String? kelasId,
    DateTime? tanggalIzin,
    bool? isActive,
    String? catatan,
    DateTime? createdAt,
  }) {
    return DelegasiModel(
      id: id ?? this.id,
      lembagaId: lembagaId ?? this.lembagaId,
      pemberiIzinId: pemberiIzinId ?? this.pemberiIzinId,
      penerimaIzinId: penerimaIzinId ?? this.penerimaIzinId,
      kelasId: kelasId ?? this.kelasId,
      tanggalIzin: tanggalIzin ?? this.tanggalIzin,
      isActive: isActive ?? this.isActive,
      catatan: catatan ?? this.catatan,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}