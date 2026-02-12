import 'dart:convert';
import 'dart:io';

void main() async {
  final directory = Directory('./');

  final files = directory
      .listSync()
      .where((file) => file.path.endsWith('.json'));

  for (var file in files) {
    final content = await File(file.path).readAsString();
    final data = json.decode(content);

    int page = data['page'];

    for (var line in data['lines']) {
      if (line['type'] == 'text') {
        if (line['verseRange'] != null) {
          String verseRange = line['verseRange'];
          String firstVerse = verseRange.split('-')[0];
          var parts = firstVerse.split(':');

          int surah = int.parse(parts[0]);
          int ayah = int.parse(parts[1]);

          int juz = data['juz'] ?? 0;

          String text = line['text'].replaceAll("'", "''");

          print(
              "INSERT INTO quran_lines (page, line_number, surah, ayah, juz, text) VALUES ($page, ${line['line']}, $surah, $ayah, $juz, '$text');");
        }
      }
    }
  }
}
