// Lokasi: lib/features/mutabaah/services/layanan_simpan_mutabaah.dart
part of 'mutabaah_service.dart';

class LayananSimpanMutabaah {
  final MutabaahTahfidzService _mainService;
  LayananSimpanMutabaah(this._mainService);

  SupabaseClient get supabase => _mainService.supabase;

  Future<void> submitRecord(MutabaahRecord record) async {
    try {
      final data = _mainService.cleanData(record.toJson());

      // FIX: Pastikan kolom kritikal tidak hilang meski cleanData agresif
      data['end_surah_id'] = record.endSurahId;
      data['total_baris'] = record.totalBaris;

      if (record.id == null) {
        data.remove('id');
      }

      await supabase.from('mutabaah_records').insert(data);

      await _mainService._kecerdasanAkademik._evaluateExamReadiness(record.siswaId, record.modulId);
      await _mainService._kecerdasanAkademik._evaluateStudentPromotion(record.siswaId);
    } catch (e) {
      throw Exception(_mainService.handleError(e));
    }
  }
}