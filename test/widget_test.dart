import 'package:flutter_test/flutter_test.dart';
import 'package:login_app/core/format.dart';
import 'package:login_app/main.dart';

void main() {
  testWidgets('FOODSTOCK AI App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FoodstockApp());
    await tester.pump(const Duration(milliseconds: 300));

    // Splash atau layar login sama-sama menampilkan judul aplikasi.
    expect(find.text('FOODSTOCK AI'), findsOneWidget);
  });

  test('Fmt.parseAngka menangani format Indonesia dan internasional', () {
    expect(Fmt.parseAngka('1.500,5'), 1500.5);
    expect(Fmt.parseAngka('1500,5'), 1500.5);
    expect(Fmt.parseAngka('1500.5'), 1500.5);
    expect(Fmt.parseAngka(''), isNull);
    expect(Fmt.parseAngka('abc'), isNull);
    expect(Fmt.parseAngka('-3'), isNull);
  });

  test('Fmt.angka memakai pemisah ribuan titik', () {
    expect(Fmt.angka(1234567.5), '1.234.567,5');
    expect(Fmt.angka(0), '0');
  });
}
