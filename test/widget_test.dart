// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vitala/main.dart';

void main() {
  testWidgets('Vitala opens smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'vitala_first_launch': true});
    final controller = AppController();
    await controller.load();

    await tester.pumpWidget(Vitala(controller: controller));

    expect(find.text('Vitala'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('Health record'), findsOneWidget);
  });
}
