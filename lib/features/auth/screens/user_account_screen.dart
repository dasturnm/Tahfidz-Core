import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:tahfidz_core/core/providers/app_context_provider.dart';
import 'package:tahfidz_core/features/auth/providers/auth_provider.dart';

class UserAccountScreen extends ConsumerStatefulWidget {
  const UserAccountScreen({super.key});

  @override
  ConsumerState<UserAccountScreen> createState() => _UserAccountScreenState();
}

class _UserAccountScreenState extends ConsumerState<UserAccountScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fade = CurvedAnimation(parent: _animationController, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, .08), end: Offset.zero).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authUser = Supabase.instance.client.auth.currentUser;
    final contextState = ref.watch(appContextProvider);

    final nama = contextState.profile?.namaLengkap ?? authUser?.userMetadata?['full_name'] ?? 'Pengguna';
    final email = authUser?.email ?? 'Email tidak tersedia';
    final role = (contextState.role ?? 'GUEST').toUpperCase();
    final avatarUrl = authUser?.userMetadata?['avatar_url'] ?? '';

    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _animationController.forward());
    }

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.white,
        title: const Text("Profil Saya", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xff0F172A))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                FadeTransition(opacity: _fade, child: SlideTransition(position: _slide, child: _buildPremiumHeader(nama, email, role, avatarUrl))),
                const SizedBox(height: 32),

                // QUICK ACTION
                FadeTransition(opacity: _fade, child: Row(children: [Expanded(child: _quickAction(Icons.camera_alt_outlined, "Foto", () {})), const SizedBox(width: 12), Expanded(child: _quickAction(Icons.lock_outline, "Password", () => _showPasswordSheet())), const SizedBox(width: 12), Expanded(child: _quickAction(Icons.person_outline, "Profil", () {})), const SizedBox(width: 12), Expanded(child: _quickAction(Icons.settings_outlined, "Setting", () {}))])),
                const SizedBox(height: 32),

                // STATISTIK
                FadeTransition(opacity: _fade, child: Row(children: [Expanded(child: _statCard("Status", "Aktif", Icons.verified)), const SizedBox(width: 14), Expanded(child: _statCard("Role", role, Icons.workspace_premium_outlined)), const SizedBox(width: 14), Expanded(child: _statCard("Lembaga", contextState.lembaga?.namaLembaga ?? "-", Icons.school_outlined))])),
                const SizedBox(height: 42),

                // DATA PRIBADI
                _sectionTitle("DATA PRIBADI"),
                const SizedBox(height: 22),
                _readonlyField(Icons.person_outline, "Nama Lengkap", nama),
                _divider(),
                _readonlyField(Icons.phone_outlined, "WhatsApp", "Belum diisi"),
                _divider(),
                _readonlyField(Icons.email_outlined, "Email", email),
                const SizedBox(height: 42),

                // DATA LEMBAGA
                _sectionTitle("DATA LEMBAGA"),
                const SizedBox(height: 22),
                _readonlyField(Icons.business_outlined, "Nama Lembaga", contextState.lembaga?.namaLembaga ?? "-"),
                _divider(),
                _readonlyField(Icons.badge_outlined, "Jabatan", role),
                _divider(),
                _readonlyField(Icons.numbers, "ID Anggota", contextState.profile?.id ?? "-"),
                const SizedBox(height: 42),

                // PENGATURAN
                _sectionTitle("PENGATURAN"),
                const SizedBox(height: 18),
                _settingTile(Icons.lock_outline, "Ubah Password", () => _showPasswordSheet()),
                _settingTile(Icons.notifications_none, "Notifikasi", () {}),
                _settingTile(Icons.dark_mode_outlined, "Dark Mode", () {}),
                const SizedBox(height: 50),

                // LOGOUT
                Center(child: TextButton.icon(onPressed: () async { await ref.read(authProvider.notifier).logout(); if (context.mounted) context.go("/login"); }, icon: const Icon(Icons.logout, color: Colors.red), label: const Text("Keluar Akun", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)))),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(String nama, String email, String role, String avatarUrl) => Container(height: 240, width: double.infinity, decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xff10B981), Color(0xff059669)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.vertical(bottom: Radius.circular(32))), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircleAvatar(radius: 45, backgroundColor: Colors.white, backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null, child: avatarUrl.isEmpty ? Text(nama[0], style: const TextStyle(fontSize: 30, color: Color(0xff10B981), fontWeight: FontWeight.bold)) : null), const SizedBox(height: 16), Text(nama, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)), Text(email, style: const TextStyle(color: Colors.white70, fontSize: 13))]));
  Widget _sectionTitle(String title) => Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1, color: Color(0xff64748B)));
  Widget _divider() => const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1));
  Widget _quickAction(IconData icon, String label, VoidCallback onTap) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]), child: Column(children: [Icon(icon, color: const Color(0xff10B981)), const SizedBox(height: 4), Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))])));
  Widget _statCard(String label, String value, IconData icon) => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, size: 20, color: const Color(0xff64748B)), const SizedBox(height: 8), Text(label, style: const TextStyle(fontSize: 10, color: Color(0xff64748B))), Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))]));
  Widget _readonlyField(IconData icon, String label, String value) => Row(children: [Icon(icon, color: const Color(0xff64748B), size: 20), const SizedBox(width: 16), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 12, color: Color(0xff64748B))), Text(value, style: const TextStyle(fontSize: 15, color: Color(0xff0F172A), fontWeight: FontWeight.w500))])]);
  Widget _settingTile(IconData icon, String label, VoidCallback onTap) => ListTile(contentPadding: EdgeInsets.zero, leading: Icon(icon, color: const Color(0xff0F172A)), title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)), trailing: const Icon(Icons.chevron_right), onTap: onTap);
  void _showPasswordSheet() => showModalBottomSheet(context: context, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))), builder: (context) => Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [const Text("Ubah Password", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 20), const TextField(decoration: InputDecoration(labelText: "Password Lama", border: OutlineInputBorder())), const SizedBox(height: 16), const TextField(decoration: InputDecoration(labelText: "Password Baru", border: OutlineInputBorder())), const SizedBox(height: 24), SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Simpan")))])));
}