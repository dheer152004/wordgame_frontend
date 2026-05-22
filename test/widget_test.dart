// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:word_frontend/main.dart';

void main() {
  testWidgets('shows the auth screen when there is no saved session', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const WordApp());

    await tester.pumpAndSettle();

    expect(find.text('Klug'), findsWidgets);
    expect(find.text('Continue as guest'), findsOneWidget);
  });
}
