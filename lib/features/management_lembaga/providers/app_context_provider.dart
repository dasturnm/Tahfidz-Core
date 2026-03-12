import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Perbaiki path import: naik satu tingkat ke folder management_lembaga, lalu masuk ke models
import '../models/lembaga_model.dart';
import '../models/cabang_model.dart';
import '../models/tahun_ajaran_model.dart';

part 'app_context_provider.g.dart';

class AppContextState {
  final LembagaModel? lembaga;
  final CabangModel? currentCabang;
  final TahunAjaranModel? currentTahunAjaran;
  final String? programId;
  final List<CabangModel> availableCabang;
  final bool isLoading;

  AppContextState({
    this.lembaga,
    this.currentCabang,
    this.currentTahunAjaran,
    this.programId,
    this.availableCabang = const [],
    this.isLoading = false,
  });

  AppContextState copyWith({
    LembagaModel? lembaga,
    CabangModel? currentCabang,
    TahunAjaranModel? currentTahunAjaran,
    String? programId,
    List<CabangModel>? availableCabang,
    bool? isLoading,
  }) {
    return AppContextState(
      lembaga: lembaga ?? this.lembaga,
      currentCabang: currentCabang ?? this.currentCabang,
      currentTahunAjaran: currentTahunAjaran ?? this.currentTahunAjaran,
      programId: programId ?? this.programId,
      availableCabang: availableCabang ?? this.availableCabang,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

@Riverpod(keepAlive: true)
class AppContext extends _$AppContext {
  final _supabase = Supabase.instance.client;

  @override
  AppContextState build() {
    // Inisialisasi dengan state kosong
    return AppContextState();
  }

  // --- FUNGSI UPDATE PROFIL LEMBAGA ---
  Future<void> updateLembaga({
    required String nama,
    String? alamat,
    String? kontak,
    String? logoUrl,
    String? emailOfficial,
    String? visi,
    String? misi,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception("Sesi login tidak valid.");

    if (state.lembaga == null) {
      // --- SKENARIO 1: DATA BARU (INSERT) ---
      final response = await _supabase
          .from('lembaga')
          .insert({
        'nama_lembaga': nama,
        'alamat_pusat': alamat,
        'wa_official': kontak,
        'logo_url': logoUrl,
        'email_official': emailOfficial,
        'visi': visi,
        'misi': misi,
      })
          .select()
          .single();

      final newLembaga = LembagaModel.fromJson(response);

      // Tautkan profil dengan lembaga baru
      await _supabase
          .from('profiles')
          .update({'lembaga_id': newLembaga.id})
          .eq('id', user.id);

      // --- OTOMATISASI AKSES ---
      await _supabase
          .from('profile_access')
          .insert({
        'profile_id': user.id,
        'cabang_id': null, // Belum ada cabang saat pertama buat
        'role': 'OWNER',
      });

      state = state.copyWith(lembaga: newLembaga);
    } else {
      // --- SKENARIO 2: SUDAH ADA DATA (UPDATE) ---
      final updatedLembaga = state.lembaga!.copyWith(
        namaLembaga: nama,
        alamat: alamat,
        kontak: kontak,
        logoUrl: logoUrl,
        emailOfficial: emailOfficial,
        visi: visi,
        misi: misi,
      );

      // FIX: Gunakan Map spesifik untuk update guna menghindari konflik RLS/ID di Supabase
      await _supabase
          .from('lembaga')
          .update({
        'nama_lembaga': nama,
        'alamat_pusat': alamat,
        'wa_official': kontak,
        'logo_url': logoUrl,
        'email_official': emailOfficial,
        'visi': visi,
        'misi': misi,
      })
          .eq('id', updatedLembaga.id);

      // Update state global agar Dashboard & UI lainnya langsung berubah
      state = state.copyWith(lembaga: updatedLembaga);
    }
  }

  // --- FUNGSI UPLOAD LOGO ---
  Future<void> uploadLembagaLogo(String filePath) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception("Silakan login kembali.");

    // FIX: Coba ambil data dari database jika memori kosong
    if (state.lembaga == null) {
      await initContext();
      if (state.lembaga == null) throw Exception("Profil lembaga belum dibuat.");
    }

    // Ambil ekstensi asli (jpg/png) agar sesuai dengan SQL Policy
    final String extension = filePath.split('.').last.toLowerCase();
    final fileName = 'logo_${state.lembaga!.id}.$extension';
    final file = File(filePath);

    // 1. Upload ke Storage Bucket 'logos'
    await _supabase.storage.from('logos').upload(
      fileName,
      file,
      fileOptions: const FileOptions(upsert: true),
    );

    // 2. Ambil Public URL
    final String publicUrl = _supabase.storage.from('logos').getPublicUrl(fileName);

    // 3. Update URL di tabel lembaga
    await updateLembaga(
      nama: state.lembaga!.namaLembaga,
      alamat: state.lembaga!.alamat,
      kontak: state.lembaga!.kontak,
      logoUrl: publicUrl,
      emailOfficial: state.lembaga!.emailOfficial,
      visi: state.lembaga!.visi,
      misi: state.lembaga!.misi,
    );
  }

  // --- FUNGSI INISIALISASI SAAT LOGIN ---
  Future<void> initContext() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      // 1. Ambil Profil & Lembaga
      final profileData = await _supabase
          .from('profiles')
          .select('*, lembaga:lembaga_id(*)')
          .eq('id', user.id)
          .single();

      if (profileData['lembaga'] == null) {
        // FIX: Jangan throw Exception. Biarkan state kosong agar user bisa membuat profil.
        state = state.copyWith(
          lembaga: null,
          availableCabang: [],
          currentCabang: null,
          currentTahunAjaran: null,
          isLoading: false,
        );
        return;
      }

      final lembaga = LembagaModel.fromJson(profileData['lembaga']);

      // 2. Ambil Daftar Cabang yang bisa diakses user ini
      final accessData = await _supabase
          .from('profile_access')
          .select('cabang:cabang_id(*)')
          .eq('profile_id', user.id);

      final List<CabangModel> branches = (accessData as List)
          .map((item) => CabangModel.fromJson(item['cabang']))
          .toList();

      // 3. Ambil Tahun Ajaran Aktif
      TahunAjaranModel? tahunAktif;
      if (lembaga.tahunAjaranAktifId != null) {
        try {
          final taData = await _supabase
              .from('tahun_ajaran')
              .select()
              .eq('id', lembaga.tahunAjaranAktifId!)
              .single();
          tahunAktif = TahunAjaranModel.fromJson(taData);
        } catch (taErr) {
          // Abaikan jika tahun ajaran aktif tidak ditemukan
          tahunAktif = null;
        }
      }

      // 4. Update State Akhir
      state = state.copyWith(
        lembaga: lembaga,
        availableCabang: branches,
        currentCabang: branches.isNotEmpty ? branches.first : null,
        currentTahunAjaran: tahunAktif,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  // --- FUNGSI PINDAH CABANG (CONTEXT SWITCHER) ---
  void switchCabang(CabangModel cabang) {
    state = state.copyWith(currentCabang: cabang);
    // Refresh context dilakukan secara implisit oleh provider yang menonton currentCabang
  }

  void setProgramId(String id) {
    state = state.copyWith(programId: id);
  }
}