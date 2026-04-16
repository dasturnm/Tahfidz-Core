// Lokasi: lib/features/management_lembaga/services/cabang_service.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Ditambahkan untuk tipe data PostgrestList
import '../../../core/services/base_service.dart';
import '../models/cabang_model.dart';

class CabangService extends BaseService {
  /// 1. READ: Mengambil daftar cabang berdasarkan lembaga yang aktif
  Future<List<CabangModel>> getCabang(Ref ref) async {
    try {
      final lembagaId = getLembagaId(ref);

      // Gunakan query builder dasar
      var query = supabase.from('cabang').select();

      // 🔥 SMART: Gunakan filter standar dari BaseService (ditambahkan cast PostgrestList)
      // FIX: Casting ke PostgrestFilterBuilder<PostgrestList> untuk menghindari invalid_assignment
      query = applyLembagaFilter(query: query, lembagaId: lembagaId) as PostgrestFilterBuilder<PostgrestList>;

      // Sorting
      final response = await query.order('nama_cabang', ascending: true);

      return (response as List)
          .map((e) => CabangModel.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// 2. CREATE/UPDATE: Simpan data cabang
  Future<void> saveCabang(Ref ref, CabangModel cabang) async {
    try {
      final data = cleanData(cabang.toJson());
      // FIX: Gunakan lembaga_id agar sinkron dengan database dan BaseService
      data['lembaga_id'] = getLembagaId(ref);

      // Pastikan ID tidak ikut dikirim jika ini data baru agar UUID digenerate Supabase
      if (cabang.id.isEmpty) data.remove('id');

      await supabase.from('cabang').upsert(data);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// 3. DELETE: Hapus cabang berdasarkan ID
  Future<void> deleteCabang(String id) async {
    try {
      await supabase.from('cabang').delete().eq('id', id);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }
}