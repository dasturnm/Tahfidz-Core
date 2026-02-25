import 'package:flutter/material.dart';

class AssignmentTimeline extends StatelessWidget {
  final List<dynamic> history; // Data dari tabel riwayat_penugasan

  const AssignmentTimeline({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Center(
        child: Text("Belum ada riwayat penugasan.", style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        final bool isLast = index == history.length - 1;
        final bool isActive = item['tanggal_selesai'] == null;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SISI KIRI: GARIS TIMELINE
            Column(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF10B981) : Colors.grey[300],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      if (isActive) BoxShadow(color: const Color(0xFF10B981).withValues(alpha: 0.3), blurRadius: 8)
                    ],
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 80,
                    color: Colors.grey[200],
                  ),
              ],
            ),
            const SizedBox(width: 20),

            // SISI KANAN: KONTEN
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['tanggal_mulai'] ?? '-',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isActive ? const Color(0xFF10B981) : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['jabatan']?['nama_jabatan'] ?? 'Posisi Tidak Diketahui',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.business, size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              item['cabang']?['nama_cabang'] ?? 'Kantor Pusat',
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                        if (item['keterangan'] != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            "# ${item['keterangan']}",
                            style: const TextStyle(color: Colors.teal, fontSize: 11, fontStyle: FontStyle.italic),
                          ),
                        ]
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}