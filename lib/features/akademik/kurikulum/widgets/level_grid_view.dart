// lib/features/akademik/kurikulum/widgets/level_grid_view.dart

import 'package:flutter/material.dart';
import '../models/kurikulum_model.dart';

class LevelGridView extends StatelessWidget {
  final List<LevelModel> level;
  final Color primaryColor;
  final Function(LevelModel) onAction;
  final Function(LevelModel) onTap;

  const LevelGridView({
    super.key,
    required this.level,
    required this.primaryColor,
    required this.onAction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: level.length,
      itemBuilder: (context, index) {
        final l = level[index]; // PERBAIKAN: Hindari shadowing variabel 'level'
        return InkWell(
          onTap: () => onTap(l),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04), // PERBAIKAN: withValues
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Icon Menu di pojok kanan atas
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.more_horiz, color: Colors.grey),
                    onPressed: () => onAction(l),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Badge Urutan
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1), // PERBAIKAN: withValues
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "LEVEL ${l.urutan}",
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l.namaLevel,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      // Visual Target
                      Row(
                        children: [
                          Icon(Icons.track_changes_rounded, size: 14, color: Colors.grey[400]),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "Target: ${l.targetTotal} ${l.metrik}",
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.auto_stories_outlined, size: 14, color: Colors.grey[400]),
                          const SizedBox(width: 6),
                          Text(
                            "${l.modul.length} Modul", // PERBAIKAN: Sync ke model singular 'modul'
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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