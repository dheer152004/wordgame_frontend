import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'mascot_mood.dart';

class MascotFace extends StatelessWidget {
  final MascotMood mood;
  final double blinkOpen;
  final double laughPulse;
  final double motionPulse;

  const MascotFace({
    super.key,
    required this.mood,
    required this.blinkOpen,
    required this.laughPulse,
    required this.motionPulse,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 24,
      child: SizedBox(
        width: 132,
        height: 132,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 18,
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
              top: 28,
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
            Positioned(
              top: 44,
              left: 22,
              child: _MascotBrow(
                mood: mood,
                side: _EyeSide.left,
                motionPulse: motionPulse,
              ),
            ),
            Positioned(
              top: 44,
              right: 22,
              child: _MascotBrow(
                mood: mood,
                side: _EyeSide.right,
                motionPulse: motionPulse,
              ),
            ),
            Positioned(
              top: 58,
              child: _MascotMouth(
                mood: mood,
                motionPulse: motionPulse,
                laughPulse: laughPulse,
              ),
            ),
            if (mood == MascotMood.happy)
              Positioned(
                top: 60,
                left: 20,
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
                top: 60,
                right: 20,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC6D0).withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            if (mood == MascotMood.shocked)
              Positioned(
                top: 52,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3C1AA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            if (mood == MascotMood.cry)
              Positioned(
                top: 50,
                left: 20,
                child: _MascotTear(progress: motionPulse, strong: true),
              ),
            if (mood == MascotMood.cry)
              Positioned(
                top: 50,
                right: 20,
                child: _MascotTear(progress: motionPulse, strong: true),
              ),
          ],
        ),
      ),
    );
  }
}

enum _EyeSide { left, right }

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
