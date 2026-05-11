import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'mascot_mood.dart';

class MascotStage extends StatelessWidget {
  final MascotMood mood;
  final double floatPhase;
  final double blinkPhase;
  final double motionPhase;

  const MascotStage({
    super.key,
    required this.mood,
    required this.floatPhase,
    required this.blinkPhase,
    required this.motionPhase,
  });

  @override
  Widget build(BuildContext context) {
    final floatWave = math.sin(floatPhase * math.pi * 2);
    final motionWave = motionPhase == 0
        ? 0.0
        : (math.sin(motionPhase * math.pi * 2) + 1) / 2;
    final blinkOpen = _blinkOpenValue(blinkPhase);

    final jumpLift = mood == MascotMood.jump ? motionWave * 12 : 0.0;
    final tapPulse = mood == MascotMood.tapReaction ? motionWave : 0.0;
    final laughPulse = mood == MascotMood.laugh ? motionWave : 0.0;
    final wavePulse = mood == MascotMood.wave ? motionWave : 0.0;
    final celebratePulse = mood == MascotMood.celebration ? motionWave : 0.0;
    final angryPulse = mood == MascotMood.angry ? motionWave : 0.0;
    final idlePulse = mood == MascotMood.idle ? motionWave : 0.0;
    final happyPulse = mood == MascotMood.happy ? motionWave : 0.0;
    final blinkPulse = mood == MascotMood.blink ? motionWave : 0.0;
    final tilt = mood == MascotMood.laugh
        ? floatWave * 0.045
        : mood == MascotMood.angry
        ? -0.03 * angryPulse
        : mood == MascotMood.wave
        ? 0.02 * math.sin(motionPhase * math.pi * 2)
        : mood == MascotMood.jump
        ? floatWave * 0.03
        : mood == MascotMood.happy
        ? 0.03 * happyPulse + 0.012 * floatWave
        : mood == MascotMood.idle
        ? 0.008 * floatWave
        : mood == MascotMood.blink
        ? 0.012 * blinkPulse
        : 0.015 * floatWave;

    final scale =
        1.0 +
        (mood == MascotMood.tapReaction ? tapPulse * 0.05 : 0.0) +
        (mood == MascotMood.celebration ? celebratePulse * 0.04 : 0.0) +
        (mood == MascotMood.jump ? motionWave * 0.025 : 0.0) +
        (mood == MascotMood.happy ? happyPulse * 0.03 : 0.0) +
        (mood == MascotMood.idle ? idlePulse * 0.01 : 0.0) +
        (mood == MascotMood.blink ? blinkPulse * 0.008 : 0.0);

    return SizedBox(
      width: 160,
      height: 184,
      child: Transform.translate(
        offset: Offset(0, floatWave * 6 - jumpLift),
        child: Transform.rotate(
          angle: tilt,
          child: Transform.scale(
            scale: scale,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Positioned(
                  bottom: 6,
                  child: Container(
                    width: 72,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Positioned(
                  top: 24,
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
                  top: 4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _MascotEar(
                        left: true,
                        mood: mood,
                        wavePulse: wavePulse,
                        laughPulse: laughPulse,
                        celebratePulse: celebratePulse,
                      ),
                      const SizedBox(width: 70),
                      _MascotEar(
                        left: false,
                        mood: mood,
                        wavePulse: wavePulse,
                        laughPulse: laughPulse,
                        celebratePulse: celebratePulse,
                      ),
                    ],
                  ),
                ),
                if (mood == MascotMood.tapReaction)
                  Positioned(
                    top: 18,
                    child: _PulseRing(
                      progress: tapPulse,
                      color: mood.accentColor,
                    ),
                  ),
                Positioned(
                  top: 42,
                  child: Container(
                    width: 98,
                    height: 112,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
                Positioned(
                  top: 52,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _MascotEye(
                        mood: mood,
                        side: _EyeSide.left,
                        blinkOpen: blinkOpen,
                        laughPulse: laughPulse,
                      ),
                      const SizedBox(width: 18),
                      _MascotEye(
                        mood: mood,
                        side: _EyeSide.right,
                        blinkOpen: blinkOpen,
                        laughPulse: laughPulse,
                      ),
                    ],
                  ),
                ),
                if (mood == MascotMood.happy)
                  Positioned(
                    top: 98,
                    left: 34,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC6D0).withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                if (mood == MascotMood.happy)
                  Positioned(
                    top: 98,
                    right: 34,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC6D0).withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                Positioned(
                  top: 38,
                  left: 36,
                  child: _MascotBrow(
                    mood: mood,
                    side: _EyeSide.left,
                    motionPulse: motionWave,
                  ),
                ),
                Positioned(
                  top: 38,
                  right: 36,
                  child: _MascotBrow(
                    mood: mood,
                    side: _EyeSide.right,
                    motionPulse: motionWave,
                  ),
                ),
                Positioned(
                  top: 80,
                  child: _MascotMouth(
                    mood: mood,
                    motionPulse: motionWave,
                    laughPulse: laughPulse,
                  ),
                ),
                if (mood == MascotMood.cry)
                  Positioned(
                    top: 74,
                    left: 44,
                    child: _MascotTear(progress: motionWave, strong: true),
                  ),
                if (mood == MascotMood.cry)
                  Positioned(
                    top: 74,
                    right: 44,
                    child: _MascotTear(progress: motionWave, strong: true),
                  ),
                if (mood == MascotMood.wave)
                  Positioned(
                    right: 16,
                    top: 96,
                    child: _WaveArm(progress: wavePulse),
                  ),
                if (mood == MascotMood.celebration)
                  ..._buildConfetti(celebratePulse),
                if (mood == MascotMood.shocked)
                  Positioned(
                    top: 76,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3C1AA),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                if (mood == MascotMood.jump)
                  Positioned(
                    top: 16,
                    child: Container(
                      width: 38,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(999),
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

  List<Widget> _buildConfetti(double pulse) {
    final colors = [
      const Color(0xFFF0A53A),
      const Color(0xFF56A06A),
      const Color(0xFFE76A54),
      const Color(0xFF2F8FEA),
    ];
    final offsets = [
      const Offset(-42, -42),
      const Offset(40, -40),
      const Offset(-36, 26),
      const Offset(38, 20),
    ];

    return List.generate(4, (index) {
      final drift = (index.isEven ? -1 : 1) * pulse * 8;
      return Positioned(
        left: 80 + offsets[index].dx + drift,
        top: 28 + offsets[index].dy - pulse * 10,
        child: Transform.rotate(
          angle: (index + 1) * 0.35 + pulse,
          child: Container(
            width: 10 - (pulse * 2),
            height: 10 - (pulse * 2),
            decoration: BoxDecoration(
              color: colors[index].withOpacity(0.95),
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    });
  }

  double _blinkOpenValue(double phase) {
    if (mood == MascotMood.blink) {
      if (phase < 0.1) {
        return 1.0 - (phase / 0.1);
      }
      if (phase < 0.18) {
        return (phase - 0.1) / 0.08;
      }
      return 1.0;
    }
    if (mood == MascotMood.laugh) {
      return 0.12;
    }
    if (mood == MascotMood.shocked) {
      return 1.0;
    }
    return 1.0;
  }
}

enum _EyeSide { left, right }

class _MascotEar extends StatelessWidget {
  final bool left;
  final MascotMood mood;
  final double wavePulse;
  final double laughPulse;
  final double celebratePulse;

  const _MascotEar({
    required this.left,
    required this.mood,
    required this.wavePulse,
    required this.laughPulse,
    required this.celebratePulse,
  });

  @override
  Widget build(BuildContext context) {
    final isLaugh = mood == MascotMood.laugh;
    final isWave = mood == MascotMood.wave;
    final isJump = mood == MascotMood.jump;
    final isCelebrate = mood == MascotMood.celebration;
    final yShift = isLaugh
        ? 4 + laughPulse * 5
        : isWave
        ? (left ? -2 : 3) + wavePulse * 4
        : isJump
        ? -4 + celebratePulse * 2
        : isCelebrate
        ? -2 + celebratePulse * 3
        : 0.0;

    return Transform.rotate(
      angle:
          (left ? -0.22 : 0.22) +
          (isLaugh ? (left ? -0.08 : 0.08) : 0) +
          (isWave ? (left ? -0.03 : 0.03) : 0),
      child: Transform.translate(
        offset: Offset(0, yShift),
        child: Container(
          width: 24,
          height: 30,
          decoration: BoxDecoration(
            color: const Color(0xFF1F7FDB),
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

class _MascotEye extends StatelessWidget {
  final MascotMood mood;
  final _EyeSide side;
  final double blinkOpen;
  final double laughPulse;

  const _MascotEye({
    required this.mood,
    required this.side,
    required this.blinkOpen,
    required this.laughPulse,
  });

  @override
  Widget build(BuildContext context) {
    final isLaugh = mood == MascotMood.laugh;
    final isSad = mood == MascotMood.sad || mood == MascotMood.cry;
    final isShocked = mood == MascotMood.shocked;
    final isAngry = mood == MascotMood.angry;
    final isHappy = mood == MascotMood.happy;
    final isIdle = mood == MascotMood.idle;
    final isBlinking = mood == MascotMood.blink;

    if (isLaugh) {
      return Transform.rotate(
        angle: side == _EyeSide.left ? -0.12 : 0.12,
        child: Container(
          width: 22 + (laughPulse * 5),
          height: 5,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(99),
          ),
        ),
      );
    }

    if (isBlinking && blinkOpen < 0.55) {
      return Container(
        width: 22,
        height: 5,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(99),
        ),
      );
    }

    final size = isShocked
        ? 23.0
        : isHappy
        ? 20.0
        : isIdle
        ? 17.0
        : 18.0;
    final pupilY = isSad
        ? 3.0
        : isAngry
        ? 2.0
        : isHappy
        ? -0.5
        : isIdle
        ? 0.5
        : 0.0;
    final pupilSize = isShocked
        ? 9.0
        : isHappy
        ? 8.0
        : 7.0;
    final eyeScale = isShocked ? 1.0 : blinkOpen.clamp(0.15, 1.0);

    return Transform.scale(
      scaleY: eyeScale,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF1A1A1A).withOpacity(0.12),
            width: 1,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.translate(
              offset: Offset(0, pupilY),
              child: Container(
                width: pupilSize,
                height: pupilSize,
                decoration: const BoxDecoration(
                  color: Color(0xFF1F4A78),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            if (mood == MascotMood.shocked)
              Positioned(
                top: 4,
                child: Container(
                  width: 6,
                  height: 2,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MascotBrow extends StatelessWidget {
  final MascotMood mood;
  final _EyeSide side;
  final double motionPulse;

  const _MascotBrow({
    required this.mood,
    required this.side,
    required this.motionPulse,
  });

  @override
  Widget build(BuildContext context) {
    final isSad = mood == MascotMood.sad || mood == MascotMood.cry;
    final isShocked = mood == MascotMood.shocked;
    final isAngry = mood == MascotMood.angry;
    final isLaugh = mood == MascotMood.laugh;
    final width = isLaugh ? 22.0 : 20.0;
    final height = isSad
        ? 9.0
        : isShocked
        ? 8.0
        : 7.0;
    final lift = isLaugh
        ? 1 + (motionPulse * 2)
        : isSad
        ? 2.0
        : isShocked
        ? -1.0
        : isAngry
        ? 1.0
        : 0.5;

    return Transform.translate(
      offset: Offset(0, lift),
      child: SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          painter: _MascotBrowPainter(
            mood: mood,
            side: side,
            motionPulse: motionPulse,
          ),
        ),
      ),
    );
  }
}

class _MascotBrowPainter extends CustomPainter {
  final MascotMood mood;
  final _EyeSide side;
  final double motionPulse;

  _MascotBrowPainter({
    required this.mood,
    required this.side,
    required this.motionPulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A1A1A).withOpacity(0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final left = side == _EyeSide.left;

    if (mood == MascotMood.sad || mood == MascotMood.cry) {
      final drop = mood == MascotMood.cry ? 4.0 : 3.0;
      path.moveTo(left ? size.width : 0, 2);
      path.quadraticBezierTo(
        size.width / 2,
        drop,
        left ? 0 : size.width,
        size.height - 1,
      );
    } else if (mood == MascotMood.angry) {
      path.moveTo(0, 1);
      path.quadraticBezierTo(size.width / 2, size.height, size.width, 1);
    } else if (mood == MascotMood.shocked) {
      path.moveTo(0, size.height - 2);
      path.quadraticBezierTo(size.width / 2, 0, size.width, size.height - 2);
    } else if (mood == MascotMood.laugh) {
      final peak = 2.0 + motionPulse * 1.2;
      path.moveTo(left ? 0 : size.width, size.height - 2);
      path.quadraticBezierTo(
        size.width / 2,
        peak,
        left ? size.width : 0,
        size.height - 2,
      );
    } else {
      path.moveTo(0, size.height - 2);
      path.quadraticBezierTo(size.width / 2, 0, size.width, size.height - 2);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MascotBrowPainter oldDelegate) {
    return oldDelegate.mood != mood ||
        oldDelegate.side != side ||
        oldDelegate.motionPulse != motionPulse;
  }
}

class _MascotMouth extends StatelessWidget {
  final MascotMood mood;
  final double motionPulse;
  final double laughPulse;

  const _MascotMouth({
    required this.mood,
    required this.motionPulse,
    required this.laughPulse,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 26,
      child: CustomPaint(
        painter: _MascotMouthPainter(
          mood: mood,
          motionPulse: motionPulse,
          laughPulse: laughPulse,
        ),
      ),
    );
  }
}

class _MascotMouthPainter extends CustomPainter {
  final MascotMood mood;
  final double motionPulse;
  final double laughPulse;

  _MascotMouthPainter({
    required this.mood,
    required this.motionPulse,
    required this.laughPulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.fill;

    if (mood == MascotMood.shocked) {
      final rect = Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: 16,
        height: 20,
      );
      canvas.drawOval(rect, strokePaint);
      return;
    }

    if (mood == MascotMood.laugh) {
      final laughWidth = 26 + (laughPulse * 8);
      final laughHeight = 18 + (laughPulse * 5);
      final rect = Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2 + 2 + laughPulse),
        width: laughWidth,
        height: laughHeight,
      );
      canvas.drawOval(rect, fillPaint);

      final tongue = Paint()
        ..color = const Color(0xFFF06575)
        ..style = PaintingStyle.fill;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2 + 7 + laughPulse),
          width: 11 + (laughPulse * 2),
          height: 7 + laughPulse,
        ),
        tongue,
      );
      return;
    }

    if (mood == MascotMood.sad || mood == MascotMood.cry) {
      final rect = Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2 + 3),
        width: 22,
        height: 14,
      );
      canvas.drawArc(rect, math.pi, math.pi, false, strokePaint);
      return;
    }

    if (mood == MascotMood.angry) {
      final rect = Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2 + 1),
        width: 18,
        height: 10,
      );
      canvas.drawArc(rect, math.pi, math.pi, false, strokePaint);
      return;
    }

    if (mood == MascotMood.happy) {
      final rect = Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2 - 1),
        width: 28 + (motionPulse * 2),
        height: 20 + (motionPulse * 2),
      );
      canvas.drawArc(rect, 0.1 * math.pi, 0.8 * math.pi, false, strokePaint);
      return;
    }

    if (mood == MascotMood.idle || mood == MascotMood.blink) {
      final rect = Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2 - 1),
        width: 18 + (motionPulse * 1.5),
        height: 12 + (motionPulse * 1.2),
      );
      canvas.drawArc(rect, 0.18 * math.pi, 0.62 * math.pi, false, strokePaint);
      return;
    }

    final smilePulse =
        mood == MascotMood.tapReaction || mood == MascotMood.celebration
        ? 1.0 + motionPulse * 2.0
        : 0.0;
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 - 1),
      width: 24 + smilePulse,
      height: 18 + (motionPulse * 2),
    );
    canvas.drawArc(rect, 0.15 * math.pi, 0.72 * math.pi, false, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _MascotMouthPainter oldDelegate) {
    return oldDelegate.mood != mood ||
        oldDelegate.motionPulse != motionPulse ||
        oldDelegate.laughPulse != laughPulse;
  }
}

class _MascotTear extends StatelessWidget {
  final double progress;
  final bool strong;

  const _MascotTear({required this.progress, required this.strong});

  @override
  Widget build(BuildContext context) {
    final fall = Curves.easeIn.transform(progress) * (strong ? 18.0 : 14.0);
    final fade = 1.0 - (progress * 0.35);

    return Opacity(
      opacity: fade,
      child: Transform.translate(
        offset: Offset(0, fall),
        child: Transform.rotate(
          angle: -0.28,
          child: Container(
            width: strong ? 10 : 8,
            height: strong ? 18 : 14,
            decoration: BoxDecoration(
              color: strong ? const Color(0xFF5BB6FF) : const Color(0xFF83C7FF),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(strong ? 10 : 8),
                topRight: Radius.circular(strong ? 10 : 8),
                bottomLeft: Radius.circular(strong ? 10 : 8),
                bottomRight: Radius.circular(strong ? 10 : 8),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WaveArm extends StatelessWidget {
  final double progress;

  const _WaveArm({required this.progress});

  @override
  Widget build(BuildContext context) {
    final angle = -0.3 + math.sin(progress * math.pi * 2) * 0.35;
    final yShift = math.cos(progress * math.pi * 2) * 4;

    return Transform.translate(
      offset: Offset(-4, yShift),
      child: Transform.rotate(
        angle: angle,
        alignment: Alignment.center,
        child: Container(
          width: 16,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF1F7FDB),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _PulseRing extends StatelessWidget {
  final double progress;
  final Color color;

  const _PulseRing({required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    final scale = 0.92 + progress * 0.34;
    final opacity = (1.0 - progress).clamp(0.0, 1.0);

    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 116,
          height: 116,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.45), width: 2),
          ),
        ),
      ),
    );
  }
}
