// Lokasi: lib/features/akademik/kurikulum/providers/quran_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'quran_provider.g.dart';

@riverpod
Future<List<Map<String, dynamic>>> quranSurahList(QuranSurahListRef ref) async {
  final supabase = Supabase.instance.client;

  final response = await supabase
      .from('quran_surah')
      .select('id, name_id, nama_latin, total_ayah, juz_start, juz_end')
      .order('id', ascending: true);

  return List<Map<String, dynamic>>.from(response);
}

@riverpod
Future<Map<String, String>> getMushafBounds(GetMushafBoundsRef ref, {int? halaman, int? juz}) async {
  final supabase = Supabase.instance.client;
  var query = supabase.from('quran_lines').select('surah_id, ayat_number');

  if (halaman != null) query = query.eq('halaman_number', halaman);
  if (juz != null) query = query.eq('juz_number', juz);

  final res = await query.order('id', ascending: true);

  if (res.isEmpty) return {'mulai': '', 'akhir': ''};

  final first = res.first;
  final last = res.last;

  return {
    'mulai': "${first['surah_id']}:${first['ayat_number']}",
    'akhir': "${last['surah_id']}:${last['ayat_number']}",
  };
}