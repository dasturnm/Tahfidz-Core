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
  final int surahId;    // TAMBAHAN: Mapping Fisik
  final int endSurahId; // TAMBAHAN: Mapping Lintas Surah
  final int ayahStart;  // TAMBAHAN: Mapping Fisik
  final int ayahEnd;    // TAMBAHAN: Mapping Fisik
  final int totalBaris; // TAMBAHAN: Beban Baris Aktual
  final String tipeModul; // 'Tahfidz', 'Akademik', 'Karakter'
  final Map<String, dynamic> dataPayload; // Tempat menyimpan metrik dinamis
  final double targetSnapshot; // Target saat input (Base Kurikulum + Akumulasi Hutang)
  final double achievedAmount; // Jumlah yang berhasil disetor (Ziyadah/Tilawah)
  final double sabqiAmount;    // Jumlah Murajaah Sabqi yang dilakukan
  final double debtCreated;    // Jumlah hutang baru yang muncul dari record ini
  final bool isPassedTarget;   // Apakah setoran ini memenuhi target minimum kurikulum
  final String? catatan;
  final int internalStart;     // TAMBAHAN: Batas mulai metrik internal polimorfik
  final int internalEnd;       // TAMBAHAN: Batas akhir metrik internal polimorfik
  final String? materiSilabusAktif; // TAMBAHAN: Judul materi aktif dari CSV
  final int nomorUrutMateri;   // TAMBAHAN: Indeks urutan baris materi koordinat auto-next
  final int statusKeputusan;   // TAMBAHAN: Nilai StatusSwitchButton (-1 = Ulang, 0 = Off, 1 = Lanjut)
  final String academicStateSnapshot; // TAMBAHAN: Merekam kondisi status akademik siswa saat entri dibuat
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
    this.surahId = 0,
    this.endSurahId = 0,
    this.ayahStart = 0,
    this.ayahEnd = 0,
    this.totalBaris = 0,
    required this.tipeModul,
    required this.dataPayload,
    this.targetSnapshot = 0.0,
    this.achievedAmount = 0.0,
    this.sabqiAmount = 0.0,
    this.debtCreated = 0.0,
    this.isPassedTarget = true,
    this.catatan,
    this.internalStart = 0,
    this.internalEnd = 0,
    this.materiSilabusAktif,
    this.nomorUrutMateri = 0,
    this.statusKeputusan = 0,
    this.academicStateSnapshot = 'daily', // TAMBAHAN
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
      surahId: (json['surah_id'] as num?)?.toInt() ?? 0,
      endSurahId: (json['end_surah_id'] as num?)?.toInt() ?? 0,
      ayahStart: (json['ayah_start'] as num?)?.toInt() ?? 0,
      ayahEnd: (json['ayah_end'] as num?)?.toInt() ?? 0,
      totalBaris: (json['total_baris'] as num?)?.toInt() ?? 0,
      tipeModul: json['tipe_modul']?.toString() ?? '',
      dataPayload: json['data_payload'] as Map<String, dynamic>? ?? {},
      targetSnapshot: (json['target_snapshot'] as num?)?.toDouble() ?? 0.0,
      achievedAmount: (json['achieved_amount'] as num?)?.toDouble() ?? 0.0,
      sabqiAmount: (json['sabqi_amount'] as num?)?.toDouble() ?? 0.0,
      debtCreated: (json['debt_created'] as num?)?.toDouble() ?? 0.0,
      isPassedTarget: json['is_passed_target'] ?? true,
      catatan: json['catatan']?.toString(),
      internalStart: (json['internal_start'] as num?)?.toInt() ??
          (json['data_payload'] is Map ? (json['data_payload']['halaman_awal'] as num?)?.toInt() : null) ?? 0,
      internalEnd: (json['internal_end'] as num?)?.toInt() ??
          (json['data_payload'] is Map ? (json['data_payload']['halaman_akhir'] as num?)?.toInt() : null) ?? 0,
      materiSilabusAktif: json['materi_silabus_aktif']?.toString() ??
          (json['data_payload'] is Map ? json['data_payload']['materi_silabus']?.toString() : null),
      nomorUrutMateri: (json['nomor_urut_materi'] as num?)?.toInt() ?? 0,
      statusKeputusan: (json['status_keputusan'] as num?)?.toInt() ?? 0,
      academicStateSnapshot: json['academic_state_snapshot']?.toString() ?? 'daily', // TAMBAHAN
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
      'surah_id': surahId,
      'end_surah_id': endSurahId,
      'ayah_start': ayahStart,
      'ayah_end': ayahEnd,
      'total_baris': totalBaris,
      'tipe_modul': tipeModul,
      'data_payload': dataPayload,
      'target_snapshot': targetSnapshot,
      'achieved_amount': achievedAmount,
      'sabqi_amount': sabqiAmount,
      'debt_created': debtCreated,
      'is_passed_target': isPassedTarget,
      'catatan': catatan,
      'internal_start': internalStart,
      'internal_end': internalEnd,
      'materi_silabus_aktif': materiSilabusAktif,
      'nomor_urut_materi': nomorUrutMateri,
      'status_keputusan': statusKeputusan,
      'academic_state_snapshot': academicStateSnapshot, // TAMBAHAN
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
    int? surahId,
    int? endSurahId,
    int? ayahStart,
    int? ayahEnd,
    int? totalBaris,
    String? tipeModul,
    Map<String, dynamic>? dataPayload,
    double? targetSnapshot,
    double? achievedAmount,
    double? sabqiAmount,
    double? debtCreated,
    bool? isPassedTarget,
    String? catatan,
    int? internalStart,
    int? internalEnd,
    String? materiSilabusAktif,
    int? nomorUrutMateri,
    int? statusKeputusan,
    String? academicStateSnapshot, // TAMBAHAN
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
      surahId: surahId ?? this.surahId,
      endSurahId: endSurahId ?? this.endSurahId,
      ayahStart: ayahStart ?? this.ayahStart,
      ayahEnd: ayahEnd ?? this.ayahEnd,
      totalBaris: totalBaris ?? this.totalBaris,
      tipeModul: tipeModul ?? this.tipeModul,
      dataPayload: dataPayload ?? this.dataPayload,
      targetSnapshot: targetSnapshot ?? this.targetSnapshot,
      achievedAmount: achievedAmount ?? this.achievedAmount,
      sabqiAmount: sabqiAmount ?? this.sabqiAmount,
      debtCreated: debtCreated ?? this.debtCreated,
      isPassedTarget: isPassedTarget ?? this.isPassedTarget,
      catatan: catatan ?? this.catatan,
      internalStart: internalStart ?? this.internalStart,
      internalEnd: internalEnd ?? this.internalEnd,
      materiSilabusAktif: materiSilabusAktif ?? this.materiSilabusAktif,
      nomorUrutMateri: nomorUrutMateri ?? this.nomorUrutMateri,
      statusKeputusan: statusKeputusan ?? this.statusKeputusan,
      academicStateSnapshot: academicStateSnapshot ?? this.academicStateSnapshot, // TAMBAHAN
      createdAt: createdAt ?? this.createdAt,
    );
  }
}