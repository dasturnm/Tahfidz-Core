// Lokasi: lib/features/akademik/kurikulum/widgets/kurikulum_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/kurikulum_model.dart'; // PERBAIKAN: Mundur 1 tingkat saja

class KurikulumCard extends ConsumerWidget {
  final KurikulumModel kurikulum;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap; // TAMBAHAN: Untuk navigasi ke detail

  const KurikulumCard({
    super.key,
    required this.kurikulum,
    this.onEdit,
    this.onDelete,
    this.onTap, // TAMBAHAN
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const bluePrimary = Color(0xFF3B82F6); // Warna Biru sesuai visual foto

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. ICON BOX (Sesuai image_4e5c1b.png)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.format_align_left_rounded, color: Color(0xFF94A3B8), size: 24),
              ),
              const SizedBox(height: 24),

              // 2. JUDUL (Sesuai image_4e5c1b.png)
              Text(
                kurikulum.namaKurikulum,
                style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.5
                ),
              ),
              const SizedBox(height: 8),

              // 3. DESKRIPSI (Sesuai image_4e5c1b.png)
              Text(
                kurikulum.deskripsi ?? 'Fokus pada metrik hafalan berbasis standar kurikulum lembaga.',
                style: const TextStyle(color: Colors.grey, fontSize: 12, height: 1.5),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),

              // 4. BADGES (PERBAIKAN POIN 5: Menampilkan Statistik Lengkap)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // PERBAIKAN: Menambahkan indikator Mode Linear
                  if (kurikulum.isLinear) _buildBadge("LINEAR", Colors.orange),
                  _buildBadge("${kurikulum.jenjangs.length} JENJANG", bluePrimary),
                  // Sembunyikan badge level jika linear karena level bersifat tunggal/bypass
                  if (!kurikulum.isLinear) _buildBadge("${kurikulum.totalLevels} LEVEL", const Color(0xFF64748B)),
                  _buildBadge("${kurikulum.totalModules} MODUL", const Color(0xFF64748B)),
                  // PERBAIKAN: Menggunakan totalTargets sesuai dengan getter di KurikulumModel
                  _buildBadge("${kurikulum.totalTargets} METRIK", const Color(0xFFF59E0B)),
                  _buildBadge(
                      kurikulum.isActive ? "AKTIF" : "DRAFT",
                      kurikulum.isActive ? const Color(0xFF10B981) : const Color(0xFF64748B)
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFF1F5F9), height: 1),
              const SizedBox(height: 12),

              // 5. FOOTER ID & ACTION (Sesuai image_4e5c1b.png)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    // PERBAIKAN: Tambahkan pengecekan panjang string agar tidak crash jika ID pendek
                    kurikulum.id != null && kurikulum.id!.length >= 8
                        ? "ID: ${kurikulum.id!.substring(0, 8).toUpperCase()}"
                        : (kurikulum.id?.toUpperCase() ?? "NEW BLUEPRINT"),
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1
                    ),
                  ),
                  _buildMenuAction(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900),
      ),
    );
  }

  Widget _buildMenuAction() {
    // PERBAIKAN: Bungkus dengan GestureDetector agar klik tidak "tembus" ke InkWell kartu
    return GestureDetector(
      onTap: () {},
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.more_horiz, color: Color(0xFFCBD5E1), size: 18),
        onSelected: (val) {
          if (val == 'edit') onEdit?.call();
          if (val == 'delete') onDelete?.call();
        },
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'edit', child: Text("Edit Kurikulum", style: TextStyle(fontSize: 13))),
          const PopupMenuItem(
            value: 'delete',
            child: Text("Hapus", style: TextStyle(color: Colors.red, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}