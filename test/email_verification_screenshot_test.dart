import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nroq/screens/auth/email_verification_screen.dart';

void main() {
  testWidgets('capture email verification screen', (tester) async {
    await _loadFont('Arial', r'C:\Windows\Fonts\arial.ttf');
    await _loadFont(
      'MaterialIcons',
      r'C:\flutter\bin\cache\artifacts\material_fonts\materialicons-regular.otf',
    );
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(fontFamily: 'Arial'),
        home: const EmailVerificationScreen(
          email: 'dheerajkumar152004@gmail.com',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(EmailVerificationScreen),
      matchesGoldenFile('email_verification_screen.png'),
    );
  });
}

Future<void> _loadFont(String family, String fontPath) async {
  final fontData = ByteData.sublistView(await File(fontPath).readAsBytes());
  await (FontLoader(family)..addFont(Future.value(fontData))).load();
}
