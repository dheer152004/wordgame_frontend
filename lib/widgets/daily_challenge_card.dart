import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DailyChallengeCard extends StatelessWidget {
  const DailyChallengeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.challengeCard,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Decorative background circle (subtle)
          Positioned(
            right: -20,
            top: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),

          // Content row
          Padding(
            padding: const EdgeInsets.all(22),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Daily\nchallenge',
                        style: AppTextStyles.challengeTitle,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Do your plan before 10:00 AM',
                        style: AppTextStyles.challengeSubtitle,
                      ),
                      const Spacer(),
                      // Participant avatars
                      _ParticipantAvatars(),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Right: 3D donut rings illustration
                SizedBox(
                  width: 110,
                  height: 110,
                  child: _DonutRingsIllustration(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticipantAvatars extends StatelessWidget {
  final List<Color> avatarColors = const [
    Color(0xFFD4A574),
    Color(0xFF8B7355),
    Color(0xFFC4956A),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Overlapping avatar stack
        SizedBox(
          width: 80,
          height: 26,
          child: Stack(
            children: List.generate(avatarColors.length, (i) {
              return Positioned(
                left: i * 18.0,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: avatarColors[i],
                    border: Border.all(color: AppColors.challengeCard, width: 1.5),
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 14),
                ),
              );
            }),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.15),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: const Text(
            '+4',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

/// A custom painter that draws overlapping colorful donut-ring shapes
/// to approximate the 3D rings in the design.
class _DonutRingsIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RingsPainter(),
    );
  }
}

class _RingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rings = [
      _RingData(
        center: Offset(size.width * 0.55, size.height * 0.28),
        outerRadius: size.width * 0.28,
        innerRadius: size.width * 0.16,
        color: const Color(0xFF4A90D9), // blue
        angle: -0.3,
      ),
      _RingData(
        center: Offset(size.width * 0.35, size.height * 0.42),
        outerRadius: size.width * 0.30,
        innerRadius: size.width * 0.17,
        color: const Color(0xFFE8734A), // orange
        angle: 0.2,
      ),
      _RingData(
        center: Offset(size.width * 0.62, size.height * 0.55),
        outerRadius: size.width * 0.26,
        innerRadius: size.width * 0.15,
        color: const Color(0xFF2D2D2D), // dark
        angle: 0.1,
      ),
      _RingData(
        center: Offset(size.width * 0.38, size.height * 0.72),
        outerRadius: size.width * 0.28,
        innerRadius: size.width * 0.16,
        color: const Color(0xFFF5F0EB), // cream/white
        angle: -0.15,
      ),
    ];

    for (final ring in rings) {
      _drawRing(canvas, ring);
    }
  }

  void _drawRing(Canvas canvas, _RingData ring) {
    final paint = Paint()
      ..color = ring.color
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(ring.center.dx, ring.center.dy);
    canvas.rotate(ring.angle);

    // Draw outer ellipse
    final outerRect = Rect.fromCenter(
      center: Offset.zero,
      width: ring.outerRadius * 2,
      height: ring.outerRadius * 1.4,
    );

    // Draw as donut: outer path minus inner hole
    final path = Path()
      ..addOval(outerRect)
      ..addOval(Rect.fromCenter(
        center: Offset.zero,
        width: ring.innerRadius * 2,
        height: ring.innerRadius * 1.4,
      ));
    path.fillType = PathFillType.evenOdd;

    // Slight 3D shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.translate(2, 3);
    canvas.drawPath(path, shadowPaint);
    canvas.translate(-2, -3);

    canvas.drawPath(path, paint);

    // Inner highlight (top of ring lighter)
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..style = PaintingStyle.fill;
    final highlightPath = Path()
      ..addOval(Rect.fromCenter(
        center: const Offset(0, -4),
        width: ring.outerRadius * 1.5,
        height: ring.outerRadius * 0.7,
      ))
      ..addOval(Rect.fromCenter(
        center: Offset.zero,
        width: ring.innerRadius * 2.2,
        height: ring.innerRadius * 1.6,
      ));
    highlightPath.fillType = PathFillType.evenOdd;
    canvas.drawPath(highlightPath, highlightPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RingData {
  final Offset center;
  final double outerRadius;
  final double innerRadius;
  final Color color;
  final double angle;

  const _RingData({
    required this.center,
    required this.outerRadius,
    required this.innerRadius,
    required this.color,
    required this.angle,
  });
}