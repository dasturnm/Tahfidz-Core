// Sesuai aturan SAFE CODE UPDATE & COPY-SAFE
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
    if (!uniqueSurahs.containsKey(item['surah_number'])) {
      uniqueSurahs[item['surah_number']] = item;
    }
  }

  return uniqueSurahs.values.toList();
});