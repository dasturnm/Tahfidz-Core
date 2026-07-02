import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class UserProfileMenu extends StatelessWidget {
  const UserProfileMenu({super.key});

  @override
  Widget build(BuildContext context) {
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

    final nama = user.userMetadata?['full_name'] ?? 'Pengguna';
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
        if (value == 'logout') {
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