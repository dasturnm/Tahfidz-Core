import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cabang_model.dart';
// Asumsi nama model: DivisiModel & JabatanModel
// Jika nama file model Anda berbeda, silakan sesuaikan importnya
import '../models/divisi_model.dart';
import '../models/jabatan_model.dart';

part 'lembaga_provider.g.dart';

final _supabase = Supabase.instance.client;

// --- PROVIDER DAFTAR CABANG ---
@riverpod
class CabangList extends _$CabangList {
  @override
  Future<List<CabangModel>> build(String lembagaId) async {
    final data = await _supabase
        .from('cabang')
        .select()
        .eq('lembaga_id', lembagaId)
        .order('nama_cabang');

    return (data as List).map((e) => CabangModel.fromJson(e)).toList();
  }

  Future<void> saveCabang(CabangModel cabang) async {
    final data = Map<String, dynamic>.from(cabang.toJson());
    if (cabang.id.isEmpty) data.remove('id'); // Pastikan ID tidak kosong saat insert baru
    data['lembaga_id'] = lembagaId; // Suntikkan lembagaId agar data muncul di list

    // FIX: Cegah error "invalid input syntax for type date: """ jika tanggal kosong
    if (data['tanggal_berdiri'] == '') data['tanggal_berdiri'] = null;

    await _supabase.from('cabang').upsert(data);
    ref.invalidateSelf();
  }

  Future<void> deleteCabang(String id) async {
    await _supabase.from('cabang').delete().eq('id', id);
    ref.invalidateSelf();
  }
}

// --- PROVIDER DAFTAR DIVISI ---
@riverpod
class DivisiList extends _$DivisiList {
  @override
  Future<List<DivisiModel>> build(String lembagaId) async {
    final data = await _supabase
        .from('divisi')
        .select()
        .eq('lembaga_id', lembagaId)
        .order('nama_divisi');

    return (data as List).map((e) => DivisiModel.fromJson(e)).toList();
  }

  Future<void> saveDivisi(DivisiModel divisi) async {
    final data = Map<String, dynamic>.from(divisi.toJson());
    if (divisi.id.isEmpty) data.remove('id'); // Pastikan ID tidak kosong saat insert baru
    data['lembaga_id'] = lembagaId; // Suntikkan lembagaId agar data muncul di list
    await _supabase.from('divisi').upsert(data);
    ref.invalidateSelf();
  }

  // --- TAMBAHKAN METHOD DELETE ---
  Future<void> deleteDivisi(String id) async {
    await _supabase.from('divisi').delete().eq('id', id);
    ref.invalidateSelf();
  }
}

// --- PROVIDER DAFTAR JABATAN ---
@riverpod
class JabatanList extends _$JabatanList {
  @override
  Future<List<JabatanModel>> build(String lembagaId) async {
    final data = await _supabase
        .from('jabatan')
        .select()
        .eq('lembaga_id', lembagaId)
        .order('nama_jabatan');

    return (data as List).map((e) => JabatanModel.fromJson(e)).toList();
  }

  Future<void> saveJabatan(JabatanModel jabatan) async {
    final data = Map<String, dynamic>.from(jabatan.toJson());
    if (jabatan.id.isEmpty) data.remove('id'); // Pastikan ID tidak kosong saat insert baru
    data['lembaga_id'] = lembagaId; // Suntikkan lembagaId agar data muncul di list
    await _supabase.from('jabatan').upsert(data);
    ref.invalidateSelf();
  }

  // --- TAMBAHKAN METHOD DELETE ---
  Future<void> deleteJabatan(String id) async {
    await _supabase.from('jabatan').delete().eq('id', id);
    ref.invalidateSelf();
  }
}