import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cabang_model.dart';

part 'cabang_provider.g.dart';

@riverpod
class CabangList extends _$CabangList {
  @override
  Future<List<CabangModel>> build() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('cabang')
          .select()
          .order('nama_cabang');

      return (response as List).map((e) => CabangModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Error memuat CabangList: $e");
      return [];
    }
  }
}