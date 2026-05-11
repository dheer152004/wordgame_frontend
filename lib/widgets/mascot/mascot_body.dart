import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'mascot_mood.dart';

class MascotBody extends StatelessWidget {
  final MascotMood mood;
  final double floatPhase;
  final double motionPhase;
  final double motionPulse;

  const MascotBody({
    super.key,
    required this.mood,
    required this.floatPhase,
    required this.motionPhase,
    required this.motionPulse,
  });

  @override
  Widget build(BuildContext context) {
    final floatWave = (floatPhase - 0.5) * 6;
    final isHappy = mood == MascotMood.happy;
    final isIdle = mood == MascotMood.idle || mood == MascotMood.blink;
    final isSleepy = mood == MascotMood.sleepy;
    final isProud = mood == MascotMood.proud;
    final isJump = mood == MascotMood.jump;
    final isWave = mood == MascotMood.wave;
    final breathWave = 0.5 + 0.5 * math.sin(motionPhase * math.pi * 2);
    final bellyPulse = isProud
        ? 1.0 + (breathWave * 0.08)
        : isSleepy
        ? 1.0 + (breathWave * 0.03)
        : isIdle
        ? 1.0 + (breathWave * 0.05)
        : 1.0;
    final scaleY = isJump
        ? 0.96 - (motionPulse * 0.03)
        : isHappy
        ? 1.02 + (motionPulse * 0.02)
        : isProud
        ? 1.03 + (motionPulse * 0.03)
        : isSleepy
        ? 0.97 + (motionPulse * 0.01)
        : isIdle
        ? 0.99 + (motionPulse * 0.01)
        : 1.0;

    return Positioned(
      top: 10,
      child: SizedBox(
        width: 146,
        height: 162,
        child: Transform.translate(
          offset: Offset(0, floatWave * 0.35),
          child: Transform.scale(
            scaleY: scaleY,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 4,
                  child: Container(
                    width: 128,
                    height: 128,
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
                  top: 108,
                  child: Container(
                    width: 94,
                    height: 68,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F8FEA),
                      borderRadius: BorderRadius.circular(48),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2F8FEA).withOpacity(0.18),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 114,
                  child: Container(
                    width: 78,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                ),
                Positioned(
                  top: 88,
                  child: Container(
                    width: 24,
                    height: 22,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F8FEA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  child: Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  top: -2,
                  left: 31,
                  child: _BodyEar(
                    left: true,
                    mood: mood,
                    motionPulse: motionPulse,
                  ),
                ),
                Positioned(
                  top: -2,
                  right: 31,
                  child: _BodyEar(
                    left: false,
                    mood: mood,
                    motionPulse: motionPulse,
                  ),
                ),
                Positioned(
                  top: 50,
                  child: Container(
                    width: 100 * bellyPulse,
                    height: 72 * bellyPulse,
                    child: ClipOval(
                      child: Container(color: Colors.white.withOpacity(0.1)),
                    ),
                  ),
                ),
                if (isHappy)
                  Positioned(
                    top: 67,
                    child: Container(
                      width: 92,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                  ),
                if (isSleepy)
                  Positioned(
                    top: 70,
                    child: Container(
                      width: 86,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                  ),
                if (isProud)
                  Positioned(
                    top: 63,
                    child: Container(
                      width: 96,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                  ),
                if (isIdle)
                  Positioned(
                    top: 67,
                    child: Container(
                      width: 88,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                  ),
                if (isJump)
                  Positioned(
                    top: 64,
                    child: Container(
                      width: 92,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                  ),
                if (isWave)
                  Positioned(
                    top: 65,
                    child: Container(
                      width: 90,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(26),
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
    final isProud = mood == MascotMood.proud;
    final yShift = isLaugh
        ? motionPulse * 3
        : isWave
        ? (left ? -1.5 : 2.0) + motionPulse * 2
        : isCelebrate
        ? -2.0 + motionPulse * 2
        : isJump
        ? -1.0 + motionPulse * 1.5
        : isProud
        ? -1.4 + motionPulse * 1.2
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
