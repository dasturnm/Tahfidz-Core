// lib/features/akademik/kurikulum/widgets/jenjang_grid_view.dart

import 'package:flutter/material.dart';
import '../models/kurikulum_model.dart';

class JenjangGridView extends StatelessWidget {
  final List<JenjangModel> jenjangs;
  final Function(JenjangModel) onTap;

  const JenjangGridView({
    super.key,
    required this.jenjangs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color emerald = Color(0xFF10B981);

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: jenjangs.length,
      itemBuilder: (context, index) {
        final jenjang = jenjangs[index];
        return InkWell(
          onTap: () => onTap(jenjang),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [
                BoxShadow(
                  color: emerald.withValues(alpha: 0.05), // PERBAIKAN: withValues
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ikon Visual
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: emerald.withValues(alpha: 0.1), // PERBAIKAN: withValues
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.account_tree_outlined, color: emerald, size: 20),
                  ),
                  const Spacer(),
                  // Info Jenjang
                  Text(
                    jenjang.namaJenjang,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1E293B),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${jenjang.levels.length} Tingkatan/Level",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}