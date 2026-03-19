// lib/features/akademik/kurikulum/widgets/modul_grid_view.dart

import 'package:flutter/material.dart';
import '../models/kurikulum_model.dart';

class ModulGridView extends StatelessWidget {
  final List<ModulModel> modul;
  final Function(ModulModel) onAction;
  final Function(ModulModel) onTap;

  const ModulGridView({
    super.key,
    required this.modul,
    required this.onAction,
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
      itemCount: modul.length,
      itemBuilder: (context, index) {
        final m = modul[index]; // PERBAIKAN: Hindari shadowing variabel 'modul'
        return InkWell(
          onTap: () => onTap(m),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.more_horiz, color: Colors.grey),
                    onPressed: () => onAction(m),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: emerald.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          m.tipe.toUpperCase(),
                          style: const TextStyle(color: emerald, fontWeight: FontWeight.bold, fontSize: 9),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        m.namaModul,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            "${m.targetPertemuan} Pertemuan",
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}