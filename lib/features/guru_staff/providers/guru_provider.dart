import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/guru_model.dart';

part 'guru_provider.g.dart';

@riverpod
class GuruList extends _$GuruList {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<GuruModel>> build() async {
    // 1. Ambil user yang sedang login
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    // 2. Ambil lembaga_id dari profile user tersebut
    final profile = await _supabase
        .from('profiles')
        .select('lembaga_id')
        .eq('id', user.id)
        .single();

    // 3. Ambil semua data dengan role 'guru' di lembaga yang sama
    // Ditambahkan join ke tabel divisi dan penugasan_staf (Cabang & Jabatan)
    final response = await _supabase
        .from('profiles')
        .select('*, divisi:divisi_id(nama_divisi), penugasan_staf(cabang:cabang_id(nama_cabang), jabatan:jabatan_id(nama_jabatan))')
        .eq('lembaga_id', profile['lembaga_id'])
        .eq('role', 'guru')
        .order('nama_lengkap', ascending: true);

    // 4. Mapping data Map dari Supabase ke GuruModel
    return (response as List).map((json) {
      // Ambil data penugasan pertama jika ada (Relasi One-to-Many di Supabase dibaca sebagai List)
      final penugasan = (json['penugasan_staf'] as List?)?.isNotEmpty == true
          ? json['penugasan_staf'][0]
          : null;

      return GuruModel.fromJson({
        ...json,
        'nama': json['nama_lengkap'], // Sinkronisasi nama kolom
        'namaDivisi': json['divisi']?['nama_divisi'], // Sinkronisasi hasil join divisi
        'namaCabang': penugasan?['cabang']?['nama_cabang'], // Sinkronisasi hasil join cabang
        'namaJabatan': penugasan?['jabatan']?['nama_jabatan'], // Sinkronisasi hasil join jabatan
      });
    }).toList();
  }

  // --- Fungsi yang sudah kamu buat sebelumnya tetap terjaga ---

  // Fungsi untuk Menambah/Edit Guru
  Future<void> upsertGuru(Map<String, dynamic> data) async {
    await _supabase.from('profiles').upsert(data);
    ref.invalidateSelf(); // Refresh data otomatis
  }

  // Fungsi untuk Nonaktifkan Guru (Soft Delete)
  Future<void> toggleStatus(String id, String currentStatus) async {
    final newStatus = currentStatus == 'aktif' ? 'nonaktif' : 'aktif';
    await _supabase.from('profiles').update({'status': newStatus}).eq('id', id);
    ref.invalidateSelf();
  }
}