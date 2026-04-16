// Lokasi: lib/features/mutabaah/services/delegasi_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/base_service.dart';
import '../models/delegasi_model.dart';

class DelegasiService extends BaseService {
  /// 1. CREATE: Membuat delegasi baru (Izin dari Guru Tetap)
  Future<void> createDelegasi(DelegasiModel delegasi) async {
    try {
      final data = cleanData(delegasi.toJson());
      // Hapus ID jika null agar di-generate otomatis
      if (delegasi.id == null) data.remove('id');

      await supabase.from('delegasi_guru').insert(data);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// 2. READ: Mengambil daftar delegasi yang diterima oleh saya (Guru Pengganti)
  Future<List<DelegasiModel>> fetchIncomingDelegations(Ref ref, String myId) async {
    try {
      final lembagaId = getLembagaId(ref);
      final today = DateTime.now().toIso8601String().split('T')[0];

      PostgrestFilterBuilder query = supabase.from('delegasi_guru').select();

      // Filter Lembaga & Penerima Izin & Tanggal Hari Ini & Status Aktif
      final response = await (applyLembagaFilter(query: query, lembagaId: lembagaId)
      as PostgrestFilterBuilder<PostgrestList>)
          .eq('penerima_izin_id', myId)
          .eq('tanggal_izin', today)
          .eq('is_active', true);

      return (response as List).map((json) => DelegasiModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// 3. READ: Mengambil daftar delegasi yang diberikan oleh saya (Guru Tetap)
  Future<List<DelegasiModel>> fetchOutgoingDelegations(Ref ref, String myId) async {
    try {
      final lembagaId = getLembagaId(ref);
      PostgrestFilterBuilder query = supabase.from('delegasi_guru').select();

      final response = await (applyLembagaFilter(query: query, lembagaId: lembagaId)
      as PostgrestFilterBuilder<PostgrestList>)
          .eq('pemberi_izin_id', myId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => DelegasiModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// 4. UPDATE: Mencabut izin delegasi secara manual
  Future<void> revokeDelegasi(String id) async {
    try {
      await supabase
          .from('delegasi_guru')
          .update({'is_active': false})
          .eq('id', id);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }
}