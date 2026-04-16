// Lokasi: lib/features/mushaf/widgets/mushaf_page_view.dart

import 'package:flutter/material.dart';
import '../models/mushaf_model.dart';

class MushafPageView extends StatelessWidget {
  final List<MushafLine> lines;

  const MushafPageView({super.key, required this.lines});

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) {
      return const Center(
        child: Text(
          "Data halaman tidak ditemukan di database.",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final pageNum = lines.first.pageNumber;
        final bool isSpecialPage = pageNum <= 2;

        // POIN 2: Sistem Scaling agar pas 15 baris di layar mana pun (Tanpa Scroll)
        final double dynamicFontSize = constraints.maxHeight * (isSpecialPage ? 0.042 : 0.030);

        return Container(
          margin: const EdgeInsets.all(4.0),
          padding: const EdgeInsets.all(2.0),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E7),
            border: Border.all(color: const Color(0xFFB8963E), width: 2.0),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: isSpecialPage ? 24 : 10,
                vertical: isSpecialPage ? 24 : 8
            ),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFB8963E), width: isSpecialPage ? 5.0 : 2.5),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: MushafCornerPainter(color: const Color(0xFFB8963E)),
                  ),
                ),

                Column(
                  children: [
                    // Header Navigasi (Hanya pemberi jarak setelah search/tab dihapus)
                    _buildActionHeader(),

                    if (!isSpecialPage) _buildTopHeader(constraints),
                    if (!isSpecialPage) const SizedBox(height: 4),

                    Expanded(
                      child: Column(
                        // PAS 15 BARIS: Menggunakan spaceBetween agar terbagi rata mengikuti tinggi layar
                        mainAxisAlignment: isSpecialPage ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
                        children: lines.asMap().entries.map((entry) {
                          final int idx = entry.key;
                          final MushafLine line = entry.value;

                          // Banner hanya muncul SEKALI: di baris pertama (index terkecil) yang ayahNumber == 1
                          final int firstAyah1LineIdx = lines.indexWhere((l) => l.ayahNumber == 1);
                          bool isStartOfSurah = line.ayahNumber == 1 && !isSpecialPage && idx == firstAyah1LineIdx;

                          // Nomor ayat hanya muncul di baris TERAKHIR setiap ayat
                          final bool isLastLineOfAyah = (idx == lines.length - 1) ||
                              (lines[idx + 1].ayahNumber != line.ayahNumber) ||
                              (lines[idx + 1].surahNumber != line.surahNumber);

                          return isSpecialPage
                              ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RichText(
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: dynamicFontSize,
                                    fontFamily: 'UthmanicFont',
                                    height: 1.8,
                                    color: const Color(0xFF1A1A1A),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: _buildTajwidText(line, dynamicFontSize, isLastLineOfAyah),
                                ),
                              ),
                            ],
                          )
                              : Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (isStartOfSurah) _buildSurahBanner(line.surahName, line.surahNumber, constraints),
                                Flexible(
                                  child: RichText(
                                    textAlign: TextAlign.justify,
                                    textDirection: TextDirection.rtl,
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontSize: dynamicFontSize,
                                        fontFamily: 'UthmanicFont',
                                        height: 1.6,
                                        color: const Color(0xFF1A1A1A),
                                        fontWeight: FontWeight.w400,
                                      ),
                                      children: _buildTajwidText(line, dynamicFontSize, isLastLineOfAyah),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 4),

                    _buildFooter(pageNum, constraints),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // FIX: WidgetSpan sekarang menerima fontSize agar ikut scaling
  List<InlineSpan> _buildTajwidText(MushafLine line, double fontSize, bool showAyahNumber) {
    final double ayahNumSize = fontSize * 0.7;
    return [
      TextSpan(text: "${line.quranText} "),
      if (showAyahNumber)
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: fontSize * 0.2),
            padding: EdgeInsets.all(fontSize * 0.15),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF10B981), width: 1.0),
            ),
            child: Text(
              line.arabicAyahNumber,
              style: TextStyle(
                fontSize: ayahNumSize,
                fontFamily: 'UthmanicFont',
                fontWeight: FontWeight.bold,
                color: const Color(0xFF10B981),
              ),
            ),
          ),
        ),
    ];
  }

  Widget _buildActionHeader() {
    return const SizedBox(height: 12);
  }

  Widget _buildTopHeader(BoxConstraints constraints) {
    final double headerFontSize = constraints.maxWidth * 0.035;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "الجزء ${lines.first.juzNumber}",
            style: TextStyle(
              fontFamily: 'UthmanicFont',
              fontSize: headerFontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF8B4513),
            ),
          ),
          Text(
            lines.first.surahName,
            style: TextStyle(
              fontFamily: 'UthmanicFont',
              fontSize: headerFontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF8B4513),
            ),
          ),
        ],
      ),
    );
  }

  // Update Banner dengan Floral Frame dan Jarak Basmalah yang Rapi
  Widget _buildSurahBanner(String name, int surahNumber, BoxConstraints constraints) {
    final double bannerFontSize = constraints.maxWidth * 0.042;
    final double basmalaFontSize = constraints.maxWidth * 0.052;
    final double iconSize = constraints.maxWidth * 0.045;
    // Strip prefix ganda jika surahName dari DB sudah mengandung kata Surah / سُورَةُ
    String cleanName = name
        .replaceAll(RegExp(r'^سُورَةُ\s*'), '')
        .replaceAll(RegExp(r'^[Ss]urah\s*', caseSensitive: false), '')
        .trim();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: constraints.maxWidth * 0.92,
          margin: EdgeInsets.symmetric(vertical: constraints.maxHeight * 0.006),
          padding: EdgeInsets.symmetric(
            vertical: constraints.maxHeight * 0.008,
            horizontal: constraints.maxWidth * 0.04,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E7),
            border: Border.all(color: const Color(0xFFB8963E), width: 1.5),
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                // FIX: Menggunakan .withValues() untuk menghindari deprecation withOpacity
                color: const Color(0xFFB8963E).withValues(alpha: 0.2),
                blurRadius: 2,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.filter_vintage_outlined, color: const Color(0xFFB8963E), size: iconSize),
              Text(
                "سُورَةُ $cleanName",
                style: TextStyle(
                  fontFamily: 'UthmanicFont',
                  fontSize: bannerFontSize,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6B3A1F),
                ),
              ),
              Icon(Icons.filter_vintage_outlined, color: const Color(0xFFB8963E), size: iconSize),
            ],
          ),
        ),
        if (surahNumber != 1 && surahNumber != 9)
          Padding(
            padding: EdgeInsets.only(
              bottom: constraints.maxHeight * 0.010,
              top: constraints.maxHeight * 0.004,
            ),
            child: Text(
              "بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'UthmanicFont',
                fontSize: basmalaFontSize,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFooter(int pageNum, BoxConstraints constraints) {
    final double footerIconSize = constraints.maxWidth * 0.09;
    final double footerFontSize = constraints.maxWidth * 0.028;
    return Container(
      padding: const EdgeInsets.only(top: 4),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.settings_suggest_outlined, color: const Color(0xFFB8963E), size: footerIconSize),
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Text(
              pageNum.toString(), // POIN: HANYA NOMOR SAJA
              style: TextStyle(
                fontSize: footerFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MushafCornerPainter extends CustomPainter {
  final Color color;
  MushafCornerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    double len = 20.0;

    canvas.drawLine(const Offset(0, 0), Offset(len, 0), paint);
    canvas.drawLine(const Offset(0, 0), Offset(0, len), paint);
    canvas.drawCircle(const Offset(0, 0), 3, paint..style = PaintingStyle.fill);

    canvas.drawLine(Offset(size.width, 0), Offset(size.width - len, 0), paint..style = PaintingStyle.stroke);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, len), paint);
    canvas.drawCircle(Offset(size.width, 0), 3, paint..style = PaintingStyle.fill);

    canvas.drawLine(Offset(0, size.height), Offset(len, size.height), paint..style = PaintingStyle.stroke);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - len), paint);
    canvas.drawCircle(Offset(0, size.height), 3, paint..style = PaintingStyle.fill);

    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - len, size.height), paint..style = PaintingStyle.stroke);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - len), paint);
    canvas.drawCircle(Offset(size.width, size.height), 3, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}