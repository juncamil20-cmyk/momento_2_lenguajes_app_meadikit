// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:momento_2_lenguajes_app_meadikit/app/app.dart';

void main() {
  testWidgets('muestra la biblioteca MediaKit al iniciar', (tester) async {
    await tester.pumpWidget(const MediaKitApp());
    await tester.pumpAndSettle();
    expect(find.text('MI BIBLIOTECA'), findsOneWidget);
    expect(find.text('CREAR PROYECTO'), findsOneWidget);
  });
}
