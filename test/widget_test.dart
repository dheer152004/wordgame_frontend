// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nroq/main.dart';
import 'package:nroq/models/auth_models.dart';
import 'package:nroq/models/profile_models.dart';
import 'package:nroq/models/word_Content_models.dart';
import 'package:nroq/screens/auth/auth_screen.dart';
import 'package:nroq/screens/auth/email_verification_screen.dart';
import 'package:nroq/screens/auth/register_screen.dart';
import 'package:nroq/screens/profile/widgets/date_of_birth_dialog.dart';
import 'package:nroq/theme/app_theme.dart';
import 'package:nroq/widgets/categories_section.dart';

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

  test('parses an unverified registration without creating a user session', () {
    final registration = RegistrationResult.fromJson({
      'token': null,
      'refreshToken': null,
      'id': null,
      'username': 'dheeraj',
      'email': 'dheerajkumar152004@gmail.com',
      'displayName': 'Dheeraj',
      'provider': 'email',
      'emailVerified': false,
      'roles': ['USER'],
    });

    expect(registration.email, 'dheerajkumar152004@gmail.com');
    expect(registration.emailVerified, isFalse);
    expect(registration.user, isNull);
  });

  test('includes accepted documents and platform in registration payload', () {
    final request = RegisterRequest(
      username: 'dheeraj',
      email: 'dheeraj@example.com',
      password: 'password',
      acceptedDocuments: const [1, 2],
      displayName: 'Dheeraj',
      platform: 'ANDROID',
    );

    expect(request.toJson(), {
      'username': 'dheeraj',
      'email': 'dheeraj@example.com',
      'password': 'password',
      'acceptedDocuments': [1, 2],
      'platform': 'ANDROID',
      'displayName': 'Dheeraj',
    });
  });

  testWidgets('requires acceptance of the terms and privacy policy', (
    WidgetTester tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    final usernameController = TextEditingController();
    final emailController = TextEditingController();
    final displayNameController = TextEditingController();
    final passwordController = TextEditingController();
    usernameController.text = 'dheeraj';
    emailController.text = 'dheeraj@example.com';
    passwordController.text = 'password123';
    addTearDown(usernameController.dispose);
    addTearDown(emailController.dispose);
    addTearDown(displayNameController.dispose);
    addTearDown(passwordController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 280,
              child: SingleChildScrollView(
                child: RegisterScreen(
                  formKey: formKey,
                  usernameController: usernameController,
                  emailController: emailController,
                  displayNameController: displayNameController,
                  passwordController: passwordController,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final agreement = tester.widget<RichText>(
      find.byKey(const ValueKey('agreement-text')),
    );
    expect(agreement.textAlign, TextAlign.left);
    final agreementSpan = agreement.text as TextSpan;
    final agreementSize = tester.getSize(
      find.byKey(const ValueKey('agreement-text')),
    );
    expect(agreementSize.height, greaterThan(20));
    expect(
      tester.getCenter(find.byType(Checkbox)).dy,
      closeTo(
        tester.getCenter(find.byKey(const ValueKey('agreement-text'))).dy,
        1,
      ),
    );
    final termsSpan = agreementSpan.children![1] as TextSpan;
    final privacySpan = agreementSpan.children![3] as TextSpan;
    expect(termsSpan.text, 'Terms of Use');
    expect(termsSpan.recognizer, isNotNull);
    expect(privacySpan.text, 'Privacy Policy');
    expect(privacySpan.recognizer, isNotNull);

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(
      find.text('Please accept the Terms of Use and Privacy Policy.'),
      findsOneWidget,
    );

    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    expect(formKey.currentState!.validate(), isTrue);
    await tester.pump();
    expect(
      find.text('Please accept the Terms of Use and Privacy Policy.'),
      findsNothing,
    );
  });

  testWidgets('auth mode switch wraps on narrow screens', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: AuthScreen(initialMode: AuthMode.register)),
    );
    await tester.pump();

    expect(find.text('Already have an account?'), findsOneWidget);
    expect(tester.takeException(), isNull);
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

  testWidgets('shows the email address on the verification screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: EmailVerificationScreen(email: 'dheeraj@example.com'),
      ),
    );

    expect(find.text('Verify your email'), findsOneWidget);
    expect(find.text('dheeraj@example.com'), findsOneWidget);
    expect(find.text('Back to sign in'), findsOneWidget);
  });

  testWidgets('shows the full-screen date of birth picker', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: DateOfBirthDialog(canSkip: false)),
    );

    expect(find.text('Select your\ndate of birth'), findsOneWidget);
    expect(
      find.textContaining('Please refer to our', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Confirm'), findsOneWidget);
    expect(find.byType(CupertinoPicker), findsNWidgets(3));
  });

  testWidgets('shows the Categories heading in the dark theme text color', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.getDarkTheme(),
        home: const Scaffold(body: CategoriesSection()),
      ),
    );

    final heading = tester.widget<Text>(find.text('Categories'));
    expect(heading.style?.color, DarkColors.textPrimary);
  });
}
