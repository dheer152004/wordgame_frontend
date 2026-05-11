import 'package:flutter/material.dart';

import 'mascot_angry.dart';
import 'mascot_blink.dart';
import 'mascot_celebration.dart';
import 'mascot_core.dart';
import 'mascot_cry.dart';
import 'mascot_happy.dart';
import 'mascot_idle.dart';
import 'mascot_jump.dart';
import 'mascot_laugh.dart';
import 'mascot_mood.dart';
import 'mascot_proud.dart';
import 'mascot_sleepy.dart';
import 'mascot_sad.dart';
import 'mascot_shocked.dart';
import 'mascot_tap_reaction.dart';
import 'mascot_wave.dart';

Widget buildMascotArt({
  required MascotMood mood,
  required double floatPhase,
  required double blinkPhase,
  required double motionPhase,
}) {
  switch (mood) {
    case MascotMood.idle:
      return MascotIdleArt(
        floatPhase: floatPhase,
        blinkPhase: blinkPhase,
        motionPhase: motionPhase,
      );
    case MascotMood.blink:
      return MascotBlinkArt(
        floatPhase: floatPhase,
        blinkPhase: blinkPhase,
        motionPhase: motionPhase,
      );
    case MascotMood.sleepy:
      return MascotSleepyArt(
        floatPhase: floatPhase,
        blinkPhase: blinkPhase,
        motionPhase: motionPhase,
      );
    case MascotMood.proud:
      return MascotProudArt(
        floatPhase: floatPhase,
        blinkPhase: blinkPhase,
        motionPhase: motionPhase,
      );
    case MascotMood.happy:
      return MascotHappyArt(
        floatPhase: floatPhase,
        blinkPhase: blinkPhase,
        motionPhase: motionPhase,
      );
    case MascotMood.sad:
      return MascotSadArt(
        floatPhase: floatPhase,
        blinkPhase: blinkPhase,
        motionPhase: motionPhase,
      );
    case MascotMood.laugh:
      return MascotLaughArt(
        floatPhase: floatPhase,
        blinkPhase: blinkPhase,
        motionPhase: motionPhase,
      );
    case MascotMood.cry:
      return MascotCryArt(
        floatPhase: floatPhase,
        blinkPhase: blinkPhase,
        motionPhase: motionPhase,
      );
    case MascotMood.angry:
      return MascotAngryArt(
        floatPhase: floatPhase,
        blinkPhase: blinkPhase,
        motionPhase: motionPhase,
      );
    case MascotMood.shocked:
      return MascotShockedArt(
        floatPhase: floatPhase,
        blinkPhase: blinkPhase,
        motionPhase: motionPhase,
      );
    case MascotMood.wave:
      return MascotWaveArt(
        floatPhase: floatPhase,
        blinkPhase: blinkPhase,
        motionPhase: motionPhase,
      );
    case MascotMood.jump:
      return MascotJumpArt(
        floatPhase: floatPhase,
        blinkPhase: blinkPhase,
        motionPhase: motionPhase,
      );
    case MascotMood.tapReaction:
      return MascotTapReactionArt(
        floatPhase: floatPhase,
        blinkPhase: blinkPhase,
        motionPhase: motionPhase,
      );
    case MascotMood.celebration:
      return MascotCelebrationArt(
        floatPhase: floatPhase,
        blinkPhase: blinkPhase,
        motionPhase: motionPhase,
      );
  }
}
