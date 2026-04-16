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
    required String password,
    required String lembagaId,
  }) async {
    try {
      // FIX: Menarik konfigurasi dari Environment Variables (Tanpa Hardcoded Key)
      // Pastikan untuk menambahkan --dart-define=SUPABASE_URL="..." dan --dart-define=SUPABASE_ANON_KEY="..." saat build/run
      const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
      const supabaseKey = String.fromEnvironment('SUPABASE_ANON_KEY');

      if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
        throw 'Gagal mendaftarkan guru. Kredensial Supabase (URL/Key) tidak ditemukan di Environment.';
      }

      // Membuat client terisolasi agar sesi Admin TIDAK tertimpa/logout
      final tempClient = SupabaseClient(
        supabaseUrl,
        supabaseKey,
        authOptions: const AuthClientOptions(authFlowType: AuthFlowType.implicit),
      );

      // 1. Daftarkan ke Supabase Auth menggunakan client sementara
      final authRes = await tempClient.auth.signUp(
        email: email.trim().toLowerCase(),
        password: password,
        data: {
          'nama_lengkap': nama.trim(),
          'role': 'guru',
        },
      );

      final user = authRes.user;
      if (user == null) {
        throw 'Gagal membuat akun login guru. Pastikan email belum terdaftar.';
      }

      final newUserId = user.id;

      // 2. Simpan ke tabel profiles menggunakan client utama (supabase) - Protokol cleanData
      await supabase.from('profiles').insert(cleanData({
        'id': newUserId,
        'lembaga_id': lembagaId,
        'nama_lengkap': nama.trim(),
        'no_hp': noHp.trim(),
        'role': 'guru',
        'status': 'aktif',
        'is_new_user': true,
      }));

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
      final cleanNamaAdmin = namaAdmin.trim();

      // A. Buat Akun Auth
      final authRes = await supabase.auth.signUp(
        email: cleanEmail,
        password: password,
      );

      final user = authRes.user;
      if (user == null) {
        throw 'Gagal mendaftarkan akun auth.';
      }

      final userId = user.id;

      // B. Simpan Lembaga - Protokol cleanData
      final lembagaData = await supabase
          .from('lembaga')
          .insert(cleanData({'nama_lembaga': cleanNamaLembaga}))
          .select()
          .single();

      // C. Simpan Profile Admin - Protokol cleanData
      await supabase.from('profiles').insert(cleanData({
        'id': userId,
        'lembaga_id': lembagaData['id'],
        'nama_lengkap': cleanNamaAdmin,
        'role': 'admin_lembaga',
        'status': 'aktif',
        'is_new_user': false,
      }));

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