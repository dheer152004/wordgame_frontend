import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'mascot_art.dart';
import 'mascot_mood.dart';

class AnimatedMascotCard extends StatefulWidget {
  final String? userName;

  const AnimatedMascotCard({super.key, this.userName});

  @override
  State<AnimatedMascotCard> createState() => _AnimatedMascotCardState();
}

class _AnimatedMascotCardState extends State<AnimatedMascotCard>
    with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final AnimationController _blinkController;
  late final AnimationController _motionController;

  MascotMood _mood = MascotMood.idle;

  static const List<MascotMood> _moods = [
    MascotMood.idle,
    MascotMood.blink,
    MascotMood.sleepy,
    MascotMood.proud,
    MascotMood.happy,
    MascotMood.sad,
    MascotMood.laugh,
    MascotMood.cry,
    MascotMood.angry,
    MascotMood.shocked,
    MascotMood.wave,
    MascotMood.jump,
    MascotMood.tapReaction,
    MascotMood.celebration,
  ];

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
    _motionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 780),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    _blinkController.dispose();
    _motionController.dispose();
    super.dispose();
  }

  void _selectMood(MascotMood mood) {
    if (_mood == mood) {
      return;
    }
    setState(() {
      _mood = mood;
    });
  }

  void _cycleMood() {
    final nextIndex = (_moods.indexOf(_mood) + 1) % _moods.length;
    _selectMood(_moods[nextIndex]);
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.userName?.trim().isNotEmpty == true
        ? widget.userName!.trim()
        : 'trainer';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _mood.gradientColors,
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 560;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: -8,
                top: 42,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.24,
                    child: CustomPaint(
                      size: const Size(56, 76),
                      painter: _EggDecorationPainter(
                        color: Colors.white.withOpacity(0.7),
                        accent: _mood.accentColor.withOpacity(0.18),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: -18,
                top: -20,
                child: _DecorativeOrb(
                  color: _mood.accentColor.withOpacity(0.12),
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
              if (isCompact)
                Column(
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
                        _mood.message,
                        key: ValueKey(_mood),
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
                      children: _moods.map((mood) {
                        final selected = mood == _mood;
                        return GestureDetector(
                          onTap: () => _selectMood(mood),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOut,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? _mood.accentColor
                                  : Colors.white.withOpacity(0.48),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: selected
                                    ? _mood.accentColor
                                    : Colors.white.withOpacity(0.28),
                              ),
                              boxShadow: selected
                                  ? [
                                      BoxShadow(
                                        color: _mood.accentColor.withOpacity(
                                          0.25,
                                        ),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              mood.label,
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
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: _cycleMood,
                        child: AnimatedBuilder(
                          animation: Listenable.merge([
                            _floatController,
                            _blinkController,
                            _motionController,
                          ]),
                          builder: (context, _) {
                            return FittedBox(
                              fit: BoxFit.scaleDown,
                              child: buildMascotArt(
                                mood: _mood,
                                floatPhase: _floatController.value,
                                blinkPhase: _blinkController.value,
                                motionPhase: _motionController.value,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                )
              else
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
                              _mood.message,
                              key: ValueKey(_mood),
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
                            children: _moods.map((mood) {
                              final selected = mood == _mood;
                              return GestureDetector(
                                onTap: () => _selectMood(mood),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 220),
                                  curve: Curves.easeOut,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? _mood.accentColor
                                        : Colors.white.withOpacity(0.48),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: selected
                                          ? _mood.accentColor
                                          : Colors.white.withOpacity(0.28),
                                    ),
                                    boxShadow: selected
                                        ? [
                                            BoxShadow(
                                              color: _mood.accentColor
                                                  .withOpacity(0.25),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Text(
                                    mood.label,
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
                      onTap: _cycleMood,
                      child: AnimatedBuilder(
                        animation: Listenable.merge([
                          _floatController,
                          _blinkController,
                          _motionController,
                        ]),
                        builder: (context, _) {
                          return buildMascotArt(
                            mood: _mood,
                            floatPhase: _floatController.value,
                            blinkPhase: _blinkController.value,
                            motionPhase: _motionController.value,
                          );
                        },
                      ),
                    ),
                  ],
                ),
            ],
          );
        },
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

class _EggDecorationPainter extends CustomPainter {
  final Color color;
  final Color accent;

  const _EggDecorationPainter({required this.color, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.05)
      ..style = PaintingStyle.fill;
    final accentPaint = Paint()
      ..color = accent
      ..style = PaintingStyle.fill;

    final eggPath = Path()
      ..moveTo(size.width / 2, 0)
      ..cubicTo(
        size.width * 0.16,
        size.height * 0.2,
        size.width * 0.08,
        size.height * 0.75,
        size.width / 2,
        size.height,
      )
      ..cubicTo(
        size.width * 0.92,
        size.height * 0.75,
        size.width * 0.84,
        size.height * 0.2,
        size.width / 2,
        0,
      );

    final highlightPath = Path()
      ..moveTo(size.width * 0.42, size.height * 0.12)
      ..cubicTo(
        size.width * 0.25,
        size.height * 0.28,
        size.width * 0.24,
        size.height * 0.56,
        size.width * 0.4,
        size.height * 0.82,
      )
      ..cubicTo(
        size.width * 0.28,
        size.height * 0.5,
        size.width * 0.3,
        size.height * 0.24,
        size.width * 0.42,
        size.height * 0.12,
      );

    canvas.drawPath(eggPath.shift(const Offset(2, 3)), shadowPaint);
    canvas.drawPath(eggPath, basePaint);
    canvas.drawPath(highlightPath, accentPaint);
  }

  @override
  bool shouldRepaint(covariant _EggDecorationPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.accent != accent;
  }
}


// import 'package:flutter/material.dart';

// import '../../theme/app_theme.dart';
// import 'mascot_art.dart';
// import 'mascot_mood.dart';

// class AnimatedMascotCard extends StatefulWidget {
//   final String? userName;

//   const AnimatedMascotCard({super.key, this.userName});

//   @override
//   State<AnimatedMascotCard> createState() => _AnimatedMascotCardState();
// }

// class _AnimatedMascotCardState extends State<AnimatedMascotCard>
//     with TickerProviderStateMixin {
//   late final AnimationController _floatController;
//   late final AnimationController _blinkController;
//   late final AnimationController _motionController;

//   MascotMood _mood = MascotMood.idle;

//   static const List<MascotMood> _moods = [
//     MascotMood.idle,
//     MascotMood.blink,
//       child: LayoutBuilder(
//         builder: (context, constraints) {
//           final isCompact = constraints.maxWidth < 560;

//           return Stack(
//             clipBehavior: Clip.none,
//             children: [
//               Positioned(
//                 left: -8,
//                 top: 42,
//                 child: IgnorePointer(
//                   child: Opacity(
//                     opacity: 0.24,
//                     child: CustomPaint(
//                       size: const Size(56, 76),
//                       painter: _EggDecorationPainter(
//                         color: Colors.white.withOpacity(0.7),
//                         accent: _mood.accentColor.withOpacity(0.18),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 right: -18,
//                 top: -20,
//                 child: _DecorativeOrb(
//                   color: _mood.accentColor.withOpacity(0.12),
//                   size: 76,
//                 ),
//               ),
//               Positioned(
//                 left: -26,
//                 bottom: -18,
//                 child: _DecorativeOrb(
//                   color: Colors.white.withOpacity(0.22),
//                   size: 54,
//                 ),
//               ),
//               if (isCompact)
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       'Meet your mascot, $displayName',
//                       style: AppTextStyles.sectionTitle.copyWith(
//                         fontSize: 20,
//                         color: AppColors.textPrimary,
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     AnimatedSwitcher(
//                       duration: const Duration(milliseconds: 260),
//                       transitionBuilder: (child, animation) {
//                         return FadeTransition(
//                           opacity: animation,
//                           child: SlideTransition(
//                             position: Tween<Offset>(
//                               begin: const Offset(0, 0.08),
//                               end: Offset.zero,
//                             ).animate(animation),
//                             child: child,
//                           ),
//                         );
//                       },
//                       child: Text(
//                         _mood.message,
//                         key: ValueKey(_mood),
//                         style: AppTextStyles.greetingDate.copyWith(
//                           color: AppColors.textPrimary.withOpacity(0.8),
//                           fontSize: 14,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 14),
//                     Wrap(
//                       spacing: 8,
//                       runSpacing: 8,
//                       children: _moods.map((mood) {
//                         final selected = mood == _mood;
//                         return GestureDetector(
//                           onTap: () => _selectMood(mood),
//                           child: AnimatedContainer(
//                             duration: const Duration(milliseconds: 220),
//                             curve: Curves.easeOut,
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 8,
//                             ),
//                             decoration: BoxDecoration(
//                               color: selected
//                                   ? _mood.accentColor
//                                   : Colors.white.withOpacity(0.48),
//                               borderRadius: BorderRadius.circular(999),
//                               border: Border.all(
//                                 color: selected
//                                     ? _mood.accentColor
//                                     : Colors.white.withOpacity(0.28),
//                               ),
//                               boxShadow: selected
//                                   ? [
//                                       BoxShadow(
//                                         color: _mood.accentColor.withOpacity(
//                                           0.25,
//                                         ),
//                                         blurRadius: 12,
//                                         offset: const Offset(0, 4),
//                                       ),
//                                     ]
//                                   : null,
//                             ),
//                             child: Text(
//                               mood.label,
//                               style: TextStyle(
//                                 color: selected
//                                     ? Colors.white
//                                     : AppColors.textPrimary,
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w700,
//                                 letterSpacing: 0.2,
//                               ),
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                     const SizedBox(height: 16),
//                     Align(
//                       alignment: Alignment.centerRight,
//                       child: GestureDetector(
//                         onTap: _cycleMood,
//                         child: AnimatedBuilder(
//                           animation: Listenable.merge([
//                             _floatController,
//                             _blinkController,
//                             _motionController,
//                           ]),
//                           builder: (context, _) {
//                             return FittedBox(
//                               fit: BoxFit.scaleDown,
//                               child: buildMascotArt(
//                                 mood: _mood,
//                                 floatPhase: _floatController.value,
//                                 blinkPhase: _blinkController.value,
//                                 motionPhase: _motionController.value,
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ),
//                   ],
//                 )
//               else
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text(
//                             'Meet your mascot, $displayName',
//                             style: AppTextStyles.sectionTitle.copyWith(
//                               fontSize: 20,
//                               color: AppColors.textPrimary,
//                             ),
//                           ),
//                           const SizedBox(height: 6),
//                           AnimatedSwitcher(
//                             duration: const Duration(milliseconds: 260),
//                             transitionBuilder: (child, animation) {
//                               return FadeTransition(
//                                 opacity: animation,
//                                 child: SlideTransition(
//                                   position: Tween<Offset>(
//                                     begin: const Offset(0, 0.08),
//                                     end: Offset.zero,
//                                   ).animate(animation),
//                                   child: child,
//                                 ),
//                               );
//                             },
//                             child: Text(
//                               _mood.message,
//                               key: ValueKey(_mood),
//                               style: AppTextStyles.greetingDate.copyWith(
//                                 color: AppColors.textPrimary.withOpacity(0.8),
//                                 fontSize: 14,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 14),
//                           Wrap(
//                             spacing: 8,
//                             runSpacing: 8,
//                             children: _moods.map((mood) {
//                               final selected = mood == _mood;
//                               return GestureDetector(
//                                 onTap: () => _selectMood(mood),
//                                 child: AnimatedContainer(
//                                   duration: const Duration(milliseconds: 220),
//                                   curve: Curves.easeOut,
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 12,
//                                     vertical: 8,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: selected
//                                         ? _mood.accentColor
//                                         : Colors.white.withOpacity(0.48),
//                                     borderRadius: BorderRadius.circular(999),
//                                     border: Border.all(
//                                       color: selected
//                                           ? _mood.accentColor
//                                           : Colors.white.withOpacity(0.28),
//                                     ),
//                                     boxShadow: selected
//                                         ? [
//                                             BoxShadow(
//                                               color: _mood.accentColor
//                                                   .withOpacity(0.25),
//                                               blurRadius: 12,
//                                               offset: const Offset(0, 4),
//                                             ),
//                                           ]
//                                         : null,
//                                   ),
//                                   child: Text(
//                                     mood.label,
//                                     style: TextStyle(
//                                       color: selected
//                                           ? Colors.white
//                                           : AppColors.textPrimary,
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w700,
//                                       letterSpacing: 0.2,
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             }).toList(),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(width: 14),
//                     GestureDetector(
//                       onTap: _cycleMood,
//                       child: AnimatedBuilder(
//                         animation: Listenable.merge([
//                           _floatController,
//                           _blinkController,
//                           _motionController,
//                         ]),
//                         builder: (context, _) {
//                           return buildMascotArt(
//                             mood: _mood,
//                             floatPhase: _floatController.value,
//                             blinkPhase: _blinkController.value,
//                             motionPhase: _motionController.value,
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//             ],
//           );
//         },
//       ),
//       );

//     canvas.drawPath(eggPath.shift(const Offset(2, 3)), shadowPaint);
//     canvas.drawPath(eggPath, basePaint);
//     canvas.drawPath(highlightPath, accentPaint);
//   }

//   @override
//   bool shouldRepaint(covariant _EggDecorationPainter oldDelegate) {
//     return oldDelegate.color != color || oldDelegate.accent != accent;
//   }
// }
