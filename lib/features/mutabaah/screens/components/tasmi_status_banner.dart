// Lokasi: lib/features/mutabaah/screens/components/tasmi_status_banner.dart

import 'package:flutter/material.dart';
import '../../../akademik/kurikulum/models/kurikulum_model.dart';
import '../../../akademik/tasmi/screens/tasmi_form_screen.dart'; // Import silang ke Akademik

class TasmiStatusBanner extends StatelessWidget {
  final String siswaId;
  final String namaSiswa;
  final ModulModel modul;

  const TasmiStatusBanner({super.key, required this.siswaId, required this.namaSiswa, required this.modul});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber[700]!, width: 2),
      ),
      child: Column(
        children: [
          const Icon(Icons.stars_rounded, size: 48, color: Colors.amber),
          const SizedBox(height: 16),
          const Text("TARGET MATERI TUNTAS!",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF92400E))),
          const SizedBox(height: 8),
          const Text(
            "Mutaba'ah harian dinonaktifkan. Silakan lakukan Ujian Tasmi' untuk dapat melanjutkan ke materi berikutnya.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFFB45309)),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                builder: (context) => TasmiFormScreen(siswaId: siswaId, namaSiswa: namaSiswa, modul: modul),
              )),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB45309),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("BUKA FORM UJIAN TASMI'",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}