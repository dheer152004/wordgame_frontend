import 'package:flutter/material.dart';

import 'mascot_mood.dart';

class MascotHands extends StatelessWidget {
  final MascotMood mood;
  final double wavePulse;
  final double laughPulse;
  final double celebratePulse;

  const MascotHands({
    super.key,
    required this.mood,
    required this.wavePulse,
    required this.laughPulse,
    required this.celebratePulse,
  });

  @override
  Widget build(BuildContext context) {
    final isLaugh = mood == MascotMood.laugh;
    final isWave = mood == MascotMood.wave;
    final isCelebrate = mood == MascotMood.celebration;

    return Positioned(
      top: 82,
      left: 0,
      right: 0,
      child: SizedBox(
        width: 144,
        height: 44,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 14,
              top: isWave ? 0 : 8,
              child: Transform.rotate(
                angle: isWave ? -0.58 + wavePulse * 0.35 : -0.12,
                child: _TinyHand(
                  width: 16,
                  height: 26,
                  raise: isLaugh ? 2 + laughPulse * 3 : 0,
                ),
              ),
            ),
            Positioned(
              right: 14,
              top: isCelebrate ? -2 : 8,
              child: Transform.rotate(
                angle: isWave ? 0.58 - wavePulse * 0.35 : 0.12,
                child: _TinyHand(
                  width: 16,
                  height: 26,
                  raise: isCelebrate ? 1 + celebratePulse * 4 : 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TinyHand extends StatelessWidget {
  final double width;
  final double height;
  final double raise;

  const _TinyHand({
    required this.width,
    required this.height,
    required this.raise,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, -raise),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFF1C7AD9),
          borderRadius: BorderRadius.circular(11),
        ),
      ),
    );
  }
}
