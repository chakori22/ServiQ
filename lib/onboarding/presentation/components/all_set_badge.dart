import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/app_color.dart';

/// The teal check inside its dashed orbit on the closing screen.
///
/// Onboarding draws its own rather than importing the login flow's verified
/// badge: the ring here is wider and unspeckled, and the two screens should be
/// free to diverge.
class AllSetBadge extends StatelessWidget {
  const AllSetBadge({super.key, this.size = 240});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The soft halo the design bleeds behind the ring.
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColor.authSuccessLight.withValues(alpha: 0.20),
                  AppColor.authSuccessLight.withValues(alpha: 0),
                ],
              ),
            ),
          ),
          CustomPaint(
            size: Size(size, size),
            painter: _DashedRingPainter(),
          ),
          Container(
            width: size * 0.46,
            height: size * 0.46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColor.authSuccessLight, AppColor.authSuccess],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColor.authSuccess.withValues(alpha: 0.30),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Icon(
              Icons.check_rounded,
              size: size * 0.22,
              color: AppColor.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColor.authSuccessLight.withValues(alpha: 0.55)
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final radius = size.width / 2 - 12;
    final center = Offset(size.width / 2, size.height / 2);
    const dashes = 48;
    const sweep = (2 * math.pi) / dashes;
    for (var i = 0; i < dashes; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * sweep,
        sweep * 0.42,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
