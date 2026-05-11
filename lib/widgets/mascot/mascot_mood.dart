import 'package:flutter/material.dart';

enum MascotMood {
  idle,
  blink,
  happy,
  sad,
  laugh,
  cry,
  angry,
  shocked,
  wave,
  jump,
  tapReaction,
  celebration,
}

extension MascotMoodX on MascotMood {
  String get label {
    switch (this) {
      case MascotMood.idle:
        return 'Idle';
      case MascotMood.blink:
        return 'Blink';
      case MascotMood.happy:
        return 'Happy';
      case MascotMood.sad:
        return 'Sad';
      case MascotMood.laugh:
        return 'Laugh';
      case MascotMood.cry:
        return 'Cry';
      case MascotMood.angry:
        return 'Angry';
      case MascotMood.shocked:
        return 'Shocked';
      case MascotMood.wave:
        return 'Wave';
      case MascotMood.jump:
        return 'Jump';
      case MascotMood.tapReaction:
        return 'Tap reaction';
      case MascotMood.celebration:
        return 'Celebration';
    }
  }

  String get message {
    switch (this) {
      case MascotMood.idle:
        return 'Ready when you are.';
      case MascotMood.blink:
        return 'Just checking in.';
      case MascotMood.happy:
        return 'Nice progress today.';
      case MascotMood.sad:
        return 'That one was rough.';
      case MascotMood.laugh:
        return 'That was funny.';
      case MascotMood.cry:
        return 'I need a tissue.';
      case MascotMood.angry:
        return 'Focus up.';
      case MascotMood.shocked:
        return 'Whoa, surprise!';
      case MascotMood.wave:
        return 'Hello there!';
      case MascotMood.jump:
        return 'Let us go!';
      case MascotMood.tapReaction:
        return 'Tap again!';
      case MascotMood.celebration:
        return 'Celebrate the win!';
    }
  }

  List<Color> get gradientColors {
    switch (this) {
      case MascotMood.idle:
      case MascotMood.blink:
        return const [Color(0xFFEAF8FF), Color(0xFFDDF0FF), Color(0xFFF7FAFF)];
      case MascotMood.happy:
        return const [Color(0xFFEAF8FF), Color(0xFFD8EEFF), Color(0xFFF8F2FF)];
      case MascotMood.sad:
        return const [Color(0xFFE7F0FF), Color(0xFFD9E2F8), Color(0xFFF4F7FC)];
      case MascotMood.laugh:
        return const [Color(0xFFFFF0DF), Color(0xFFFFE1C2), Color(0xFFF8F6FF)];
      case MascotMood.cry:
        return const [Color(0xFFE8F1FF), Color(0xFFDDEBFF), Color(0xFFF5F8FF)];
      case MascotMood.angry:
        return const [Color(0xFFFFEFEA), Color(0xFFFFD4CC), Color(0xFFF8F6FF)];
      case MascotMood.shocked:
        return const [Color(0xFFEAF4FF), Color(0xFFFBE6EA), Color(0xFFFFF6DF)];
      case MascotMood.wave:
        return const [Color(0xFFE8F8F4), Color(0xFFD7F1EA), Color(0xFFF7FBFD)];
      case MascotMood.jump:
        return const [Color(0xFFF4ECFF), Color(0xFFE8DFFF), Color(0xFFFDF9FF)];
      case MascotMood.tapReaction:
        return const [Color(0xFFFFF5DB), Color(0xFFFFE9B5), Color(0xFFFDF8F0)];
      case MascotMood.celebration:
        return const [Color(0xFFEAF8FF), Color(0xFFE6F5E8), Color(0xFFFFF5E9)];
    }
  }

  Color get accentColor {
    switch (this) {
      case MascotMood.idle:
      case MascotMood.blink:
      case MascotMood.happy:
      case MascotMood.wave:
      case MascotMood.jump:
      case MascotMood.celebration:
        return const Color(0xFF2F8FEA);
      case MascotMood.sad:
      case MascotMood.cry:
        return const Color(0xFF4D86D8);
      case MascotMood.laugh:
        return const Color(0xFFF0A53A);
      case MascotMood.angry:
        return const Color(0xFFE76A54);
      case MascotMood.shocked:
        return const Color(0xFFE27C5F);
      case MascotMood.tapReaction:
        return const Color(0xFF56A06A);
    }
  }
}
