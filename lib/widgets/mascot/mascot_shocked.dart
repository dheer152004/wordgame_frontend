import 'package:flutter/material.dart';

import 'mascot_core.dart';
import 'mascot_mood.dart';

class MascotShockedArt extends StatelessWidget {
  final double floatPhase;
  final double blinkPhase;
  final double motionPhase;

  const MascotShockedArt({
    super.key,
    required this.floatPhase,
    required this.blinkPhase,
    required this.motionPhase,
  });

  @override
  Widget build(BuildContext context) {
    return MascotStage(
      mood: MascotMood.shocked,
      floatPhase: floatPhase,
      blinkPhase: blinkPhase,
      motionPhase: motionPhase,
    );
  }
}
