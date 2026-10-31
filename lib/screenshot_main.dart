import 'package:flutter/material.dart';
import 'package:nroq/screens/auth/email_verification_screen.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: EmailVerificationScreen(
        email: 'dheerajkumar152004@gmail.com',
      ),
    ),
  );
}
