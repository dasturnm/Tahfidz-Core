// lib/features/akademik/kurikulum/widgets/metrik_grid_view.dart

import 'package:flutter/material.dart';
import '../models/kurikulum_model.dart';

class MetrikGridView extends StatelessWidget {
  final List<TargetMetrikModel> targets;
  final Function(TargetMetrikModel) onAction;

  const MetrikGridView({
    super.key,
    required this.targets,
    required this.onAction,
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
        childAspectRatio: 0.85,
      ),
      itemCount: targets.length,
      itemBuilder: (context, index) {
        final target = targets[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Menu Aksi
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.more_horiz, color: Colors.grey),
                  onPressed: () => onAction(target),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Badge Tipe Metrik
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: emerald.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        target.jenisMetrik.toUpperCase(),
                        style: const TextStyle(
                          color: emerald,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Range Materi
                    const Text(
                      "CAKUPAN",
                      style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${target.mulai} ➔ ${target.akhir}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Info KKM
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("KKM", style: TextStyle(fontSize: 9, color: Colors.grey)),
                            Text("${target.kkm.toInt()}%",
                                style: const TextStyle(fontWeight: FontWeight.bold, color: emerald)),
                          ],
                        ),
                        Icon(Icons.stars_rounded, size: 20, color: Colors.amber.shade300),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}