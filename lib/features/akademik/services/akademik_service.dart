// Lokasi: lib/features/akademik/services/akademik_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/base_service.dart';
import '../../program/models/program_model.dart';
import '../kurikulum/models/kurikulum_model.dart'; // Tambahan: Menggunakan model terpusat
// FIX: Memperbaiki typo "porgram" menjadi "program" agar URI ditemukan
import 'package:tahfidz_core/features/program/models/agenda_model.dart';

class AkademikService extends BaseService {
  /// Mengambil daftar semua Program yang statusnya 'aktif'
  /// FIX: Menerima lembagaId langsung, mendukung filter cabang
  Future<List<ProgramModel>> getProgram({
    required String lembagaId,
    String? cabangId,
  }) async {
    try {
      // Gunakan instance 'supabase' dari BaseService
      PostgrestFilterBuilder query = supabase
          .from('program')
          .select()
          .eq('status', 'aktif'); // Hanya ambil program yang masih aktif

      // 🔥 EXPLICIT-SAFE: Filter berdasarkan lembaga dengan casting tipe data
      query = applyLembagaFilter(query: query, lembagaId: lembagaId) as PostgrestFilterBuilder<PostgrestList>;

      // FIX: Filter berdasarkan Cabang jika ada (Aturan 4 - Anti Data Leak)
      if (cabangId != null && cabangId.isNotEmpty) {
        query = query.eq('cabang_id', cabangId);
      }

      final response = await query.order('nama_program', ascending: true);

      return (response as List).map((json) => ProgramModel.fromJson(json)).toList();
    } catch (e) {
      // Gunakan handleError dari BaseService
      throw Exception(handleError(e));
    }
  }

  /// Mengambil daftar semua Level dari kurikulum_level
  /// FIX: Menerima lembagaId langsung
  Future<List<LevelModel>> getLevel({required String lembagaId}) async {
    try {
      PostgrestFilterBuilder query = supabase
          .from('kurikulum_level')
          .select();

      // 🔥 EXPLICIT-SAFE: Filter berdasarkan lembaga dengan casting tipe data
      query = applyLembagaFilter(query: query, lembagaId: lembagaId) as PostgrestFilterBuilder<PostgrestList>;

      final response = await query.order('nama_level', ascending: true);

      return (response as List).map((json) => LevelModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  // --- AGENDA AKADEMIK ---

  Future<List<AgendaModel>> fetchAgendas({
    required String lembagaId,
    String? tahunAjaranId,
    String? programId,
  }) async {
    try {
      PostgrestFilterBuilder query = supabase.from('agenda_akademik').select();

      // 🔥 EXPLICIT-SAFE: Filter berdasarkan lembaga dengan casting tipe data
      query = applyLembagaFilter(query: query, lembagaId: lembagaId) as PostgrestFilterBuilder<PostgrestList>;

      // Filter berdasarkan Tahun Ajaran aktif
      if (tahunAjaranId != null && tahunAjaranId.isNotEmpty) {
        query = query.eq('tahun_ajaran_id', tahunAjaranId);
      }

      if (programId != null && programId.isNotEmpty) {
        query = query.or('program_id.eq.$programId,program_id.is.null');
      }

      final response = await query.order('tanggal_mulai', ascending: true);
      return (response as List).map((e) => AgendaModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  Future<void> addAgenda(AgendaModel agenda, {bool isRecurring = false, DateTime? untilDate}) async {
    try {
      List<Map<String, dynamic>> batchData = [];
      DateTime currentStart = agenda.tanggalMulai;
      DateTime currentEnd = agenda.tanggalBerakhir;

      // Logika looping untuk Physical Generation (Opsi B)
      while (true) {
        batchData.add(cleanData({
          'lembaga_id': agenda.lembagaId,
          'tahun_ajaran_id': agenda.tahunAjaranId,
          'nama_agenda': agenda.namaAgenda,
          // FIX: Format YYYY-MM-DD agar sinkron dengan tipe 'date' di DB
          'tanggal_mulai': currentStart.toIso8601String().split('T')[0],
          'tanggal_berakhir': currentEnd.toIso8601String().split('T')[0],
          'status_hari_belajar': agenda.statusHariBelajar,
          'scope': agenda.scope,
          'program_id': agenda.programId,
          'keterangan': agenda.keterangan,
          'is_siswa_libur': agenda.isSiswaLibur,
          'is_guru_masuk': agenda.isGuruMasuk,
        }));

        // Berhenti jika tidak berulang atau tidak ada batas tanggal
        if (!isRecurring || untilDate == null) break;

        // Tambah 1 bulan untuk iterasi berikutnya (Bulanan sesuai diskusi)
        currentStart = DateTime(currentStart.year, currentStart.month + 1, currentStart.day);
        currentEnd = DateTime(currentEnd.year, currentEnd.month + 1, currentEnd.day);

        // Berhenti jika sudah melewati batas tanggal yang ditentukan
        if (currentStart.isAfter(untilDate)) break;
      }

      await supabase.from('agenda_akademik').insert(batchData);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  Future<void> updateAgenda(AgendaModel agenda) async {
    try {
      final data = cleanData({
        'tahun_ajaran_id': agenda.tahunAjaranId,
        'nama_agenda': agenda.namaAgenda,
        // FIX: Format YYYY-MM-DD agar sinkron dengan tipe 'date' di DB
        'tanggal_mulai': agenda.tanggalMulai.toIso8601String().split('T')[0],
        'tanggal_berakhir': agenda.tanggalBerakhir.toIso8601String().split('T')[0],
        'status_hari_belajar': agenda.statusHariBelajar,
        'scope': agenda.scope,
        'program_id': agenda.programId,
        'keterangan': agenda.keterangan,
        'is_siswa_libur': agenda.isSiswaLibur,
        'is_guru_masuk': agenda.isGuruMasuk,
      });
      // FIX: Null-safety bang operator (!) untuk ID
      await supabase.from('agenda_akademik').update(data).eq('id', agenda.id!);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  Future<void> deleteAgenda(String id) async {
    try {
      await supabase.from('agenda_akademik').delete().eq('id', id);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  // --- KALENDER AKADEMIK ---

  Future<List<AgendaModel>> fetchAgendasForMonth({
    required String lembagaId,
    required DateTime firstDay,
    required DateTime lastDay,
  }) async {
    try {
      PostgrestFilterBuilder query = supabase.from('agenda_akademik').select();

      // 🔥 EXPLICIT-SAFE: Filter berdasarkan lembaga dengan casting tipe data
      query = applyLembagaFilter(query: query, lembagaId: lembagaId) as PostgrestFilterBuilder<PostgrestList>;

      final response = await query
      // FIX: Format YYYY-MM-DD agar sinkron dengan tipe 'date' di DB
          .gte('tanggal_mulai', firstDay.toIso8601String().split('T')[0])
          .lte('tanggal_mulai', lastDay.toIso8601String().split('T')[0])
          .order('tanggal_mulai', ascending: true);

      return (response as List).map((e) => AgendaModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception(handleError(e));
    }
  }
}