import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_context_provider.dart';

class BaseService {
  final SupabaseClient supabase = Supabase.instance.client;

  /// 🔥 WAJIB: ambil context otomatis
  AppContext getContext(Ref ref) {
    return ref.read(appContextNotifierProvider);
  }

  /// 🔒 AUTO lembagaId
  String getLembagaId(Ref ref) {
    return getContext(ref).lembagaId;
  }

  /// 🔒 AUTO userId
  String getUserId(Ref ref) {
    return getContext(ref).userId;
  }

  /// 🔒 AUTO role
  String getUserRole(Ref ref) {
    return getContext(ref).role;
  }

  /// 🔒 AUTO tahun ajaran
  String? getTahunAjaranId(Ref ref) {
    return getContext(ref).tahunAjaranId;
  }

  /// 🔒 FILTER LEMBAGA
  PostgrestFilterBuilder applyLembagaFilter({
    required PostgrestFilterBuilder query,
    required String lembagaId,
  }) {
    return query.eq('lembaga_id', lembagaId);
  }

  /// 🔒 FILTER TAHUN AJARAN
  PostgrestFilterBuilder applyTahunAjaranFilter({
    required PostgrestFilterBuilder query,
    String? tahunAjaranId,
  }) {
    if (tahunAjaranId == null) return query;
    return query.eq('tahun_ajaran_id', tahunAjaranId);
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
  PostgrestFilterBuilder applyPagination({
    required PostgrestFilterBuilder query,
    int limit = 10,
    int offset = 0,
  }) {
    return query.range(offset, offset + limit - 1);
  }

  /// 🔽 SORTING
  PostgrestFilterBuilder applyOrder({
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
      if (value == '' || value == 'null') {
        cleaned[key] = null;
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
}