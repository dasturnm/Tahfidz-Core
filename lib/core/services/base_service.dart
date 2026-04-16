// Lokasi: lib/core/services/base_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tahfidz_core/core/providers/app_context_provider.dart';

class BaseService {
  final SupabaseClient supabase = Supabase.instance.client;

  /// 🔥 WAJIB: ambil context otomatis
  AppContextState getContext(Ref ref) {
    // FIX: Mengembalikan AppContextState (Data), bukan AppContext (Notifier)
    return ref.read(appContextProvider);
  }

  /// 🔒 AUTO lembagaId
  String getLembagaId(Ref ref) {
    // OPTIMIZED: Proteksi throw agar error terdeteksi dini jika sesi hilang
    final id = getContext(ref).lembaga?.id;
    if (id == null || id.isEmpty) {
      throw Exception("Sesi lembaga tidak ditemukan. Silakan masuk kembali.");
    }
    return id;
  }

  /// 🔒 AUTO userId
  String getUserId(Ref ref) {
    // UPDATED: Mengakses property id langsung dari ProfileModel (v2026.03.22)
    return getContext(ref).profile?.id ?? supabase.auth.currentUser?.id ?? '';
  }

  /// 🔒 AUTO role
  String getUserRole(Ref ref) {
    // UPDATED: Menghubungkan langsung ke data role di AppContextState
    return getContext(ref).role ?? '';
  }

  /// 🔒 AUTO tahun ajaran
  String? getTahunAjaranId(Ref ref) {
    return getContext(ref).currentTahunAjaran?.id;
  }

  /// 🔒 AUTO siswaId (v2026.04.16)
  /// Digunakan oleh MurojaahTaskService untuk identifikasi santri aktif
  String? getSiswaId(Ref ref) {
    return getContext(ref).profile?.id;
  }

  /// 🔒 FILTER LEMBAGA
  PostgrestFilterBuilder applyLembagaFilter({
    required PostgrestFilterBuilder query,
    required String lembagaId,
  }) {
    // FIX: Gunakan toSafeId untuk mencegah hang jika ID bernilai 'null' atau kosong
    final safeId = toSafeId(lembagaId);
    if (safeId == null) return query;

    return query.eq('lembaga_id', safeId);
  }

  /// 🔒 FILTER TAHUN AJARAN
  PostgrestFilterBuilder applyTahunAjaranFilter({
    required PostgrestFilterBuilder query,
    String? tahunAjaranId,
  }) {
    // FIX: Gunakan toSafeId untuk validasi UUID tahun ajaran
    final safeId = toSafeId(tahunAjaranId);
    if (safeId == null) return query;

    return query.eq('tahun_ajaran_id', safeId);
  }

  /// 🔍 SEARCH
  PostgrestFilterBuilder applySearch({
    required PostgrestFilterBuilder query,
    required String field,
    String? keyword,
  }) {
    if (keyword == null || keyword.isEmpty) return query;
    return query.ilike(field, '%$keyword%');
  }

  /// 📄 PAGINATION
  PostgrestTransformBuilder applyPagination({
    required PostgrestFilterBuilder query,
    int limit = 10,
    int offset = 0,
  }) {
    return query.range(offset, offset + limit - 1);
  }

  /// 🔽 SORTING
  PostgrestTransformBuilder applyOrder({
    required PostgrestFilterBuilder query,
    String field = 'created_at',
    bool ascending = false,
  }) {
    return query.order(field, ascending: ascending);
  }

  /// 🧼 DATA CLEANING
  Map<String, dynamic> cleanData(Map<String, dynamic> data) {
    final cleaned = <String, dynamic>{};

    data.forEach((key, value) {
      if (value is String) {
        // OPTIMIZED: Membersihkan spasi dan menangani string 'null' secara case-insensitive
        final v = value.trim();
        cleaned[key] = (v == '' || v.toLowerCase() == 'null') ? null : v;
      } else {
        cleaned[key] = value;
      }
    });

    return cleaned;
  }

  /// 🔒 VALIDASI
  void validateRequired({
    required Map<String, dynamic> data,
    required List<String> requiredFields,
  }) {
    for (final field in requiredFields) {
      if (data[field] == null || data[field] == '') {
        throw Exception('$field wajib diisi');
      }
    }
  }

  /// 🔐 ROLE CHECK
  void checkRole({
    required String userRole,
    required List<String> allowedRoles,
  }) {
    if (!allowedRoles.contains(userRole)) {
      throw Exception('Tidak punya akses');
    }
  }

  /// 🔗 RELATION
  String withRelation(String relation) {
    return '*, $relation(*)';
  }

  /// 🧬 SAFE CAST UUID
  String? toSafeId(dynamic value) {
    if (value == null) return null;

    final stringValue = value.toString();

    if (stringValue.isEmpty || stringValue == 'null') {
      return null;
    }

    return stringValue;
  }

  /// 🧬 SAFE DATE
  DateTime? toSafeDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  /// 🚨 ERROR HANDLER (SaaS Ready)
  String handleError(dynamic error) {
    if (error is PostgrestException) {
      return error.message;
    }
    return error.toString();
  }
}