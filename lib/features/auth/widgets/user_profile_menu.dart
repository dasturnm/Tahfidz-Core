import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:tahfidz_core/core/providers/app_context_provider.dart';

class UserProfileMenu extends ConsumerWidget {
  const UserProfileMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        ),
      );
    }

    final contextState = ref.watch(appContextProvider);
    final nama = contextState.profile?.namaLengkap ?? user.userMetadata?['full_name'] ?? 'Pengguna';
    final role = (contextState.role ?? "User").toUpperCase();
    final email = user.email ?? 'Email tidak tersedia';
    final avatarUrl = user.userMetadata?['avatar_url'] ?? '';

    return PopupMenuButton<String>(
      offset: const Offset(0, 56),
      tooltip: 'Profil Pengguna',
      icon: CircleAvatar(
        radius: 16,
        backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
        child: avatarUrl.isEmpty ? const Icon(Icons.person, size: 20) : null,
      ),
      onSelected: (value) async {
        if (value == 'profile') {
          context.go('/profile');
        } else if (value == 'logout') {
          await Supabase.instance.client.auth.signOut();
          if (context.mounted) {
            context.go('/login');
          }
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nama,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                role,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF10B981),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person_outline, size: 20),
              SizedBox(width: 12),
              Text('Profil Saya'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, color: Colors.redAccent, size: 20),
              SizedBox(width: 12),
              Text(
                'Keluar',
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}