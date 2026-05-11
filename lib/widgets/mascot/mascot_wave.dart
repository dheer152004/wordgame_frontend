import 'package:flutter/material.dart';

import 'mascot_core.dart';
import 'mascot_mood.dart';

class MascotWaveArt extends StatelessWidget {
  final double floatPhase;
  final double blinkPhase;
  final double motionPhase;

  const MascotWaveArt({
    super.key,
    required this.floatPhase,
    required this.blinkPhase,
    required this.motionPhase,
  });

  @override
  Widget build(BuildContext context) {
    return MascotStage(
      mood: MascotMood.wave,
      floatPhase: floatPhase,
      blinkPhase: blinkPhase,
      motionPhase: motionPhase,
    );
  }
}
