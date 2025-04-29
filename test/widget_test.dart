// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fridge_spin/main.dart';

void main() {
  testWidgets('Application launches and shows welcome text', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FridgeSpinApp());

    // Verify that the welcome text appears
    expect(find.text('ยินดีต้อนรับสู่ FridgeSpin'), findsOneWidget);

    // Verify that the app bar title appears
    expect(find.text('FridgeSpin'), findsOneWidget);
  });
}
