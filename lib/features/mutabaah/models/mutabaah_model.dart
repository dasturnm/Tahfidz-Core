// Lokasi: lib/features/mutabaah/models/mutabaah_model.dart

class MutabaahRecord {
  final String? id;
  final String siswaId;
  final String guruId; // PERBAIKAN: Nama variabel disesuaikan dengan kolom guru_id di DB
  final String modulId;
  final String tipeModul; // 'Tahfidz', 'Akademik', 'Karakter'
  final Map<String, dynamic> dataPayload; // Tempat menyimpan metrik dinamis
  final String? catatan;
  final DateTime createdAt;

  MutabaahRecord({
    this.id,
    required this.siswaId,
    required this.guruId,
    required this.modulId,
    required this.tipeModul,
    required this.dataPayload,
    this.catatan,
    required this.createdAt,
  });

  // FIX: Tambahkan factory untuk konversi dari JSON Supabase (UUID safe)
  factory MutabaahRecord.fromJson(Map<String, dynamic> json) {
    return MutabaahRecord(
      id: json['id']?.toString(),
      siswaId: json['siswa_id']?.toString() ?? '',
      guruId: json['guru_id']?.toString() ?? '',
      modulId: json['modul_id']?.toString() ?? '',
      tipeModul: json['tipe_modul'] ?? '',
      dataPayload: json['data_payload'] as Map<String, dynamic>? ?? {},
      catatan: json['catatan'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }

  // Untuk konversi ke Supabase/JSON
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'siswa_id': siswaId,
      'guru_id': guruId, // FIX: Sinkron dengan kolom guru_id di database
      'modul_id': modulId,
      'tipe_modul': tipeModul,
      'data_payload': dataPayload,
      'catatan': catatan,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Alias toMap untuk konsistensi dengan model lain
  Map<String, dynamic> toJson() => toMap();

  MutabaahRecord copyWith({
    String? id,
    String? siswaId,
    String? guruId,
    String? modulId,
    String? tipeModul,
    Map<String, dynamic>? dataPayload,
    String? catatan,
    DateTime? createdAt,
  }) {
    return MutabaahRecord(
      id: id ?? this.id,
      siswaId: siswaId ?? this.siswaId,
      guruId: guruId ?? this.guruId,
      modulId: modulId ?? this.modulId,
      tipeModul: tipeModul ?? this.tipeModul,
      dataPayload: dataPayload ?? this.dataPayload,
      catatan: catatan ?? this.catatan,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}