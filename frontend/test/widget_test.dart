// This is a basic Flutter widget test for Jivhala Motors App.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jivhala_motors/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const JivhalaMotorsApp());

    // Wait for splash screen animation
    await tester.pumpAndSettle();

    // Verify that the app loads without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
