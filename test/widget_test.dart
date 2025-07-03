// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arknights/main.dart';

void main() {
  testWidgets('Daily Quote App smoke test', (WidgetTester tester) async {
    // Build app
    await tester.pumpWidget(const ArknightsApp());
    await tester.pump(const Duration(seconds: 1));

    // Basic smoke test: ensure MaterialApp is present
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
