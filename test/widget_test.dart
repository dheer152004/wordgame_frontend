// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nroq/main.dart';
import 'package:nroq/models/profile_models.dart';
import 'package:nroq/models/word_Content_models.dart';

void main() {
  test('saved word preview prefers the first available image URL', () {
    final savedWord = SavedWord.fromJson({
      'wordImageUrl': 'fallback.png',
      'images': [
        {'imageUrl': 'first.png'},
        {'imageUrl': 'second.png'},
      ],
    });

    expect(savedWord.previewImageUrl, 'first.png');
  });

  test('parses a profile date of birth from an ISO date string', () {
    final profile = UserProfile.fromJson({'dateOfBirth': '2005-08-15'});

    expect(profile.dateOfBirth, DateTime(2005, 8, 15));
  });

  test('parses a profile date of birth from a Java date array', () {
    final profile = UserProfile.fromJson({
      'dateOfBirth': [2005, 8, 15],
    });

    expect(profile.dateOfBirth, DateTime(2005, 8, 15));
  });

  test('parses createdAt from the profile API date array', () {
    final profile = UserProfile.fromJson({
      'createdAt': [2026, 9, 17, 11, 27, 38, 54508000],
    });

    expect(profile.createdAt, DateTime(2026, 9, 17, 11, 27, 38, 54508));
  });

  testWidgets('shows the auth screen when there is no saved session', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const WordApp());

    await tester.pumpAndSettle();

    expect(find.text('NROQ'), findsWidgets);
    expect(find.text('Forgot password?'), findsOneWidget);
  });

  testWidgets('shows a forgot password action on the login form', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const WordApp());

    await tester.pumpAndSettle();

    expect(find.text('Forgot password?'), findsOneWidget);
  });
}
