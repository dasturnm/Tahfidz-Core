// Lokasi: lib/features/mutabaah/models/mutabaah_projection_model.dart
// MutabaahProjectionModel ntuk menampung hasil kalkulasi cerdas.

class MutabaahProjectionModel {
  final String siswaId;
  final String modulId;
  final double totalTarget;
  final double currentAchieved;
  final double remainingVolume;
  final double averageVelocity;
  final int estimatedMeetingsLeft;
  final DateTime? estimatedCompletionDate;
  final bool isCompleted;

  MutabaahProjectionModel({
    required this.siswaId,
    required this.modulId,
    this.totalTarget = 0.0,
    this.currentAchieved = 0.0,
    this.remainingVolume = 0.0,
    this.averageVelocity = 0.0,
    this.estimatedMeetingsLeft = 0,
    this.estimatedCompletionDate,
    this.isCompleted = false,
  });

  factory MutabaahProjectionModel.fromJson(Map<String, dynamic> json) {
    return MutabaahProjectionModel(
      siswaId: json['siswa_id']?.toString() ?? '',
      modulId: json['modul_id']?.toString() ?? '',
      totalTarget: (json['total_target'] as num?)?.toDouble() ?? 0.0,
      currentAchieved: (json['current_achieved'] as num?)?.toDouble() ?? 0.0,
      remainingVolume: (json['remaining_volume'] as num?)?.toDouble() ?? 0.0,
      averageVelocity: (json['average_velocity'] as num?)?.toDouble() ?? 0.0,
      estimatedMeetingsLeft: (json['estimated_meetings_left'] as num?)?.toInt() ?? 0,
      estimatedCompletionDate: json['estimated_completion_date'] != null
          ? DateTime.tryParse(json['estimated_completion_date'].toString())
          : null,
      isCompleted: json['is_completed'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'siswa_id': siswaId,
      'modul_id': modulId,
      'total_target': totalTarget,
      'current_achieved': currentAchieved,
      'remaining_volume': remainingVolume,
      'average_velocity': averageVelocity,
      'estimated_meetings_left': estimatedMeetingsLeft,
      if (estimatedCompletionDate != null)
        'estimated_completion_date': estimatedCompletionDate!.toIso8601String(),
      'is_completed': isCompleted,
    };
  }

  MutabaahProjectionModel copyWith({
    String? siswaId,
    String? modulId,
    double? totalTarget,
    double? currentAchieved,
    double? remainingVolume,
    double? averageVelocity,
    int? estimatedMeetingsLeft,
    DateTime? estimatedCompletionDate,
    bool? isCompleted,
  }) {
    return MutabaahProjectionModel(
      siswaId: siswaId ?? this.siswaId,
      modulId: modulId ?? this.modulId,
      totalTarget: totalTarget ?? this.totalTarget,
      currentAchieved: currentAchieved ?? this.currentAchieved,
      remainingVolume: remainingVolume ?? this.remainingVolume,
      averageVelocity: averageVelocity ?? this.averageVelocity,
      estimatedMeetingsLeft: estimatedMeetingsLeft ?? this.estimatedMeetingsLeft,
      estimatedCompletionDate: estimatedCompletionDate ?? this.estimatedCompletionDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}