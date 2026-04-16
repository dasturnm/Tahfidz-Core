// Lokasi: lib/features/keuangan/models/salary_settings_model.dart

class SalarySettingsModel {
  final String? id;
  final String lembagaId;
  final double baseSalary; // Gaji Pokok
  final double perStudentBonus; // Bonus per kepala siswa yang ditangani

  // Mode Bonus Pengganti: 'fixed' (Harian) atau 'per_student' (Per Siswa)
  final String substituteBonusMode;
  final double substituteBonusAmount; // Nominal bonus pengganti

  final bool isOriginalTeacherDeducted; // Apakah gaji guru tetap dipotong jika ada delegasi?
  final double deductionAmount; // Nominal potongan jika delegasi aktif

  final DateTime updatedAt;

  SalarySettingsModel({
    this.id,
    required this.lembagaId,
    this.baseSalary = 0.0,
    this.perStudentBonus = 0.0,
    this.substituteBonusMode = 'per_student',
    this.substituteBonusAmount = 0.0,
    this.isOriginalTeacherDeducted = false,
    this.deductionAmount = 0.0,
    required this.updatedAt,
  });

  factory SalarySettingsModel.fromJson(Map<String, dynamic> json) {
    return SalarySettingsModel(
      id: json['id']?.toString(),
      lembagaId: json['lembaga_id']?.toString() ?? '',
      baseSalary: (json['base_salary'] ?? 0.0).toDouble(),
      perStudentBonus: (json['per_student_bonus'] ?? 0.0).toDouble(),
      substituteBonusMode: json['substitute_bonus_mode'] ?? 'per_student',
      substituteBonusAmount: (json['substitute_bonus_amount'] ?? 0.0).toDouble(),
      isOriginalTeacherDeducted: json['is_original_teacher_deducted'] ?? false,
      deductionAmount: (json['deduction_amount'] ?? 0.0).toDouble(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'lembaga_id': lembagaId,
      'base_salary': baseSalary,
      'per_student_bonus': perStudentBonus,
      'substitute_bonus_mode': substituteBonusMode,
      'substitute_bonus_amount': substituteBonusAmount,
      'is_original_teacher_deducted': isOriginalTeacherDeducted,
      'deduction_amount': deductionAmount,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  SalarySettingsModel copyWith({
    String? id,
    String? lembagaId,
    double? baseSalary,
    double? perStudentBonus,
    String? substituteBonusMode,
    double? substituteBonusAmount,
    bool? isOriginalTeacherDeducted,
    double? deductionAmount,
    DateTime? updatedAt,
  }) {
    return SalarySettingsModel(
      id: id ?? this.id,
      lembagaId: lembagaId ?? this.lembagaId,
      baseSalary: baseSalary ?? this.baseSalary,
      perStudentBonus: perStudentBonus ?? this.perStudentBonus,
      substituteBonusMode: substituteBonusMode ?? this.substituteBonusMode,
      substituteBonusAmount: substituteBonusAmount ?? this.substituteBonusAmount,
      isOriginalTeacherDeducted: isOriginalTeacherDeducted ?? this.isOriginalTeacherDeducted,
      deductionAmount: deductionAmount ?? this.deductionAmount,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}