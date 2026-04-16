// Lokasi: lib/features/mutabaah/models/mutabaah_model.dart

class MutabaahRecord {
  final String? id;
  final String siswaId;
  final String guruId; // Actual Guru (Penginput/Pengganti) - Sesuai kolom guru_id di DB
  final String? originalGuruId; // Guru Tetap (Wali Bimbingan asli)
  final bool isDelegasi; // Flag apakah diinput melalui jalur delegasi/pengganti
  final String? delegasiId; // Referensi ke ID tabel delegasi
  final String payrollStatus; // 'pending', 'processed', 'skipped' (Audit Payroll)
  final String modulId;
  final String tipeModul; // 'Tahfidz', 'Akademik', 'Karakter'
  final Map<String, dynamic> dataPayload; // Tempat menyimpan metrik dinamis
  final String? catatan;
  final DateTime createdAt;

  MutabaahRecord({
    this.id,
    required this.siswaId,
    required this.guruId,
    this.originalGuruId,
    this.isDelegasi = false,
    this.delegasiId,
    this.payrollStatus = 'pending',
    required this.modulId,
    required this.tipeModul,
    required this.dataPayload,
    this.catatan,
    required this.createdAt,
  });

  // FIX: Factory untuk konversi dari JSON Supabase dengan UUID safety & Audit Fields
  factory MutabaahRecord.fromJson(Map<String, dynamic> json) {
    return MutabaahRecord(
      id: (json['id'] == null || json['id'].toString() == 'null') ? null : json['id'].toString(),
      siswaId: (json['siswa_id'] == null || json['siswa_id'].toString() == 'null') ? '' : json['siswa_id'].toString(),
      guruId: (json['guru_id'] == null || json['guru_id'].toString() == 'null') ? '' : json['guru_id'].toString(),
      originalGuruId: (json['original_guru_id'] == null || json['original_guru_id'].toString() == 'null') ? null : json['original_guru_id'].toString(),
      isDelegasi: json['is_delegasi'] ?? false,
      delegasiId: (json['delegasi_id'] == null || json['delegasi_id'].toString() == 'null') ? null : json['delegasi_id'].toString(),
      payrollStatus: json['payroll_status']?.toString() ?? 'pending',
      modulId: (json['modul_id'] == null || json['modul_id'].toString() == 'null') ? '' : json['modul_id'].toString(),
      tipeModul: json['tipe_modul']?.toString() ?? '',
      dataPayload: json['data_payload'] as Map<String, dynamic>? ?? {},
      catatan: json['catatan']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  // Untuk konversi ke Supabase/JSON
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'siswa_id': siswaId,
      'guru_id': guruId, // Penginput saat ini
      'original_guru_id': originalGuruId,
      'is_delegasi': isDelegasi,
      'delegasi_id': delegasiId,
      'payroll_status': payrollStatus,
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
    String? originalGuruId,
    bool? isDelegasi,
    String? delegasiId,
    String? payrollStatus,
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
      originalGuruId: originalGuruId ?? this.originalGuruId,
      isDelegasi: isDelegasi ?? this.isDelegasi,
      delegasiId: delegasiId ?? this.delegasiId,
      payrollStatus: payrollStatus ?? this.payrollStatus,
      modulId: modulId ?? this.modulId,
      tipeModul: tipeModul ?? this.tipeModul,
      dataPayload: dataPayload ?? this.dataPayload,
      catatan: catatan ?? this.catatan,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}