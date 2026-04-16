// Lokasi: lib/features/keuangan/services/keuangan_service.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/base_service.dart';
import '../models/salary_settings_model.dart';
import '../../mutabaah/models/mutabaah_model.dart';

class KeuanganService extends BaseService {

  /// 1. READ SETTINGS: Mengambil konfigurasi gaji lembaga
  Future<SalarySettingsModel?> getSettings(Ref ref) async {
    try {
      final lembagaId = getLembagaId(ref);
      final response = await supabase
          .from('salary_settings')
          .select()
          .eq('lembaga_id', lembagaId)
          .maybeSingle();

      if (response == null) return null;
      return SalarySettingsModel.fromJson(response);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// 2. UPDATE SETTINGS: Menyimpan/Update konfigurasi gaji
  Future<void> saveSettings(SalarySettingsModel settings) async {
    try {
      final data = cleanData(settings.toJson());
      if (settings.id == null) data.remove('id');

      await supabase.from('salary_settings').upsert(data);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// 3. THE CALCULATOR: Menghitung rincian gaji guru berdasarkan data mutabaah
  Future<Map<String, dynamic>> calculateMonthlyPayroll(
      Ref ref,
      String guruId,
      DateTime month
      ) async {
    try {
      final settings = await getSettings(ref);
      if (settings == null) throw Exception("Konfigurasi gaji belum diatur oleh admin.");

      // Rentang waktu bulan ini
      final firstDay = DateTime(month.year, month.month, 1).toIso8601String();
      final lastDay = DateTime(month.year, month.month + 1, 0, 23, 59, 59).toIso8601String();

      // Ambil semua record mutabaah yang diinput oleh guru ini bulan ini
      final response = await supabase
          .from('mutabaah_records')
          .select()
          .eq('guru_id', guruId)
          .gte('created_at', firstDay)
          .lte('created_at', lastDay);

      final records = (response as List).map((json) => MutabaahRecord.fromJson(json)).toList();

      // LOGIKA: Grouping per Siswa per Tanggal (Agar bonus dihitung per kepala siswa, bukan per record)
      // Key: "yyyy-MM-dd_siswaId"
      final Set<String> uniqueStudentWork = {};
      final Set<String> uniqueDelegationWork = {};
      final Set<String> uniqueDaysActive = {};

      for (var r in records) {
        final dateKey = r.createdAt.toIso8601String().split('T')[0];
        final workKey = "${dateKey}_${r.siswaId}";
        uniqueDaysActive.add(dateKey);

        if (r.isDelegasi) {
          uniqueDelegationWork.add(workKey);
        } else {
          uniqueStudentWork.add(workKey);
        }
      }

      // KALKULASI NOMINAL
      double totalBonusReguler = uniqueStudentWork.length * settings.perStudentBonus;
      double totalBonusDelegasi = 0;

      if (settings.substituteBonusMode == 'per_student') {
        totalBonusDelegasi = uniqueDelegationWork.length * settings.substituteBonusAmount;
      } else {
        // Mode Fixed: Dihitung berapa hari dia menjadi pengganti (bukan berapa siswa)
        totalBonusDelegasi = uniqueDaysActive.length * settings.substituteBonusAmount;
      }

      // Potongan Guru Tetap (Jika diaktifkan)
      // Logic: Mencari record di mana guruId ini adalah 'originalGuruId' tapi diinput orang lain (delegasi keluar)
      double totalPotongan = 0;
      if (settings.isOriginalTeacherDeducted) {
        final outResponse = await supabase
            .from('mutabaah_records')
            .select('id')
            .eq('original_guru_id', guruId)
            .eq('is_delegasi', true)
            .gte('created_at', firstDay)
            .lte('created_at', lastDay);

        // Sesuai diskusi: Potongan dihitung per kepala siswa yang didelegasikan keluar
        totalPotongan = (outResponse as List).length * settings.deductionAmount;
      }

      final double grandTotal = settings.baseSalary + totalBonusReguler + totalBonusDelegasi - totalPotongan;

      return {
        'base_salary': settings.baseSalary,
        'count_reguler_students': uniqueStudentWork.length,
        'bonus_reguler': totalBonusReguler,
        'count_delegasi_work': (settings.substituteBonusMode == 'per_student')
            ? uniqueDelegationWork.length
            : uniqueDaysActive.length,
        'bonus_delegasi': totalBonusDelegasi,
        'potongan': totalPotongan,
        'grand_total': grandTotal,
        'period': month,
      };
    } catch (e) {
      throw Exception(handleError(e));
    }
  }
}