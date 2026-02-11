class GuruModel {
  final String? id; // Nullable karena saat create, ID dibuat oleh DB
  final String nama;
  final String? nip;
  final String? kontak;
  final String? alamat;
  final bool isActive;
  final DateTime? createdAt;

  GuruModel({
    this.id,
    required this.nama,
    this.nip,
    this.kontak,
    this.alamat,
    this.isActive = true,
    this.createdAt,
  });

  // Factory untuk konversi dari JSON (Supabase) ke Object
  factory GuruModel.fromJson(Map<String, dynamic> json) {
    return GuruModel(
      id: json['id'],
      nama: json['nama'] ?? '',
      nip: json['nip'],
      kontak: json['kontak'],
      alamat: json['alamat'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  // Method untuk konversi dari Object ke JSON (untuk Insert/Update)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nama': nama,
      'nip': nip,
      'kontak': kontak,
      'alamat': alamat,
      'is_active': isActive,
    };
  }

  // Mempermudah update data dengan method copyWith
  GuruModel copyWith({
    String? id,
    String? nama,
    String? nip,
    String? kontak,
    String? alamat,
    bool? isActive,
  }) {
    return GuruModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      nip: nip ?? this.nip,
      kontak: kontak ?? this.kontak,
      alamat: alamat ?? this.alamat,
      isActive: isActive ?? this.isActive,
    );
  }
}