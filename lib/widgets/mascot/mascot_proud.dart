import 'package:flutter/material.dart';

import 'mascot_core.dart';
import 'mascot_mood.dart';

class MascotProudArt extends StatelessWidget {
  final double floatPhase;
  final double blinkPhase;
  final double motionPhase;

  const MascotProudArt({
    super.key,
    required this.floatPhase,
    required this.blinkPhase,
    required this.motionPhase,
  });

  @override
  Widget build(BuildContext context) {
    return MascotStage(
      mood: MascotMood.proud,
      floatPhase: floatPhase,
      blinkPhase: blinkPhase,
      motionPhase: motionPhase,
    );
  }
}
