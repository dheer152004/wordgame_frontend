# word

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
my hu papa

## Crashlytics setup

Crash reports are enabled for Android and iOS in `lib/main.dart`. Before building
the mobile app, connect this project to your Firebase project with FlutterFire:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Select the Android and iOS apps when prompted. This creates the Firebase app
configuration and downloads `android/app/google-services.json` plus the iOS
Firebase configuration. Keep those files out of source control if your project
policy requires it. Crashlytics reports are available after the first release
or profile build reaches Firebase; debug crashes are not uploaded by default.
