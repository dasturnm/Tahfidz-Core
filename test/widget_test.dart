import 'package:flutter_test/flutter_test.dart';
import 'package:tahfidz_core/app.dart';

void main() {
  testWidgets('Cek tampilan awal', (WidgetTester tester) async {
    // Memanggil TahfidzCoreApp, bukan MyApp
    await tester.pumpWidget(const TahfidzCoreApp());
  });
}