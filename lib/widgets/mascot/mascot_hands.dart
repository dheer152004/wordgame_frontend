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
      top: 84,
      left: 0,
      right: 0,
      child: SizedBox(
        width: 132,
        height: 40,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 18,
              top: isWave ? 2 : 8,
              child: Transform.rotate(
                angle: isWave ? -0.55 + wavePulse * 0.35 : -0.22,
                child: _TinyHand(raise: isLaugh ? 2 + laughPulse * 3 : 0),
              ),
            ),
            Positioned(
              right: 18,
              top: isCelebrate ? -2 : 8,
              child: Transform.rotate(
                angle: isWave ? 0.55 - wavePulse * 0.35 : 0.22,
                child: _TinyHand(
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
  final double raise;

  const _TinyHand({required this.raise});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, -raise),
      child: Container(
        width: 16,
        height: 26,
        decoration: BoxDecoration(
          color: const Color(0xFF1F7FDB),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
