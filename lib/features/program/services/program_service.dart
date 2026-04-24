import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/base_service.dart';
import '../models/program_model.dart';

class ProgramService extends BaseService {
  /// 🔍 AMBIL DATA PROGRAM
  Future<List<ProgramModel>> fetchPrograms({
    required String lembagaId,
    String? cabangId,
  }) async {
    try {
      // 🔥 FIX: Tambahkan relasi kurikulum(id) agar ProgramModel bisa mengecek hasKurikulum
      // Menggunakan !kurikulum_id untuk mematikan ambiguitas relasi ganda
      PostgrestFilterBuilder query = supabase.from('program').select('*, kurikulum!kurikulum_id(id)');

      // Gunakan helper BaseService untuk keamanan data
      query = applyLembagaFilter(query: query, lembagaId: lembagaId);

      // Filter Cabang: Milik cabang terpilih ATAU Global
      if (cabangId != null && cabangId.isNotEmpty && cabangId != 'null') {
        query = query.or('cabang_id.eq.$cabangId,cabang_id.is.null');
      }

      // FIX: Tambahkan explicit casting ke PostgrestList dan penanganan null
      final response = await query.order('nama_program');

      if (response == null) return [];

      final data = response as List;
      return data.map((e) => ProgramModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      // Jika terjadi error, pastikan error ditangkap dan dilempar dengan jelas
      throw Exception(handleError(e));
    }
  }

  /// ➕ TAMBAH PROGRAM
  Future<void> addProgram({
    required String lembagaId,
    required String nama,
    String? kurikulumId,
    String? cabangId,
    String? deskripsi,
    double pendaftaran = 0,
    double spp = 0,
    List<String> hari = const [],
  }) async {
    try {
      final data = cleanData({
        'lembaga_id': lembagaId,
        'kurikulum_id': kurikulumId,
        'cabang_id': cabangId,
        'nama_program': nama,
        'deskripsi': deskripsi,
        'biaya_pendaftaran': pendaftaran,
        'biaya_spp': spp,
        'hari_aktif': hari,
      });
      await supabase.from('program').insert(data);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// 📝 UPDATE PROGRAM
  Future<void> updateProgram(ProgramModel updated) async {
    try {
      final data = cleanData({
        'nama_program': updated.namaProgram,
        'kurikulum_id': updated.kurikulumId,
        'cabang_id': updated.cabangId,
        'deskripsi': updated.deskripsi,
        'biaya_pendaftaran': updated.biayaPendaftaran,
        'biaya_spp': updated.biayaSpp,
        'hari_aktif': updated.hariAktif,
      });
      await supabase.from('program').update(data).eq('id', updated.id);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// 🗑️ HAPUS PROGRAM
  Future<void> deleteProgram(String programId) async {
    try {
      await supabase.from('program').delete().eq('id', programId);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }
}