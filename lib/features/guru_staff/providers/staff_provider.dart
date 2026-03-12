import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/staff_model.dart';

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
  final _supabase = Supabase.instance.client;

  @override
  Future<List<StaffModel>> build() async {
    // 1. Ambil user yang sedang login
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    // 2. Ambil lembaga_id dari profile user tersebut
    final profile = await _supabase
        .from('profiles')
        .select('lembaga_id')
        .eq('id', user.id)
        .maybeSingle();

    if (profile == null) return [];

    // 3. Ambil semua data personil (Termasuk data absensi hari ini)
    // UPDATE: Menambahkan jenis_kelamin ke dalam select
    final response = await _supabase
        .from('profiles')
        .select('*, jenis_kelamin, divisi:divisi_id(nama_divisi), penugasan_staf(status, is_utama, cabang:cabang_id(nama_cabang), jabatan:jabatan_id(nama_jabatan)), absensi(status, tanggal)')
        .eq('lembaga_id', profile['lembaga_id'])
        .order('nama_lengkap', ascending: true);

    // 4. Mapping data Map dari Supabase ke StaffModel
    final today = DateTime.now().toIso8601String().split('T')[0];

    return (response as List).map((json) {
      // Cari penugasan yang statusnya aktif dan is_utama = true
      // Jika tidak ada is_utama, ambil yang pertama dari yang aktif
      final listPenugasan = (json['penugasan_staf'] as List?) ?? [];

      final penugasanActive = listPenugasan.firstWhere(
            (ps) => ps['status'] == 'aktif' && ps['is_utama'] == true,
        orElse: () => listPenugasan.firstWhere(
              (ps) => ps['status'] == 'aktif',
          orElse: () => listPenugasan.isNotEmpty ? listPenugasan[0] : null,
        ),
      );

      // Ambil status absen hari ini
      final lastAttendance = (json['absensi'] as List?)?.firstWhere(
            (a) => a['tanggal'] == today,
        orElse: () => null,
      );

      return StaffModel.fromJson({
        ...json,
        'nama': json['nama_lengkap'], // Sinkronisasi nama kolom
        'namaDivisi': json['divisi']?['nama_divisi'] ?? '-', // Fallback jika null
        'namaCabang': penugasanActive?['cabang']?['nama_cabang'] ?? '-', // Fallback jika null
        'namaJabatan': penugasanActive?['jabatan']?['nama_jabatan'] ?? '-', // Fallback jika null
        'assignments': listPenugasan, // Melemparkan raw list untuk deteksi Hybrid
        'last_attendance': lastAttendance, // Status kehadiran untuk UI
      });
    }).toList();
  }

  // --- Fungsi yang sudah kamu buat sebelumnya tetap terjaga ---

  // Fungsi untuk Menambah/Edit Staff (Universal)
  Future<void> upsertStaff(Map<String, dynamic> data) async {
    // FIX: Data cleaning untuk mencegah error "invalid input syntax" pada tipe data DATE atau UUID
    final cleanData = Map<String, dynamic>.from(data);
    cleanData.forEach((key, value) {
      if (value == '') cleanData[key] = null;
    });

    await _supabase.from('profiles').upsert(cleanData);
    ref.invalidateSelf(); // Refresh data otomatis
  }

  // Fungsi untuk Nonaktifkan Staff (Soft Delete)
  Future<void> toggleStatus(String id, String currentStatus) async {
    final newStatus = currentStatus == 'aktif' ? 'nonaktif' : 'aktif';
    await _supabase.from('profiles').update({'status': newStatus}).eq('id', id);
    ref.invalidateSelf();
  }

  // --- FUNGSI BARU: AMBIL RIWAYAT PENUGASAN PER STAF ---
  Future<List<Map<String, dynamic>>> fetchHistory(String staffId) async {
    // 1. Ambil Penugasan yang sedang AKTIF sekarang (dari penugasan_staf)
    final activeResponse = await _supabase
        .from('penugasan_staf')
        .select('*, cabang:cabang_id(nama_cabang), jabatan:jabatan_id(nama_jabatan)')
        .eq('profile_id', staffId)
        .eq('status', 'aktif');

    // 2. Ambil data dari tabel RIWAYAT masa lalu
    final historyResponse = await _supabase
        .from('riwayat_penugasan')
        .select('*, cabang:cabang_id(nama_cabang), jabatan:jabatan_id(nama_jabatan)')
        .eq('staf_id', staffId);

    // 3. Gabungkan keduanya menjadi satu Timeline
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
  }

  // --- FUNGSI BARU: UPDATE ROLE OTOMATIS ---
  Future<void> updateRole(String staffId, String role) async {
    await _supabase.from('profiles').update({'role': role}).eq('id', staffId);
    ref.invalidateSelf();
  }

  // --- PULIHKAN SEMENTARA AGAR TIDAK ERROR BUILD ---
  Future<void> submitAbsensi({
    required String staffId,
    required String status, // H, I, S, A
  }) async {
    final today = DateTime.now().toIso8601String().split('T')[0];

    // Menggunakan upsert agar data hari yang sama bisa diperbarui jika ada perubahan
    await _supabase.from('absensi').upsert({
      'staf_id': staffId,
      'tanggal': today,
      'status': status,
      'waktu_catat': DateTime.now().toIso8601String(),
    });

    ref.invalidateSelf(); // Refresh data agar status di UI berubah
  }
}