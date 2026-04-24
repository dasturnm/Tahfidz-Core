// Lokasi: lib/features/auth/services/auth_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/base_service.dart';

part 'auth_service.g.dart';

// KODE BARU (Sesuai saran Flutter)
@riverpod
AuthService authService(Ref ref) {
  return AuthService();
}

class AuthService extends BaseService {
  // Menggunakan instance 'supabase' dari BaseService

  User? get currentUser => supabase.auth.currentUser;

  // --- 1. REGISTER GURU (Oleh Admin) ---
  // FIX: Menggunakan Isolated Client agar Admin TIDAK ter-logout otomatis
  Future<String?> registerGuru({
    required String nama,
    required String email,
    required String noHp,
    String? jenisKelamin, // TAMBAHAN: Menangkap input gender
    String? nip, // TAMBAHAN: Sinkronisasi metadata
    String? cabangId, // TAMBAHAN: Menangkap input cabang
    String? devisiId, // TAMBAHAN: Menangkap input divisi
    String? jabatanId, // TAMBAHAN: Menangkap input jabatan
    required String password,
    required String lembagaId,
  }) async {
    try {
      // LOGIKA FALLBACK JANGKA PANJANG:
      // Ambil dari environment (Hasil build), jika kosong gunakan data cadangan.
      final String effectiveUrl = const String.fromEnvironment('SUPABASE_URL').isNotEmpty
          ? const String.fromEnvironment('SUPABASE_URL')
          : 'https://mrxtnwmyqfmfdncdvssh.supabase.co';

      final String effectiveKey = const String.fromEnvironment('SUPABASE_ANON_KEY').isNotEmpty
          ? const String.fromEnvironment('SUPABASE_ANON_KEY')
          : 'sb_publishable_OAPUWnbXxiDjKDFMkgvIng_xUKs67lg';

      // Membuat client terisolasi agar sesi Admin TIDAK tertimpa/logout
      final tempClient = SupabaseClient(
        effectiveUrl,
        effectiveKey,
        authOptions: const AuthClientOptions(authFlowType: AuthFlowType.implicit),
      );

      // 1. Daftarkan ke Supabase Auth menggunakan client sementara
      final authRes = await tempClient.auth.signUp(
        email: email.trim().toLowerCase(),
        password: password,
        data: {
          'nama_lengkap': nama.trim(),
          'no_hp': noHp.trim(), // FIX: Masukkan no_hp ke metadata agar tidak null
          'jenis_kelamin': jenisKelamin, // FIX: Masukkan gender ke metadata agar tidak null
          'role': 'guru', // Role awal default
          // FIX: Pastikan semua ID dikirim sebagai NULL (bukan "") agar casting UUID di Postgres tidak Error 500
          'lembaga_id': (lembagaId.isEmpty || lembagaId == 'null') ? null : lembagaId,
          'nip': (nip == null || nip.isEmpty) ? null : nip,
          'cabang_id': (cabangId == null || cabangId.isEmpty) ? null : cabangId,
          'devisi_id': (devisiId == null || devisiId.isEmpty) ? null : devisiId,
          'jabatan_id': (jabatanId == null || jabatanId.isEmpty) ? null : jabatanId,
        },
      );

      final user = authRes.user;
      if (user == null) {
        throw 'Gagal membuat akun login guru. Pastikan email belum terdaftar.';
      }

      final newUserId = user.id;

      // 2. Simpan ke tabel profiles menggunakan client utama (supabase) - Protokol cleanData
      // DIKOMENTARI: Karena Supabase sudah menggunakan Trigger (otomatis insert profil)
      // saat signUp diperanggil, agar tidak terjadi "Duplicate Key" pada profiles_pkey.
      /*
      await supabase.from('profiles').insert(cleanData({
        'id': newUserId,
        'lembaga_id': lembagaId,
        'nama_lengkap': nama.trim(),
        'no_hp': noHp.trim(),
        'role': 'guru',
        'status': 'aktif',
        'is_new_user': true,
      }));
      */

      return newUserId;
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  // --- 2. AMBIL PROFILE ---
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return response;
    } catch (e) {
      return null;
    }
  }

  // --- 3. LOGIN HYBRID (Email & Phone Masking) ---
  Future<AuthResponse> signIn(String identity, String password) async {
    String username = identity.trim();

    if (!username.contains('@')) {
      username = '$username@tahfidz.com';
    } else {
      username = username.toLowerCase();
    }

    return await supabase.auth.signInWithPassword(
      email: username,
      password: password,
    );
  }

  // --- 4. REGISTER LEMBAGA (Untuk Super Admin / Pendaftaran Awal) ---
  Future<void> registerLembaga({
    required String namaLembaga,
    required String namaAdmin,
    required String emailAdmin,
    required String password,
  }) async {
    try {
      final cleanEmail = emailAdmin.trim().toLowerCase();
      final cleanNamaLembaga = namaLembaga.trim();

      // A. Buat Akun Auth
      final authRes = await supabase.auth.signUp(
        email: cleanEmail,
        password: password,
      );

      final user = authRes.user;
      if (user == null) {
        throw 'Gagal mendaftarkan akun auth.';
      }

      // B. Simpan Lembaga - Protokol cleanData
      await supabase
          .from('lembaga')
          .insert(cleanData({'nama_lembaga': cleanNamaLembaga}))
          .select()
          .single();

      // C. Simpan Profile Admin - Protokol cleanData
      // DIKOMENTARI: Karena Supabase sudah menggunakan Trigger (otomatis insert profil)
      // saat signUp dipanggil, agar tidak terjadi "Duplicate Key" pada profiles_pkey.
      /*
      await supabase.from('profiles').insert(cleanData({
        'id': userId,
        'lembaga_id': lembagaData['id'],
        'nama_lengkap': cleanNamaAdmin,
        'role': 'admin_lembaga',
        'status': 'aktif',
        'is_new_user': false,
      }));
      */

    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  // --- 5. FITUR RESET PASSWORD ---

  Future<void> sendPasswordResetEmail(String email) async {
    await supabase.auth.resetPasswordForEmail(email.trim().toLowerCase());
  }

  Future<void> updatePassword(String newPassword) async {
    await supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  Future<void> signOut() async => await supabase.auth.signOut();
}