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
        ? 18.0
        : isCelebrate
        ? 14.0
        : 10.0;
    final ankleBounce = isJump ? motionPulse * 4 : 0.0;

    return Positioned(
      bottom: 6,
      child: Transform.translate(
        offset: Offset(0, -jumpLift + (isCelebrate ? motionPulse * 2 : 0)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CuteLeg(
              angle: isJump ? -0.12 : -0.02,
              xOffset: -legSpread,
              bounce: ankleBounce,
            ),
            _CuteLeg(
              angle: isJump ? 0.12 : 0.02,
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
              width: 16,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFF1F7FDB),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 2),
            Container(
              width: 18,
              height: 7,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A).withOpacity(0.16),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
