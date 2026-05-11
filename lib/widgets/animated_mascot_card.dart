import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum MascotEmotion { happy, sad, shocked, crying, laughing, calm }

extension MascotEmotionX on MascotEmotion {
  String get label {
    switch (this) {
      case MascotEmotion.happy:
        return 'Happy';
      case MascotEmotion.sad:
        return 'Sad';
      case MascotEmotion.shocked:
        return 'Shock';
      case MascotEmotion.crying:
        return 'Cry';
      case MascotEmotion.laughing:
        return 'Laugh';
      case MascotEmotion.calm:
        return 'Calm';
    }
  }

  String get message {
    switch (this) {
      case MascotEmotion.happy:
        return 'Ready for another win.';
      case MascotEmotion.sad:
        return 'A slow day still counts.';
      case MascotEmotion.shocked:
        return 'New word unlocked!';
      case MascotEmotion.crying:
        return 'Tough lesson? We can retry.';
      case MascotEmotion.laughing:
        return 'That answer was wild.';
      case MascotEmotion.calm:
        return 'Steady beats rushed.';
    }
  }

  List<Color> get gradientColors {
    switch (this) {
      case MascotEmotion.happy:
        return const [Color(0xFFEAF8FF), Color(0xFFD8EEFF), Color(0xFFF8F2FF)];
      case MascotEmotion.sad:
        return const [Color(0xFFE7F0FF), Color(0xFFD9E2F8), Color(0xFFF4F7FC)];
      case MascotEmotion.shocked:
        return const [Color(0xFFEAF4FF), Color(0xFFFBE6EA), Color(0xFFFFF6DF)];
      case MascotEmotion.crying:
        return const [Color(0xFFE8F1FF), Color(0xFFDDEBFF), Color(0xFFF5F8FF)];
      case MascotEmotion.laughing:
        return const [Color(0xFFFFF0DF), Color(0xFFFFE1C2), Color(0xFFF8F6FF)];
      case MascotEmotion.calm:
        return const [Color(0xFFE8F4EC), Color(0xFFDFF0E6), Color(0xFFF3FAF5)];
    }
  }

  Color get accentColor {
    switch (this) {
      case MascotEmotion.happy:
        return const Color(0xFF2F8FEA);
      case MascotEmotion.sad:
        return const Color(0xFF5877C8);
      case MascotEmotion.shocked:
        return const Color(0xFFE27C5F);
      case MascotEmotion.crying:
        return const Color(0xFF4D86D8);
      case MascotEmotion.laughing:
        return const Color(0xFFF0A53A);
      case MascotEmotion.calm:
        return const Color(0xFF55A86E);
    }
  }
}

class AnimatedMascotCard extends StatefulWidget {
  final String? userName;

  const AnimatedMascotCard({super.key, this.userName});

  @override
  State<AnimatedMascotCard> createState() => _AnimatedMascotCardState();
}

