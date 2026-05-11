import 'package:flutter/material.dart';

import 'mascot_mood.dart';

class MascotLegs extends StatelessWidget {
  final MascotMood mood;
  final double motionPulse;
  final double jumpLift;

  const MascotLegs({
    super.key,
    required this.mood,
    required this.motionPulse,
    required this.jumpLift,
  });

  @override
  Widget build(BuildContext context) {
    final isJump = mood == MascotMood.jump;
    final isCelebrate = mood == MascotMood.celebration;
    final legSpread = isJump
        ? 16.0
        : isCelebrate
        ? 12.0
        : 8.0;
    final ankleBounce = isJump ? motionPulse * 4 : 0.0;

    return Positioned(
      bottom: 2,
      child: Transform.translate(
        offset: Offset(0, -jumpLift + (isCelebrate ? motionPulse * 2 : 0)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CuteLeg(
              angle: isJump ? -0.1 : -0.03,
              xOffset: -legSpread,
              bounce: ankleBounce,
            ),
            _CuteLeg(
              angle: isJump ? 0.1 : 0.03,
              xOffset: legSpread,
              bounce: ankleBounce,
            ),
          ],
        ),
      ),
    );
  }
}

class _CuteLeg extends StatelessWidget {
  final double angle;
  final double xOffset;
  final double bounce;

  const _CuteLeg({
    required this.angle,
    required this.xOffset,
    required this.bounce,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(xOffset, bounce),
      child: Transform.rotate(
        angle: angle,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFF1C7AD9),
                borderRadius: BorderRadius.circular(9),
              ),
            ),
            const SizedBox(height: 2),
            Container(
              width: 20,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A).withOpacity(0.12),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
