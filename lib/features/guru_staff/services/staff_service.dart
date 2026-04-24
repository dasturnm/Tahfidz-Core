// Lokasi: lib/features/guru_staff/services/staff_service.dart

import 'package:tahfidz_core/core/services/base_service.dart';
import 'package:tahfidz_core/shared/models/profile_model.dart';

class StaffService extends BaseService {
  /// 🔍 FETCH LIST STAFF
  Future<List<ProfileModel>> fetchStaffList({required String lembagaId}) async {
    try {
      final response = await supabase
          .from('profiles')
          .select('*, jenis_kelamin, divisi:divisi_id(nama_divisi), penugasan_staf(status, is_utama, cabang:cabang_id(nama_cabang), jabatan:jabatan_id(nama_jabatan)), absensi(status, tanggal)')
          .eq('lembaga_id', lembagaId)
          .order('nama_lengkap', ascending: true);

      final today = DateTime.now().toIso8601String().split('T')[0];

      return (response as List).map((json) {
        final listPenugasan = (json['penugasan_staf'] as List?) ?? [];

        final penugasanActive = listPenugasan.firstWhere(
              (ps) => ps['status'] == 'aktif' && ps['is_utama'] == true,
          orElse: () => listPenugasan.firstWhere(
                (ps) => ps['status'] == 'aktif',
            orElse: () => listPenugasan.isNotEmpty ? listPenugasan[0] : null,
          ),
        );

        final lastAttendance = (json['absensi'] as List?)?.firstWhere(
              (a) => a['tanggal'] == today,
          orElse: () => null,
        );

        return ProfileModel.fromJson({
          ...json,
          'nama': json['nama_lengkap'],
          'namaDivisi': json['divisi']?['nama_divisi'] ?? '-',
          // FIX: Identifikasi Pusat jika cabang_id null di penugasan aktif
          'namaCabang': penugasanActive?['cabang']?['nama_cabang'] ?? (penugasanActive != null ? 'Pusat' : '-'),
          // FIX: Fallback ke teks jabatan di profile jika data relasi penugasan belum dibuat
          'namaJabatan': penugasanActive?['jabatan']?['nama_jabatan'] ?? json['jabatan'] ?? '-',
          'assignments': listPenugasan,
          'last_attendance': lastAttendance,
        });
      }).toList();
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// 💾 UPSERT STAFF
  Future<void> upsertStaff(Map<String, dynamic> data) async {
    try {
      final clean = cleanData(data); // Menggunakan helper dari BaseService
      await supabase.from('profiles').upsert(clean);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// 🔄 TOGGLE STATUS
  Future<void> updateStaffStatus(String id, String newStatus) async {
    try {
      await supabase.from('profiles').update({'status': newStatus}).eq('id', id);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// 📜 FETCH RIWAYAT
  Future<List<Map<String, dynamic>>> fetchStaffHistory(String staffId) async {
    try {
      final activeResponse = await supabase
          .from('penugasan_staf')
          .select('*, cabang:cabang_id(nama_cabang), jabatan:jabatan_id(nama_jabatan)')
          .eq('profile_id', staffId)
          .eq('status', 'aktif');

      final historyResponse = await supabase
          .from('riwayat_penugasan')
          .select('*, cabang:cabang_id(nama_cabang), jabatan:jabatan_id(nama_jabatan)')
          .eq('staf_id', staffId);

      List<Map<String, dynamic>> fullTimeline = [];
      for (var item in activeResponse) {
        fullTimeline.add({
          ...item,
          'keterangan': item['is_utama'] == true ? 'Jabatan Utama (Aktif)' : 'Jabatan Tambahan (Aktif)',
          'is_current': true,
        });
      }
      fullTimeline.addAll(historyResponse.map((e) => {...e, 'is_current': false}));
      fullTimeline.sort((a, b) => (b['tanggal_mulai'] ?? '').compareTo(a['tanggal_mulai'] ?? ''));

      return fullTimeline;
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// 🔑 UPDATE ROLE
  Future<void> updateStaffRole(String staffId, String role) async {
    try {
      await supabase.from('profiles').update({'role': role}).eq('id', staffId);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// 📅 SUBMIT ABSENSI
  Future<void> upsertAbsensi(String staffId, String status) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      await supabase.from('absensi').upsert({
        'staf_id': staffId,
        'tanggal': today,
        'status': status,
        'waktu_catat': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception(handleError(e));
    }
  }
}