class _AnimatedMascotCardState extends State<AnimatedMascotCard>
    with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final AnimationController _laughController;
  late final AnimationController _blinkController;
  MascotEmotion _emotion = MascotEmotion.happy;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _laughController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    );
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
    _syncLaughAnimation();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _laughController.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  void _syncLaughAnimation() {
    if (_emotion == MascotEmotion.laughing) {
      _laughController.repeat(reverse: true);
    } else {
      _laughController.stop();
      _laughController.value = 0;
    }
  }

  void _setEmotion(MascotEmotion emotion) {
    if (_emotion == emotion) {
      return;
    }
    setState(() => _emotion = emotion);
    _syncLaughAnimation();
  }

  void _cycleEmotion() {
    final emotions = MascotEmotion.values;
    final nextIndex = (_emotion.index + 1) % emotions.length;
    _setEmotion(emotions[nextIndex]);
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.userName?.trim().isNotEmpty == true
        ? widget.userName!.trim()
        : 'trainer';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _emotion.gradientColors,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -18,
            top: -20,
            child: _DecorativeOrb(
              color: _emotion.accentColor.withOpacity(0.12),
              size: 76,
            ),
          ),
          Positioned(
            left: -26,
            bottom: -18,
            child: _DecorativeOrb(
              color: Colors.white.withOpacity(0.22),
              size: 54,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Meet your mascot, $displayName',
                      style: AppTextStyles.sectionTitle.copyWith(
                        fontSize: 20,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.08),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        _emotion.message,
                        key: ValueKey(_emotion),
                        style: AppTextStyles.greetingDate.copyWith(
                          color: AppColors.textPrimary.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: MascotEmotion.values.map((emotion) {
                        final selected = emotion == _emotion;
                        return GestureDetector(
                          onTap: () => _setEmotion(emotion),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOut,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? _emotion.accentColor
                                  : Colors.white.withOpacity(0.48),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: selected
                                    ? _emotion.accentColor
                                    : Colors.white.withOpacity(0.28),
                              ),
                              boxShadow: selected
                                  ? [
                                      BoxShadow(
                                        color: _emotion.accentColor.withOpacity(
                                          0.25,
                                        ),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              emotion.label,
                              style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              GestureDetector(
                onTap: _cycleEmotion,
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _floatController,
                    _laughController,
                    _blinkController,
                  ]),
                  builder: (context, child) {
                    final floatY =
                        math.sin(_floatController.value * math.pi * 2) * 6;
                    final tilt =
                        math.sin(_floatController.value * math.pi * 2) * 0.035;
                    return Transform.translate(
                      offset: Offset(0, floatY),
                      child: Transform.rotate(angle: tilt, child: child),
                    );
                  },
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 420),
                    switchInCurve: Curves.elasticOut,
                    switchOutCurve: Curves.easeInOut,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(
                            begin: 0.84,
                            end: 1,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _MascotFigure(
                      key: ValueKey(_emotion),
                      emotion: _emotion,
                      laughPhase: _emotion == MascotEmotion.laughing
                          ? _laughController.value
                          : 0.0,
                      blinkPhase: _blinkController.value,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DecorativeOrb extends StatelessWidget {
  final Color color;
  final double size;

  const _DecorativeOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _MascotFigure extends StatelessWidget {
  final MascotEmotion emotion;
  final double laughPhase;
  final double blinkPhase;

  const _MascotFigure({
    super.key,
    required this.emotion,
    required this.laughPhase,
    required this.blinkPhase,
  });

  @override
  Widget build(BuildContext context) {
    final isLaughing = emotion == MascotEmotion.laughing;
    final isShocked = emotion == MascotEmotion.shocked;
    final isCrying = emotion == MascotEmotion.crying;
    final isSad = emotion == MascotEmotion.sad;
    final laughPulse = laughPhase == 0
        ? 0.0
        : (math.sin(laughPhase * math.pi * 2) + 1) / 2;

    return SizedBox(
      width: 160,
      height: 182,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 26,
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
            top: 6,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _MascotEar(left: true, mood: emotion, laughPulse: laughPulse),
                SizedBox(width: 70),
                _MascotEar(left: false, mood: emotion, laughPulse: laughPulse),
              ],
            ),
          ),
          Positioned(
            top: 44,
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
            top: 56,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _MascotEye(
                  emotion: emotion,
                  side: _EyeSide.left,
                  laughPulse: laughPulse,
                  blinkPhase: blinkPhase,
                ),
                const SizedBox(width: 18),
                _MascotEye(
                  emotion: emotion,
                  side: _EyeSide.right,
                  laughPulse: laughPulse,
                  blinkPhase: blinkPhase,
                ),
              ],
            ),
          ),
          Positioned(
            top: 84,
            child: _MascotBeak(emotion: emotion, laughPulse: laughPulse),
          ),
          Positioned(
            top: 100,
            child: _MascotMouth(emotion: emotion, laughPulse: laughPulse),
          ),
          if (isSad || isCrying)
            Positioned(
              top: 82,
              left: 44,
              child: _MascotTear(isLeft: true, strong: isCrying),
            ),
          if (isSad || isCrying)
            Positioned(
              top: 82,
              right: 44,
              child: _MascotTear(isLeft: false, strong: isCrying),
            ),
          Positioned(
            top: 42,
            left: 36,
            child: _MascotBrow(
              emotion: emotion,
              side: _EyeSide.left,
              laughPulse: laughPulse,
            ),
          ),
          Positioned(
            top: 42,
            right: 36,
            child: _MascotBrow(
              emotion: emotion,
              side: _EyeSide.right,
              laughPulse: laughPulse,
            ),
          ),
          Positioned(top: 116, left: 28, child: _MascotCheek(emotion: emotion)),
          Positioned(
            top: 116,
            right: 28,
            child: _MascotCheek(emotion: emotion),
          ),
          Positioned(
            bottom: 2,
            child: Container(
              width: 78,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.08),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          if (isLaughing)
            Positioned(
              top: 88,
              child: Container(
                width: 38,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFFF08D4E),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          if (isShocked)
            Positioned(
              top: 92,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3C1AA),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

enum _EyeSide { left, right }

class _MascotEar extends StatelessWidget {
  final bool left;
  final MascotEmotion mood;
  final double laughPulse;

  const _MascotEar({
    required this.left,
    required this.mood,
    required this.laughPulse,
  });

  @override
  Widget build(BuildContext context) {
    final isLaughing = mood == MascotEmotion.laughing;
    final isCrying = mood == MascotEmotion.crying;
    final bounce = isLaughing
        ? (3 + laughPulse * 5)
        : isCrying
        ? -3.0
        : 0.0;
    final squash = isLaughing ? (0.92 + laughPulse * 0.08) : 1.0;

    return Transform.rotate(
      angle: (left ? -0.22 : 0.22) + (isLaughing ? (left ? -0.08 : 0.08) : 0),
      child: Transform.translate(
        offset: Offset(0, bounce),
        child: Transform.scale(
          scaleY: squash,
          child: Container(
            width: 24,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFF1F7FDB),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }
}

class _MascotEye extends StatelessWidget {
  final MascotEmotion emotion;
  final _EyeSide side;
  final double laughPulse;
  final double blinkPhase;

  const _MascotEye({
    required this.emotion,
    required this.side,
    required this.laughPulse,
    required this.blinkPhase,
  });

  @override
  Widget build(BuildContext context) {
    final closed = emotion == MascotEmotion.laughing;
    final shocked = emotion == MascotEmotion.shocked;
    final sad = emotion == MascotEmotion.sad || emotion == MascotEmotion.crying;
    final laughOffset = emotion == MascotEmotion.laughing
        ? -2 + (laughPulse * 2)
        : 0.0;
    final blinkOpen = _blinkOpenValue(blinkPhase);
    final blinkScale = closed ? 1.0 : blinkOpen;

    if (closed) {
      return Transform.translate(
        offset: Offset(0, laughOffset),
        child: Transform.rotate(
          angle: side == _EyeSide.left ? -0.14 : 0.14,
          child: Container(
            width: 22 + (laughPulse * 6),
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ),
      );
    }

    return Transform.translate(
      offset: Offset(0, laughOffset),
      child: Transform.scale(
        scaleY: blinkScale,
        child: Container(
          width: shocked ? 23 : 18,
          height: shocked ? 23 : 18,
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
                offset: Offset(0, sad ? 3 : 0),
                child: Container(
                  width: shocked ? 9 : 7,
                  height: shocked ? 9 : 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1F4A78),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              if (emotion == MascotEmotion.calm)
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
      ),
    );
  }
}

double _blinkOpenValue(double phase) {
  if (phase < 0.04) {
    return 1.0 - (phase / 0.04);
  }
  if (phase < 0.08) {
    return phase / 0.04 - 1.0;
  }
  return 1.0;
}

class _MascotBrow extends StatelessWidget {
  final MascotEmotion emotion;
  final _EyeSide side;
  final double laughPulse;

  const _MascotBrow({
    required this.emotion,
    required this.side,
    required this.laughPulse,
  });

  @override
  Widget build(BuildContext context) {
    final isSad =
        emotion == MascotEmotion.sad || emotion == MascotEmotion.crying;
    final isShocked = emotion == MascotEmotion.shocked;
    final isLaughing = emotion == MascotEmotion.laughing;

    final width = isLaughing ? 22.0 : 20.0;
    final height = isSad
        ? 9.0
        : isShocked
        ? 8.0
        : 7.0;
    final lift = isLaughing
        ? 1 + (laughPulse * 2)
        : isSad
        ? 2.0
        : isShocked
        ? -1.0
        : 0.5;

    return Transform.translate(
      offset: Offset(0, lift),
      child: SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          painter: _MascotBrowPainter(
            emotion: emotion,
            side: side,
            laughPulse: laughPulse,
          ),
        ),
      ),
    );
  }
}

class _MascotBrowPainter extends CustomPainter {
  final MascotEmotion emotion;
  final _EyeSide side;
  final double laughPulse;

  _MascotBrowPainter({
    required this.emotion,
    required this.side,
    required this.laughPulse,
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

    if (emotion == MascotEmotion.sad || emotion == MascotEmotion.crying) {
      final curveDrop = emotion == MascotEmotion.crying ? 4.0 : 3.0;
      path.moveTo(left ? size.width : 0, 2);
      path.quadraticBezierTo(
        size.width / 2,
        curveDrop,
        left ? 0 : size.width,
        size.height - 1,
      );
    } else if (emotion == MascotEmotion.shocked) {
      path.moveTo(0, size.height - 2);
      path.quadraticBezierTo(size.width / 2, 0, size.width, size.height - 2);
    } else if (emotion == MascotEmotion.laughing) {
      final peak = 2.0 + laughPulse * 1.2;
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
    return oldDelegate.emotion != emotion ||
        oldDelegate.side != side ||
        oldDelegate.laughPulse != laughPulse;
  }
}

class _MascotCheek extends StatelessWidget {
  final MascotEmotion emotion;

  const _MascotCheek({required this.emotion});

  @override
  Widget build(BuildContext context) {
    final active =
        emotion == MascotEmotion.happy ||
        emotion == MascotEmotion.laughing ||
        emotion == MascotEmotion.calm;

    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: active ? const Color(0xFFFFC0C8) : const Color(0xFFFFD6DB),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _MascotBeak extends StatelessWidget {
  final MascotEmotion emotion;
  final double laughPulse;

  const _MascotBeak({required this.emotion, required this.laughPulse});

  @override
  Widget build(BuildContext context) {
    final width = emotion == MascotEmotion.shocked ? 30.0 : 26.0;
    final isLaughing = emotion == MascotEmotion.laughing;
    return Container(
      width: width,
      height: 14,
      child: Transform.translate(
        offset: Offset(0, isLaughing ? 1 + laughPulse * 2 : 0),
        child: Transform.scale(
          scaleY: isLaughing ? 1.05 + laughPulse * 0.08 : 1,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFA66B),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFE86C53), width: 1.4),
            ),
          ),
        ),
      ),
    );
  }
}

class _MascotMouth extends StatelessWidget {
  final MascotEmotion emotion;
  final double laughPulse;

  const _MascotMouth({required this.emotion, required this.laughPulse});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 26,
      child: CustomPaint(painter: _MascotMouthPainter(emotion, laughPulse)),
    );
  }
}

class _MascotMouthPainter extends CustomPainter {
  final MascotEmotion emotion;
  final double laughPulse;

  _MascotMouthPainter(this.emotion, this.laughPulse);

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

    final sad = emotion == MascotEmotion.sad;
    final crying = emotion == MascotEmotion.crying;
    final shocked = emotion == MascotEmotion.shocked;
    final laughing = emotion == MascotEmotion.laughing;
    final happy = emotion == MascotEmotion.happy;

    if (shocked) {
      final rect = Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: 16,
        height: 20,
      );
      canvas.drawOval(rect, strokePaint);
      return;
    }

    if (laughing) {
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

    if (sad || crying) {
      final rect = Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2 + 3),
        width: 22,
        height: 14,
      );
      canvas.drawArc(rect, math.pi, math.pi, false, strokePaint);
      return;
    }

    if (happy) {
      final rect = Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2 - 1),
        width: 24,
        height: 18,
      );
      canvas.drawArc(rect, 0.15 * math.pi, 0.72 * math.pi, false, strokePaint);
      return;
    }

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 18,
      height: 10,
    );
    canvas.drawArc(rect, 0.15 * math.pi, 0.7 * math.pi, false, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _MascotMouthPainter oldDelegate) {
    return oldDelegate.emotion != emotion ||
        oldDelegate.laughPulse != laughPulse;
  }
}

class _MascotTear extends StatefulWidget {
  final bool isLeft;
  final bool strong;

  const _MascotTear({required this.isLeft, required this.strong});

  @override
  State<_MascotTear> createState() => _MascotTearState();
}

class _MascotTearState extends State<_MascotTear>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tearController;

  @override
  void initState() {
    super.initState();
    _tearController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.strong ? 820 : 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _tearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _tearController,
      builder: (context, child) {
        final progress = Curves.easeIn.transform(_tearController.value);
        final fall = progress * (widget.strong ? 18.0 : 14.0);
        final fade = 1.0 - (progress * 0.35);

        return Opacity(
          opacity: fade,
          child: Transform.translate(
            offset: Offset(0, fall),
            child: Transform.rotate(
              angle: widget.isLeft ? -0.28 : 0.28,
              child: child,
            ),
          ),
        );
      },
      child: Container(
        width: widget.strong ? 10 : 8,
        height: widget.strong ? 18 : 14,
        decoration: BoxDecoration(
          color: widget.strong
              ? const Color(0xFF5BB6FF)
              : const Color(0xFF83C7FF),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(widget.strong ? 10 : 8),
            topRight: Radius.circular(widget.strong ? 10 : 8),
            bottomLeft: Radius.circular(widget.strong ? 10 : 8),
            bottomRight: Radius.circular(widget.strong ? 10 : 8),
          ),
        ),
      ),
    );
  }
}
