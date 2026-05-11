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
      top: 24,
      child: SizedBox(
        width: 132,
        height: 132,
        child: Transform.translate(
          offset: Offset(0, floatWave * 0.5),
          child: Transform.scale(
            scaleY: scaleY,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 0,
                  child: Container(
                    width: 132,
                    height: 132,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F8FEA),
                      borderRadius: BorderRadius.circular(66),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2F8FEA).withOpacity(0.24),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  child: Container(
                    width: 132,
                    height: 132,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(66),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 22,
                  child: _BodyEar(
                    left: true,
                    mood: mood,
                    motionPulse: motionPulse,
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 22,
                  child: _BodyEar(
                    left: false,
                    mood: mood,
                    motionPulse: motionPulse,
                  ),
                ),
                Positioned(
                  top: 18,
                  child: Container(
                    width: 88,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(46),
                    ),
                  ),
                ),
                if (isHappy)
                  Positioned(
                    top: 44,
                    child: Container(
                      width: 110,
                      height: 68,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(36),
                      ),
                    ),
                  ),
                if (isIdle)
                  Positioned(
                    top: 42,
                    child: Container(
                      width: 106,
                      height: 66,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(34),
                      ),
                    ),
                  ),
                if (isJump)
                  Positioned(
                    top: 6,
                    child: Container(
                      width: 112,
                      height: 128,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(58),
                      ),
                    ),
                  ),
                if (isWave)
                  Positioned(
                    top: 30,
                    child: Container(
                      width: 108,
                      height: 86,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(40),
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
    final yShift = isLaugh
        ? motionPulse * 2
        : isWave
        ? (left ? -1.0 : 2.0) + motionPulse * 2
        : isCelebrate
        ? -1.5 + motionPulse * 2
        : 0.0;

    return Transform.rotate(
      angle: (left ? -0.22 : 0.22) + (isWave ? (left ? -0.02 : 0.02) : 0),
      child: Transform.translate(
        offset: Offset(0, yShift),
        child: Container(
          width: 22,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFF1F7FDB),
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
