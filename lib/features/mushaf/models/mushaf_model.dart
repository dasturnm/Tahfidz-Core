class MushafLine {
  final int id;
  final int juzNumber;
  final int surahNumber;
  final String surahName;
  final int pageNumber;
  final int lineNumber;
  final int ayahNumber;
  final String quranText;

  // Helper untuk mengubah angka ke format Arab (١, ٢, ٣)
  String get arabicAyahNumber {
    const digits = {'0': '٠', '1': '١', '2': '٢', '3': '٣', '4': '٤', '5': '٥', '6': '٦', '7': '٧', '8': '٨', '9': '٩'};
    return ayahNumber.toString().split('').map((e) => digits[e] ?? e).join();
  }

  MushafLine({
    required this.id,
    required this.juzNumber,
    required this.surahNumber,
    required this.surahName,
    required this.pageNumber,
    required this.lineNumber,
    required this.ayahNumber,
    required this.quranText,
  });

  factory MushafLine.fromJson(Map<String, dynamic> json) {
    return MushafLine(
      id: json['id'] ?? 0,
      juzNumber: json['juz_number'] ?? 0,
      surahNumber: json['surah_number'] ?? 0,
      surahName: json['surah_name'] ?? '',
      pageNumber: json['page_number'] ?? 0,
      lineNumber: json['line_number'] ?? 0,
      ayahNumber: json['ayah_number'] ?? 0,
      quranText: json['quran_text'] ?? '',
    );
  }
}