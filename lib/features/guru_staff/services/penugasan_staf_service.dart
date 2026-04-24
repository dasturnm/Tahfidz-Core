// Lokasi: lib/features/guru_staff/services/penugasan_staf_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tahfidz_core/core/services/base_service.dart';
import 'package:tahfidz_core/features/guru_staff/models/penugasan_staf_model.dart';

class PenugasanStafService extends BaseService {
  /// 🔍 FETCH DAFTAR PENUGASAN
  Future<List<PenugasanStafModel>> fetchPenugasan({required String lembagaId}) async {
    try {
      // Menggunakan instance 'supabase' dari BaseService
      PostgrestFilterBuilder query = supabase
          .from('penugasan_staf')
          .select('''
            *,
            profiles:profile_id(nama_lengkap, email),
            jabatan:jabatan_id(nama_jabatan),
            cabang:cabang_id(nama_cabang)
          ''');

      // 🛡️ KEAMANAN: Filter otomatis berdasarkan lembagaId
      query = applyLembagaFilter(query: query, lembagaId: lembagaId);

      final response = await query.order('created_at', ascending: false);

      return (response as List)
          .map((json) => PenugasanStafModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// 💾 SAVE / UPDATE PENUGASAN (Atomic)
  Future<void> savePenugasan(PenugasanStafModel penugasan) async {
    try {
      if (penugasan.id.isEmpty) {
        // Insert Baru
        await supabase.from('penugasan_staf').insert(penugasan.toJson());
      } else {
        // Update data yang sudah ada
        await supabase
            .from('penugasan_staf')
            .update(penugasan.toJson())
            .eq('id', penugasan.id);
      }
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// 🗑️ HAPUS PENUGASAN
  Future<void> deletePenugasan(String id) async {
    try {
      await supabase.from('penugasan_staf').delete().eq('id', id);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// 🚀 LOGIKA BISNIS: TAMBAH PENUGASAN (Mutasi & Rangkap Jabatan)
  Future<void> tambahPenugasan({
    required String stafId,
    required String lembagaId, // TAMBAHAN: Agar data terbaca oleh RLS
    required String jabatanId,
    String? cabangId,
    bool isUtama = false,
    bool deactivatePrevious = false,
  }) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];

      // 1. Ambil info Role dari tabel jabatan (SINKRON: Menggunakan kolom default_role)
      final jabData = await supabase
          .from('jabatan')
          .select('default_role')
          .eq('id', jabatanId)
          .single();

      // FIX: Gunakan trim() dan toUpperCase() agar pencocokan string 100% akurat
      final String roleValue = (jabData['default_role'] ?? '').toString().trim().toUpperCase();
      String targetRole = 'staff';

      // Sesuai dengan pilihan di Dropdown Jabatan (ADMIN_PUSAT, ADMIN_CABANG, GURU, STAFF)
      if (roleValue == 'ADMIN_PUSAT') {
        targetRole = 'admin_lembaga';
      } else if (roleValue == 'ADMIN_CABANG') {
        targetRole = 'admin_cabang';
      } else if (roleValue == 'GURU') {
        targetRole = 'guru';
      } else if (roleValue == 'STAFF') {
        targetRole = 'staff';
      }

      // 2. Update ROLE di tabel profiles agar sinkron dengan Jabatan Baru
      await supabase
          .from('profiles')
          .update({'role': targetRole})
          .eq('id', stafId);

      // 3. LOGIKA MUTASI: Selesaikan semua jabatan aktif sebelumnya jika diminta
      if (deactivatePrevious) {
        await supabase
            .from('penugasan_staf')
            .update({
          'status': 'selesai',
          'tanggal_selesai': today, // FIX: Membutuhkan kolom ini di Supabase
          'is_utama': false,
        })
            .eq('profile_id', stafId)
            .eq('status', 'aktif');
      }

      // 4. LOGIKA JABATAN UTAMA: Pastikan hanya ada satu jabatan utama yang aktif
      if (isUtama) {
        await supabase
            .from('penugasan_staf')
            .update({'is_utama': false})
            .eq('profile_id', stafId);
      }

      // 5. PROSES INSERT: Menambahkan penugasan baru
      await supabase.from('penugasan_staf').insert({
        'profile_id': stafId,
        'lembaga_id': lembagaId, // FIX: Wajib ada agar data muncul di Tab/Filter
        'cabang_id': cabangId,
        'jabatan_id': jabatanId,
        'tanggal_mulai': today,
        'is_utama': isUtama,
        'status': 'aktif',
      });
    } catch (e) {
      throw Exception(handleError(e));
    }
  }
}