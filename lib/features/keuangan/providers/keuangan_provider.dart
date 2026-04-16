// Lokasi: lib/features/keuangan/providers/keuangan_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // FIX: Menambahkan akses ke Ref dan AsyncValue
import '../models/salary_settings_model.dart';
import '../services/keuangan_service.dart';

part 'keuangan_provider.g.dart';

// 1. Service Provider
final keuanganServiceProvider = Provider((ref) => KeuanganService());

// 2. Provider untuk mengambil Konfigurasi Gaji (Settings)
@riverpod
Future<SalarySettingsModel?> salarySettings(Ref ref) async {
  return ref.watch(keuanganServiceProvider).getSettings(ref);
}

// 3. Provider untuk kalkulasi Payroll (Bisa dipanggil per Guru & per Bulan)
// Penggunaan: ref.watch(monthlyPayrollProvider(guruId: '...', month: DateTime.now()))
@riverpod
Future<Map<String, dynamic>> monthlyPayroll(
    Ref ref, {
      required String guruId,
      required DateTime month,
    }) async {
  return ref.watch(keuanganServiceProvider).calculateMonthlyPayroll(ref, guruId, month);
}

// 4. Notifier untuk Aksi Keuangan (Save Settings)
@riverpod
class KeuanganNotifier extends _$KeuanganNotifier {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  /// Menyimpan atau memperbarui konfigurasi gaji lembaga
  Future<void> updateSettings(SalarySettingsModel settings) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(keuanganServiceProvider).saveSettings(settings);
      ref.invalidate(salarySettingsProvider); // Refresh data settings
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}