// Lokasi: lib/features/akademik/kurikulum/services/kurikulum_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tahfidz_core/core/services/base_service.dart';
import 'package:tahfidz_core/features/akademik/kurikulum/models/kurikulum_model.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
// FIX: Import model pendukung dihapus karena semua model (Jenjang, Level, Modul)
// sudah disatukan di dalam kurikulum_model.dart

class KurikulumService extends BaseService {
  // ===========================================================================
  // 1. FETCH SERVICES (READ OPERATIONS)
  // ===========================================================================

  /// 🔍 FETCH KURIKULUM
  /// Mengambil data kurikulum lengkap beserta seluruh hierarkinya
  Future<List<KurikulumModel>> fetchKurikulum({
    required String lembagaId,
    String search = '',
    String status = 'Semua',
    String? programId,
    String? tahunAjaranId,
  }) async {
    try {
      // Menggunakan instance 'supabase' dari BaseService
      // PENYEMPURNAAN: Sertakan target_metrik_kurikulum dalam select
      PostgrestFilterBuilder query = supabase
          .from('kurikulum')
          .select('*, jenjang:jenjang_kurikulum(*, level:kurikulum_level(*, modul:modul_kurikulum(*, target_metrik_kurikulum(*), modul_evaluasi_template(*)))))');

      // Filter Lembaga via Helper BaseService
      // FIX: Casting eksplisit ke PostgrestList untuk menghindari error invalid_assignment
      query = applyLembagaFilter(query: query, lembagaId: lembagaId) as PostgrestFilterBuilder<PostgrestList>;

      if (search.isNotEmpty) {
        query = query.ilike('nama_kurikulum', '%$search%');
      }

      if (status != 'Semua') {
        query = query.eq('status', status.toLowerCase());
      }

      if (programId != null && programId.isNotEmpty) {
        query = query.eq('program_id', programId);
      }

      if (tahunAjaranId != null && tahunAjaranId.isNotEmpty) {
        query = query.eq('tahun_ajaran_id', tahunAjaranId);
      }

      final response = await query.order('nama_kurikulum');
      return (response as List).map((e) => KurikulumModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// 🔍 FETCH KURIKULUM BY PROGRAM (BARU)
  /// Mengambil daftar kurikulum berdasarkan Program ID
  Future<List<KurikulumModel>> getKurikulumByProgram(String programId) async {
    try {
      final response = await supabase
          .from('kurikulum')
          .select('*')
          .eq('program_id', programId)
          .order('nama_kurikulum', ascending: true);

      return (response as List).map((e) => KurikulumModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// 🔍 FETCH LEVELS BY KURIKULUM (BARU)
  /// Mengambil daftar level berdasarkan Kurikulum ID (untuk dropdown berjenjang)
  Future<List<LevelModel>> getLevelsByKurikulum(String kurikulumId) async {
    try {
      final response = await supabase
          .from('kurikulum_level')
          .select('*, jenjang:jenjang_kurikulum(*)')
          .eq('kurikulum_id', kurikulumId)
          .order('urutan', ascending: true);

      return (response as List).map((e) => LevelModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// 🔍 FETCH LEVELS BY PROGRAM
  /// Mengambil daftar level berdasarkan Program ID
  Future<List<LevelModel>> getLevelsByProgram(String programId) async {
    try {
      final response = await supabase
          .from('kurikulum_level')
          .select('*, jenjang:jenjang_kurikulum(*)')
          .eq('program_id', programId)
          .order('urutan', ascending: true);

      return (response as List).map((e) => LevelModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// 🔍 FETCH MODULS BY LEVEL (BARU)
  /// Mengambil daftar modul berdasarkan Level ID
  Future<List<ModulModel>> getModulsByLevel(String levelId) async {
    try {
      final response = await supabase
          .from('modul_kurikulum')
          .select('*')
          .eq('level_id', levelId)
          .order('urutan', ascending: true);

      return (response as List).map((e) => ModulModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  // ===========================================================================
  // 2. SAVE SERVICES (WRITE/DEEP UPSERT OPERATIONS)
  // ===========================================================================

  /// 💾 SAVE KURIKULUM (Deep Upsert)
  /// Menyimpan kurikulum beserta Jenjang, Level, Modul, dan Target Metrik secara berjenjang
  Future<void> saveKurikulum(KurikulumModel kurikulum) async {
    try {
      // FIX: Menggunakan cleanData() untuk proteksi input
      final kurikulumData = cleanData(kurikulum.toJson())..remove('jenjang');
      String kurikulumId;

      if (kurikulum.id == null) {
        final res = await supabase.from('kurikulum').insert(kurikulumData..remove('id')).select().single();
        kurikulumId = res['id'];
      } else {
        await supabase.from('kurikulum').update(kurikulumData).eq('id', kurikulum.id!);
        kurikulumId = kurikulum.id!;
      }

      for (var jenjang in kurikulum.jenjang) {
        // FIX: Menggunakan cleanData()
        final jenjangData = cleanData(jenjang.toJson())
          ..remove('level')
          ..['kurikulum_id'] = kurikulumId;

        String jenjangId;
        if (jenjang.id == null) {
          final res = await supabase.from('jenjang_kurikulum').insert(jenjangData..remove('id')).select().single();
          jenjangId = res['id'];
        } else {
          await supabase.from('jenjang_kurikulum').update(jenjangData).eq('id', jenjang.id!);
          jenjangId = jenjang.id!;
        }

        // 🛡️ VIRTUAL LEVEL LOGIC:
        // Jika jenjang tidak memiliki level (Kurikulum Flat), buat 1 level default secara otomatis.
        // Ini memastikan constraint 'level_id NOT NULL' di tabel modul_kurikulum tetap terpenuhi.
        List<LevelModel> activeLevels = List.from(jenjang.level);
        if (activeLevels.isEmpty) {
          activeLevels.add(LevelModel(
            namaLevel: 'Level Utama',
            urutan: 1,
            kurikulumId: kurikulumId,
            jenjangId: jenjangId,
            programId: kurikulum.programId,
          ));
        }

        for (var level in activeLevels) {
          // FIX: Menggunakan cleanData()
          final levelData = cleanData(level.toJson())
            ..remove('modul')
            ..['jenjang_id'] = jenjangId
            ..['kurikulum_id'] = kurikulumId;

          String levelId;
          if (level.id == null) {
            final res = await supabase.from('kurikulum_level').insert(levelData..remove('id')).select().single();
            levelId = res['id'];
          } else {
            await supabase.from('kurikulum_level').update(levelData).eq('id', level.id!);
            levelId = level.id!;
          }

          for (var modul in level.modul) {
            // FIX LOCAL LOOKUP: Membaca skema koordinat sekuensial dari asset JSON lokal (Offline-First)
            final String jsonContent = await rootBundle.loadString('assets/mushaf_peta.json');
            final List<dynamic> localRows = json.decode(jsonContent) as List<dynamic>;

            final surahRows = localRows.where((r) {
              final sNum = int.tryParse(r['surah_number']?.toString() ?? '') ?? 0;
              return sNum == modul.surahId;
            }).toList();

            Map<String, dynamic>? startRes;
            Map<String, dynamic>? endRes;

            if (surahRows.isNotEmpty) {
              final startMatches = surahRows.where((r) {
                final start = int.tryParse(r['ayah_start']?.toString() ?? '') ?? 0;
                final end = int.tryParse(r['ayah_end']?.toString() ?? '') ?? 0;
                return start <= modul.ayahStart && end >= modul.ayahStart;
              }).toList();
              if (startMatches.isNotEmpty) {
                startMatches.sort((a, b) => (int.tryParse(a['koordinat_baris']?.toString() ?? '') ?? 0)
                    .compareTo(int.tryParse(b['koordinat_baris']?.toString() ?? '') ?? 0));
                startRes = startMatches.first;
              }

              final endMatches = surahRows.where((r) {
                final start = int.tryParse(r['ayah_start']?.toString() ?? '') ?? 0;
                final end = int.tryParse(r['ayah_end']?.toString() ?? '') ?? 0;
                return start <= modul.ayahEnd && end >= modul.ayahEnd;
              }).toList();
              if (endMatches.isNotEmpty) {
                endMatches.sort((a, b) => (int.tryParse(a['koordinat_baris']?.toString() ?? '') ?? 0)
                    .compareTo(int.tryParse(b['koordinat_baris']?.toString() ?? '') ?? 0));
                endRes = endMatches.first;
              }
            }

            int calculatedTotalBaris = 0;

            if (startRes != null && endRes != null) {
              final startKoor = int.tryParse(startRes['koordinat_baris']?.toString() ?? '') ?? 0;
              final endKoor = int.tryParse(endRes['koordinat_baris']?.toString() ?? '') ?? 0;

              final minKoor = startKoor < endKoor ? startKoor : endKoor;
              final maxKoor = startKoor < endKoor ? endKoor : startKoor;

              calculatedTotalBaris = surahRows.where((r) {
                final koor = int.tryParse(r['koordinat_baris']?.toString() ?? '') ?? 0;
                return koor >= minKoor && koor <= maxKoor;
              }).length;
            }

            // FIX: Menggunakan cleanData() & proteksi dari field nested
            // Tambahkan calculatedTotalBaris ke dalam payload data modul
            final modulData = cleanData(modul.toJson())
              ..remove('target_metrik_kurikulum')
              ..remove('modul_evaluasi_template')
              ..['level_id'] = levelId
              ..['total_baris'] = calculatedTotalBaris;

            String modulId;
            if (modul.id == null) {
              final res = await supabase.from('modul_kurikulum').insert(modulData..remove('id')).select().single();
              modulId = res['id'];
            } else {
              await supabase.from('modul_kurikulum').update(modulData).eq('id', modul.id!);
              modulId = modul.id!;
            }

            // SIMPAN: Target Metrik Kurikulum (Relasi terbawah)
            for (var target in modul.targetMetrik) {
              final targetData = cleanData(target.toJson())..['modul_id'] = modulId;
              if (target.id == null) {
                await supabase.from('target_metrik_kurikulum').insert(targetData..remove('id'));
              } else {
                await supabase.from('target_metrik_kurikulum').update(targetData).eq('id', target.id!);
              }
            }

            // SIMPAN: Template Evaluasi Silabus Internal (TAMBAHAN)
            for (var template in modul.evaluasiTemplates) {
              final templateData = cleanData(template.toJson())..['modul_id'] = modulId;
              if (template.id == null || template.id!.isEmpty) {
                await supabase.from('modul_evaluasi_template').insert(templateData..remove('id'));
              } else {
                await supabase.from('modul_evaluasi_template').update(templateData).eq('id', template.id!);
              }
            }
          }
        }
      }
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  // ===========================================================================
  // 3. DELETE SERVICES (REMOVE OPERATIONS)
  // ===========================================================================

  /// 🗑️ DELETE KURIKULUM
  Future<void> deleteKurikulum(String id) async {
    try {
      await supabase.from('kurikulum').delete().eq('id', id);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }
}