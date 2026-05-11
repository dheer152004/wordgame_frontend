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
    final ankleBounce = isJump ? motionPulse * 4 : 0.0;

    return Positioned(
      bottom: 0,
      child: Transform.translate(
        offset: Offset(0, -jumpLift + (isCelebrate ? motionPulse * 2 : 0)),
        child: SizedBox(
          width: 74,
          height: 62,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                left: 11,
                bottom: 0,
                child: _CuteLeg(
                  angle: isJump ? -0.08 : -0.02,
                  bounce: ankleBounce,
                ),
              ),
              Positioned(
                right: 11,
                bottom: 0,
                child: _CuteLeg(
                  angle: isJump ? 0.08 : 0.02,
                  bounce: ankleBounce,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CuteLeg extends StatelessWidget {
  final double angle;
  final double bounce;

  const _CuteLeg({required this.angle, required this.bounce});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, bounce),
      child: Transform.rotate(
        angle: angle,
        child: SizedBox(
          width: 18,
          height: 36,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Positioned(
                bottom: 0,
                child: ClipPath(
                  clipper: _EggLegClipper(),
                  child: Container(
                    width: 18,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F8FEA),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2F8FEA).withOpacity(0.16),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 6,
                child: ClipPath(
                  clipper: _EggLegHighlightClipper(),
                  child: Container(
                    width: 10,
                    height: 18,
                    color: Colors.white.withOpacity(0.08),
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

class _EggLegClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final lowerCircle = Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height * 0.72),
          width: size.width * 0.96,
          height: size.height * 0.78,
        ),
      );
    final upperCircle = Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height * 0.26),
          width: size.width * 0.58,
          height: size.height * 0.42,
        ),
      );
    return Path.combine(PathOperation.union, lowerCircle, upperCircle);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _EggLegHighlightClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final lowerCircle = Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height * 0.72),
          width: size.width * 0.96,
          height: size.height * 0.76,
        ),
      );
    final upperCircle = Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height * 0.28),
          width: size.width * 0.48,
          height: size.height * 0.34,
        ),
      );
    return Path.combine(PathOperation.union, lowerCircle, upperCircle);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
