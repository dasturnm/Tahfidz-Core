// Lokasi: lib/features/management_lembaga/services/tahun_ajaran_service.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/base_service.dart';
import '../models/tahun_ajaran_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Tambahkan import untuk tipe PostgrestList

class TahunAjaranService extends BaseService {
  /// 1. READ: Ambil semua tahun ajaran per lembaga
  Future<List<TahunAjaranModel>> getTahunAjaran(Ref ref, String lembagaId) async {
    try {
      // Gunakan helper BaseService untuk standarisasi query
      var query = supabase.from('tahun_ajaran').select();

      // Gunakan applyLembagaFilter (id_lembaga)
      // FIX: Casting eksplisit untuk menghindari error invalid_assignment pada Supabase SDK terbaru
      query = applyLembagaFilter(query: query, lembagaId: lembagaId) as PostgrestFilterBuilder<PostgrestList>;

      final data = await query.order('label_tahun', ascending: false);
      return (data as List).map((e) => TahunAjaranModel.fromJson(e)).toList();
    } catch (e) {
      throw handleError(e);
    }
  }

  /// 2. CREATE
  Future<void> addTahunAjaran(Ref ref, TahunAjaranModel ta) async {
    try {
      final data = cleanData(ta.toJson());
      // FIX: Gunakan lembaga_id agar sinkron dengan database dan BaseService
      data['lembaga_id'] = getLembagaId(ref);

      await supabase.from('tahun_ajaran').insert(data);
    } catch (e) {
      throw handleError(e);
    }
  }

  /// 3. UPDATE
  Future<void> updateTahunAjaran(Ref ref, TahunAjaranModel ta) async {
    try {
      final data = cleanData(ta.toJson());
      await supabase.from('tahun_ajaran').update(data).eq('id', ta.id);
    } catch (e) {
      throw handleError(e);
    }
  }

  /// 4. DELETE
  Future<void> deleteTahunAjaran(String id) async {
    try {
      await supabase.from('tahun_ajaran').delete().eq('id', id);
    } catch (e) {
      throw handleError(e);
    }
  }

  /// 5. SET AKTIF (Update di table Lembaga)
  Future<void> setTahunAjaranAktif(Ref ref, String taId) async {
    try {
      final lembagaId = getLembagaId(ref);
      await supabase
          .from('lembaga')
          .update({'tahun_ajaran_aktif_id': taId})
          .eq('id', lembagaId);
    } catch (e) {
      throw handleError(e);
    }
  }
}