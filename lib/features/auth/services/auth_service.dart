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
  // FIX: Menggunakan Isolated Client agar Admin TIDAK ter-logout otomatis
  Future<String?> registerGuru({
    required String nama,
    required String email,
    required String noHp,
    required String password,
    required String lembagaId,
  }) async {
    try {
      // FIX: Mengambil URL dan Key secara dinamis dari client yang sudah ada
      const supabaseUrl = 'https://mrxtnwmyqfmfdncdvssh.supabase.co';
      // SAFE LOGIC: Gunakan fallback (??) alih-alih memaksa dengan tanda seru (!) agar tidak crash
      const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1yeHRud215cWZtZmRuY2R2c3NoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAyMTY3NjUsImV4cCI6MjA4NTc5Mjc2NX0.r_sJKRw0aGasBVgn9BlbGVQ_VAJ4I3EBUrxg_Poju-w';

      // Membuat client terisolasi agar sesi Admin TIDAK tertimpa/logout
      // FIX: Gunakan AuthFlowType.implicit agar tidak butuh asyncStorage (PKCE) pada client sementara ini
      final tempClient = SupabaseClient(
        supabaseUrl,
        supabaseKey,
        authOptions: const AuthClientOptions(authFlowType: AuthFlowType.implicit),
      );

      // 1. Daftarkan ke Supabase Auth menggunakan client sementara
      final authRes = await tempClient.auth.signUp(
        email: email.trim().toLowerCase(),
        password: password,
        // Opsi: Simpan metadata user langsung di Auth (cadangan)
        data: {
          'nama_lengkap': nama.trim(),
          'role': 'guru',
        },
      );

      final user = authRes.user;
      if (user == null) {
        throw 'Gagal membuat akun login guru. Pastikan email belum terdaftar.';
      }

      final newUserId = user.id; // SAFE LOGIC: Tanpa tanda seru (!)

      // 2. Simpan ke tabel profiles menggunakan client utama (_supabase)
      // Karena kita menggunakan tempClient untuk Auth, _supabase di sini MASIH Admin
      await _supabase.from('profiles').insert({
        'id': newUserId,
        'lembaga_id': lembagaId,
        'nama_lengkap': nama.trim(),
        'no_hp': noHp.trim(),
        'role': 'guru',
        'status': 'aktif', // Default aktif
        'is_new_user': true, // Penanda untuk ganti password nanti
      });

      // 3. Kita tidak lagi membutuhkan logout otomatis di sini
      return newUserId;
    } catch (e) {
      rethrow; // Lempar error ke UI agar ditangani secara berurutan di satu pintu
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

    final user = authRes.user;
    if (user == null) {
      throw 'Gagal mendaftarkan akun auth.';
    }

    final userId = user.id; // SAFE LOGIC: Tanpa tanda seru (!)

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