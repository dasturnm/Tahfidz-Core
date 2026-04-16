import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tahfidz_core/core/providers/app_context_provider.dart';
import 'package:tahfidz_core/shared/models/profile_model.dart';
// FIX: Menggunakan penamaan 'staff' (dua 'f') sesuai instruksi
import '../services/staff_service.dart';

part 'staff_provider.g.dart';

// --- PROVIDER BARU: UNTUK PENCARIAN ---
@riverpod
class StaffSearch extends _$StaffSearch {
  @override
  String build() => '';
  void updateQuery(String query) => state = query;
}

@riverpod
class StaffList extends _$StaffList {
  // FIX: Sinkronisasi ke class StaffService
  final _service = StaffService();

  @override
  Future<List<ProfileModel>> build() async {
    // 1. Ambil lembaga_id langsung dari context global (The Brain)
    final lembagaId = ref.watch(appContextProvider).lembaga?.id;
    if (lembagaId == null) return [];

    // 2. Delegate penarikan data ke Service (The Worker)
    return _service.fetchStaffList(lembagaId: lembagaId);
  }

  // Fungsi untuk Menambah/Edit Staff (Universal)
  Future<void> upsertStaff(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.upsertStaff(data);
      final lembagaId = ref.read(appContextProvider).lembaga?.id;
      return _service.fetchStaffList(lembagaId: lembagaId!);
    });
  }

  // Fungsi untuk Nonaktifkan Staff (Soft Delete)
  Future<void> toggleStatus(String id, String currentStatus) async {
    state = const AsyncValue.loading();
    final newStatus = currentStatus == 'aktif' ? 'nonaktif' : 'aktif';

    state = await AsyncValue.guard(() async {
      await _service.updateStaffStatus(id, newStatus);
      final lembagaId = ref.read(appContextProvider).lembaga?.id;
      return _service.fetchStaffList(lembagaId: lembagaId!);
    });
  }

  // --- FUNGSI AMBIL RIWAYAT PENUGASAN PER STAFF ---
  Future<List<Map<String, dynamic>>> fetchHistory(String staffId) async {
    // Service handle semua join dan sort timeline
    return _service.fetchStaffHistory(staffId);
  }

  // --- FUNGSI UPDATE ROLE OTOMATIS ---
  Future<void> updateRole(String staffId, String role) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.updateStaffRole(staffId, role);
      final lembagaId = ref.read(appContextProvider).lembaga?.id;
      return _service.fetchStaffList(lembagaId: lembagaId!);
    });
  }

  // --- SUBMIT ABSENSI ---
  Future<void> submitAbsensi({
    required String staffId,
    required String status, // H, I, S, A
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.upsertAbsensi(staffId, status);
      final lembagaId = ref.read(appContextProvider).lembaga?.id;
      return _service.fetchStaffList(lembagaId: lembagaId!);
    });
  }
}