import 'package:flutter_test/flutter_test.dart';

import 'package:e_sahayta/main.dart';

void main() {
  testWidgets('app shell renders splash content', (WidgetTester tester) async {
    await tester.pumpWidget(const ESahaytaApp());

    expect(find.text('eSahayta'), findsOneWidget);
    expect(find.text('one app, many safeties'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
