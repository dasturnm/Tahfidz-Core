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
  final List<CabangModel> availableCabang;
  final bool isLoading;

  AppContextState({
    this.lembaga,
    this.currentCabang,
    this.currentTahunAjaran,
    this.availableCabang = const [],
    this.isLoading = false,
  });

  AppContextState copyWith({
    LembagaModel? lembaga,
    CabangModel? currentCabang,
    TahunAjaranModel? currentTahunAjaran,
    List<CabangModel>? availableCabang,
    bool? isLoading,
  }) {
    return AppContextState(
      lembaga: lembaga ?? this.lembaga,
      currentCabang: currentCabang ?? this.currentCabang,
      currentTahunAjaran: currentTahunAjaran ?? this.currentTahunAjaran,
      availableCabang: availableCabang ?? this.availableCabang,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

@riverpod
class AppContext extends _$AppContext {
  final _supabase = Supabase.instance.client;

  @override
  AppContextState build() {
    // Inisialisasi dengan state kosong
    return AppContextState();
  }

  // Tambahkan metode ini di dalam class AppContext (notifier)
  Future<void> updateLembaga({
    required String nama,
    String? alamat,
    String? kontak,
    String? logoUrl,
    String? emailOfficial,
    String? visi,
    String? misi,
  }) async {
    if (state.lembaga == null) return;

    final updatedLembaga = state.lembaga!.copyWith(
      namaLembaga: nama,
      alamat: alamat,
      kontak: kontak,
      logoUrl: logoUrl,
      emailOfficial: emailOfficial,
      visi: visi,
      misi: misi,
    );

    await _supabase
        .from('lembaga')
        .update(updatedLembaga.toJson())
        .eq('id', updatedLembaga.id);

    // Update state global agar Dashboard & UI lainnya langsung berubah
    state = state.copyWith(lembaga: updatedLembaga);
  }

  // --- FUNGSI INISIALISASI SAAT LOGIN ---
  Future<void> initContext() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      // 1. Ambil Profil & Lembaga
      final profileData = await _supabase
          .from('profiles')
          .select('*, lembaga:lembaga_id(*)')
          .eq('id', user.id)
          .single();

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
        final taData = await _supabase
            .from('tahun_ajaran')
            .select()
            .eq('id', lembaga.tahunAjaranAktifId!)
            .single();
        tahunAktif = TahunAjaranModel.fromJson(taData);
      }

      // 4. Update State
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
    // Di sini kamu bisa menambahkan refresh data provider lain jika perlu
  }
}