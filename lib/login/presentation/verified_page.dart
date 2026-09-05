import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../components/primary_button.dart';
import '../../core/app_color.dart';
import '../../core/app_routes.dart';
import '../../network/auth_session.dart';
import 'components/auth_chrome.dart';

/// Confirmation shown once verification succeeds, before the dashboard.
///
/// Reads the signed-in number from [AuthSession] rather than the LoginBloc,
/// because the router builds this route outside the bloc's provider.
class VerifiedPage extends StatelessWidget {
  const VerifiedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthSession>().user;
    final number = user == null
        ? null
        : '${user.countryCode} ${user.phoneNumber}';

    return Scaffold(
      backgroundColor: AppColor.authBackgroundTop,
      body: AuthBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(flex: 3),
                const _VerifiedBadge(),
                const SizedBox(height: 32),
                const Text(
                  "You're verified!",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: AppColor.authTextPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Welcome to ServiQ — local services,\nreal help, right near you.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppColor.authTextSecondary,
                  ),
                ),
                if (number != null) ...[
                  const SizedBox(height: 22),
                  _VerifiedNumberChip(number: number),
                ],
                const Spacer(flex: 3),
                PrimaryButton(
                  label: 'Set up your profile',
                  enabled: true,
                  gradient: true,
                  trailingIcon: Icons.arrow_forward,
                  // Pushed, not replaced, so onboarding's first step has
                  // something to go back to — the design shows a back arrow
                  // there.
                  onPressed: () =>
                      GoRouter.of(context).pushAppRoute(AppRoutes.onboarding),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () =>
                      GoRouter.of(context).goAppRoute(AppRoutes.discovery),
                  child: const Text(
                    'Complete your profile later',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColor.authTextSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VerifiedNumberChip extends StatelessWidget {
  const _VerifiedNumberChip({required this.number});

  final String number;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColor.authSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColor.authFieldBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle,
            size: 17,
            color: AppColor.authSuccess,
          ),
          const SizedBox(width: 8),
          Text(
            number,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColor.authTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// The teal check inside its dashed orbit, with the design's scattered dots.
class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(220, 220),
            painter: _DashedRingPainter(),
          ),
          Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColor.authSuccessLight, AppColor.authSuccess],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColor.authSuccess.withValues(alpha: 0.32),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 62,
              color: AppColor.white,
            ),
          ),
          const Positioned(top: 26, right: 34, child: _Speck()),
          const Positioned(
            bottom: 40,
            left: 22,
            child: _Speck(color: AppColor.authAccent),
          ),
          const Positioned(top: 62, left: 14, child: _Speck()),
          const Positioned(
            bottom: 24,
            right: 52,
            child: _Speck(color: AppColor.authAccent),
          ),
        ],
      ),
    );
  }
}

class _Speck extends StatelessWidget {
  const _Speck({this.color = AppColor.authSuccessLight});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _DashedRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColor.authSuccessLight.withValues(alpha: 0.5)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final radius = size.width / 2 - 10;
    final center = Offset(size.width / 2, size.height / 2);
    const dashes = 44;
    const sweep = (2 * math.pi) / dashes;
    for (var i = 0; i < dashes; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * sweep,
        sweep * 0.45,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
