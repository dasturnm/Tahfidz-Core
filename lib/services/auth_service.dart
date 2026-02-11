import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'auth_service.g.dart';

// KODE BARU (Sesuai saran Flutter)
@riverpod
AuthService authService(Ref ref) { // Ganti AuthServiceRef jadi Ref
  return AuthService();
}

class AuthService {
  final _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;

  // --- 1. REGISTER GURU (Oleh Admin) ---
  // Catatan: Fungsi ini akan membuat Admin ter-logout otomatis
  // karena Supabase Client beralih sesi ke user baru yang dibuat.
  Future<void> registerGuru({
    required String nama,
    required String email,
    required String noHp,
    required String password,
    required String lembagaId,
  }) async {
    try {
      // 1. Daftarkan ke Supabase Auth
      final authRes = await _supabase.auth.signUp(
        email: email.trim().toLowerCase(),
        password: password,
        // Opsi: Simpan metadata user langsung di Auth (cadangan)
        data: {
          'nama_lengkap': nama.trim(),
          'role': 'guru',
        },
      );

      if (authRes.user == null) {
        throw 'Gagal membuat akun login guru. User null.';
      }

      final newUserId = authRes.user!.id;

      // 2. Simpan ke tabel profiles
      // Karena admin terlogout, insert ini dilakukan oleh "User Baru" (Guru)
      // Pastikan RLS di tabel profiles mengizinkan "User bisa insert profilnya sendiri"
      await _supabase.from('profiles').insert({
        'id': newUserId,
        'lembaga_id': lembagaId,
        'nama_lengkap': nama.trim(),
        'no_hp': noHp.trim(),
        'role': 'guru',
        'status': 'aktif', // Default aktif
        'is_new_user': true, // Penanda untuk ganti password nanti
      });

      // 3. Logout sesi guru agar Admin bisa login kembali di layar login
      await _supabase.auth.signOut();

    } catch (e) {
      // Jika gagal di tengah jalan, pastikan kita tidak meninggalkan sesi nyangkut
      if (_supabase.auth.currentUser != null) {
        await _supabase.auth.signOut();
      }
      rethrow; // Lempar error ke UI agar muncul di SnackBar
    }
  }

  // --- 2. AMBIL PROFILE ---
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return response;
    } catch (e) {
      // Return null jika gagal ambil profile (misal koneksi putus)
      return null;
    }
  }

  // --- 3. LOGIN HYBRID (Email & Phone Masking) ---
  Future<AuthResponse> signIn(String identity, String password) async {
    String username = identity.trim();

    // Logika: Jika tidak ada '@', anggap No HP & tambahkan domain dummy
    if (!username.contains('@')) {
      username = '$username@tahfidz.com';
    } else {
      username = username.toLowerCase();
    }

    return await _supabase.auth.signInWithPassword(
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
    final cleanEmail = emailAdmin.trim().toLowerCase();
    final cleanNamaLembaga = namaLembaga.trim();
    final cleanNamaAdmin = namaAdmin.trim();

    // A. Buat Akun Auth
    final authRes = await _supabase.auth.signUp(
      email: cleanEmail,
      password: password,
    );

    if (authRes.user == null) {
      throw 'Gagal mendaftarkan akun auth.';
    }

    final userId = authRes.user!.id;

    try {
      // B. Simpan Lembaga
      final lembagaData = await _supabase
          .from('lembaga')
          .insert({'nama_lembaga': cleanNamaLembaga})
          .select()
          .single();

      // C. Simpan Profile Admin (Link ke Lembaga tadi)
      await _supabase.from('profiles').insert({
        'id': userId,
        'lembaga_id': lembagaData['id'], // Ambil ID lembaga yang baru dibuat
        'nama_lengkap': cleanNamaAdmin,
        'role': 'admin_lembaga',
        'status': 'aktif',
        'is_new_user': false,
      });

    } catch (e) {
      // Opsional: Hapus user auth jika insert data gagal agar bisa daftar ulang
      // await _supabase.rpc('delete_user_by_id', params: {'user_id': userId});
      rethrow;
    }
  }

  // --- 5. FITUR RESET PASSWORD ---

  // Kirim Link Reset
  Future<void> sendPasswordResetEmail(String email) async {
    await _supabase.auth.resetPasswordForEmail(email.trim().toLowerCase());
  }

  // Update Password Baru
  Future<void> updatePassword(String newPassword) async {
    await _supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  // Logout
  Future<void> signOut() async => await _supabase.auth.signOut();
}