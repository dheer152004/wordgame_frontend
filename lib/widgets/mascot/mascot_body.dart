import 'package:flutter/material.dart';

import 'mascot_mood.dart';

class MascotBody extends StatelessWidget {
  final MascotMood mood;
  final double floatPhase;
  final double motionPulse;

  const MascotBody({
    super.key,
    required this.mood,
    required this.floatPhase,
    required this.motionPulse,
  });

  @override
  Widget build(BuildContext context) {
    final floatWave = (floatPhase - 0.5) * 6;
    final isHappy = mood == MascotMood.happy;
    final isIdle = mood == MascotMood.idle || mood == MascotMood.blink;
    final isJump = mood == MascotMood.jump;
    final isWave = mood == MascotMood.wave;
    final scaleY = isJump
        ? 0.96 - (motionPulse * 0.03)
        : isHappy
        ? 1.02 + (motionPulse * 0.02)
        : isIdle
        ? 0.99 + (motionPulse * 0.01)
        : 1.0;

    return Positioned(
      top: 18,
      child: SizedBox(
        width: 140,
        height: 140,
        child: Transform.translate(
          offset: Offset(0, floatWave * 0.4),
          child: Transform.scale(
            scaleY: scaleY,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 4,
                  child: Container(
                    width: 122,
                    height: 122,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3090EB),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2F8FEA).withOpacity(0.22),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  top: -2,
                  left: 30,
                  child: _BodyEar(
                    left: true,
                    mood: mood,
                    motionPulse: motionPulse,
                  ),
                ),
                Positioned(
                  top: -2,
                  right: 30,
                  child: _BodyEar(
                    left: false,
                    mood: mood,
                    motionPulse: motionPulse,
                  ),
                ),
                Positioned(
                  top: 20,
                  child: Container(
                    width: 94,
                    height: 94,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.09),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                if (isHappy)
                  Positioned(
                    top: 38,
                    child: Container(
                      width: 104,
                      height: 76,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                  ),
                if (isIdle)
                  Positioned(
                    top: 40,
                    child: Container(
                      width: 100,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(38),
                      ),
                    ),
                  ),
                if (isJump)
                  Positioned(
                    top: 8,
                    child: Container(
                      width: 108,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(54),
                      ),
                    ),
                  ),
                if (isWave)
                  Positioned(
                    top: 28,
                    child: Container(
                      width: 104,
                      height: 88,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(42),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BodyEar extends StatelessWidget {
  final bool left;
  final MascotMood mood;
  final double motionPulse;

  const _BodyEar({
    required this.left,
    required this.mood,
    required this.motionPulse,
  });

  @override
  Widget build(BuildContext context) {
    final isWave = mood == MascotMood.wave;
    final isLaugh = mood == MascotMood.laugh;
    final isCelebrate = mood == MascotMood.celebration;
    final isJump = mood == MascotMood.jump;
    final yShift = isLaugh
        ? motionPulse * 3
        : isWave
        ? (left ? -1.5 : 2.0) + motionPulse * 2
        : isCelebrate
        ? -2.0 + motionPulse * 2
        : isJump
        ? -1.0 + motionPulse * 1.5
        : 0.0;

    return Transform.rotate(
      angle:
          (left ? -0.2 : 0.2) +
          (isWave ? (left ? -0.02 : 0.02) : 0) +
          (isLaugh ? (left ? -0.04 : 0.04) : 0),
      child: Transform.translate(
        offset: Offset(0, yShift),
        child: Container(
          width: 24,
          height: 30,
          decoration: BoxDecoration(
            color: const Color(0xFF1C7AD9),
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}
