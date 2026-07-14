// Lokasi: lib/features/mutabaah/screens/components/Sertifikasi_status_banner.dart

import 'package:flutter/material.dart';
import '../../kurikulum/models/kurikulum_model.dart';
import 'package:go_router/go_router.dart'; // Menggunakan go_router untuk navigasi jembatan formal

class TasmiStatusBanner extends StatelessWidget {
  final String siswaId;
  final String namaSiswa;
  final ModulModel modul;
  final String academicState; // TAMBAHAN: State posisi akademis siswa ('tasmi_mode', 'exam_ready')

  const TasmiStatusBanner({super.key, required this.siswaId, required this.namaSiswa, required this.modul, required this.academicState});

  @override
  Widget build(BuildContext context) {
    // Definisi teks dinamis berdasarkan kombinasi silabus_source dan academic_state
    final bool isInternal = modul.silabusSource == 'internal';
    final bool isTasmiMode = academicState == 'tasmi_mode';

    String titleText = "TARGET MATERI TUNTAS!";
    String descText = "Mutaba'ah harian dinonaktifkan. Silakan lakukan Ujian Tasmi' untuk dapat melanjutkan ke materi berikutnya.";
    String buttonText = "BUKA FORM UJIAN TASMI'";
    Color themeColor = const Color(0xFFB45309);
    Color borderColor = Colors.amber[700]!;
    Color bgColor = const Color(0xFFFFFBEB);
    Color textColor = const Color(0xFF92400E);
    IconData iconData = Icons.stars_rounded;

    if (isInternal) {
      titleText = "MATERI TUNTAS, SIAP UJIAN INTERNAL!";
      descText = "Seluruh silabus internal telah diselesaikan. Penginputan harian dikunci sementara, silakan buka Lembar Evaluasi Internal santri.";
      buttonText = "BUKA LEMBAR EVALUASI INTERNAL";
      themeColor = const Color(0xFF3B82F6);
      borderColor = const Color(0xFF3B82F6);
      bgColor = const Color(0xFFEFF6FF);
      textColor = const Color(0xFF1E3A8A);
      iconData = Icons.assignment_turned_in_rounded;
    } else if (isTasmiMode) {
      titleText = "WAKTUNYA TASMI' KELANCARAN!";
      descText = "Siswa telah mencapai batas volume ujian. Silakan lakukan validasi Tasmi' Kelancaran Sekali Duduk untuk membuka gembok materi berikutnya.";
      buttonText = "MULAI TASMI' KELANCARAN";
      themeColor = const Color(0xFFD97706);
      borderColor = const Color(0xFFF59E0B);
      bgColor = const Color(0xFFFEF3C7);
      textColor = const Color(0xFF78350F);
      iconData = Icons.lock_clock;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Column(
        children: [
          Icon(iconData, size: 48, color: themeColor),
          const SizedBox(height: 16),
          Text(titleText,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
          const SizedBox(height: 8),
          Text(
            descText,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: textColor.withValues(alpha: 0.9)),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.push(
                  '/akademik/tasmi',
                  extra: {
                    'siswaId': siswaId,
                    'namaSiswa': namaSiswa,
                    'modul': modul,
                    'tipeEvaluasi': isTasmiMode ? 'TASMI' : (modul.evaluationType ?? 'TASMI'),
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(buttonText,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}