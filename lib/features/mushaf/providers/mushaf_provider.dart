// Lokasi: lib/features/mushaf/providers/mushaf_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/mushaf_model.dart';

final mushafPageProvider = FutureProvider.family<List<MushafLine>, int>((ref, pageNumber) async {
  final supabase = Supabase.instance.client;

  final response = await supabase
      .from('data_mushaf')
      .select()
      .eq('page_number', pageNumber)
      .order('line_number', ascending: true);

  return (response as List).map((e) => MushafLine.fromJson(e)).toList();
});

// StateProvider ini sekarang sangat penting untuk sinkronisasi Index -> MushafView
final currentPageProvider = StateProvider<int>((ref) => 1);

/// Provider untuk menyimpan kata kunci pencarian Surah (Poin 1)
final mushafSearchProvider = StateProvider<String>((ref) => "");

/// Provider untuk mengambil daftar surah unik dari database Supabase (Poin 2)
final surahListProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = Supabase.instance.client;

  // Daftar statis jumlah ayat 114 Surah untuk mencegah error Null
  const surahAyahCounts = [
    7, 286, 200, 176, 120, 165, 206, 75, 129, 109, 123, 111, 43, 52, 99, 128, 111, 110, 98, 135, 112, 78, 118, 64, 77, 227, 93, 88, 69, 60, 34, 30, 73, 54, 45, 83, 182, 88, 75, 85, 54, 53, 89, 59, 37, 35, 38, 29, 18, 45, 60, 49, 62, 55, 78, 96, 29, 22, 24, 13, 14, 11, 11, 18, 12, 12, 30, 52, 52, 44, 28, 28, 20, 56, 40, 31, 50, 40, 46, 42, 29, 19, 36, 25, 22, 17, 19, 26, 30, 20, 15, 21, 11, 8, 8, 19, 5, 8, 8, 11, 11, 8, 3, 9, 5, 4, 7, 3, 6, 3, 5, 4, 5, 6
  ];

  // Mengambil kolom yang diperlukan untuk daftar isi (Halaman awal surah)
  // Gunakan eq('ayah_number', 1) saja agar semua 114 surah terjaring tanpa peduli barisnya
  final response = await supabase
      .from('data_mushaf')
      .select('surah_number, surah_name, page_number')
      .eq('ayah_number', 1)
      .order('surah_number', ascending: true);

  final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(response);
  final uniqueSurahs = <int, Map<String, dynamic>>{};

  // Filter agar hanya mengambil satu entry per nomor surah (Halaman awal surah)
  for (var item in data) {
    final sNum = (item['surah_number'] as num).toInt();
    if (!uniqueSurahs.containsKey(sNum)) {
      // FIX: Injeksi total_ayah agar UI ModulFormScreen tidak crash
      item['total_ayah'] = surahAyahCounts[sNum - 1];
      uniqueSurahs[sNum] = item;
    }
  }

  return uniqueSurahs.values.toList();
});