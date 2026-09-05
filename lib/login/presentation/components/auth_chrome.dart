import 'package:flutter/material.dart';

import '../../../components/app_back_button.dart';
import '../../../core/app_color.dart';

/// The pale blue wash every auth screen sits on, with a soft glow behind
/// whatever is placed at the top.
class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColor.authBackgroundTop,
            AppColor.authBackgroundTop,
            AppColor.authBackgroundBottom,
          ],
          stops: [0, 0.45, 1],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            left: -60,
            right: -60,
            child: IgnorePointer(
              child: Container(
                height: 420,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColor.authGlow.withValues(alpha: 0.75),
                      AppColor.authGlow.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// The app mark: the emblem from the brand lockup on its dark rounded tile.
///
/// The asset is the full lockup (emblem over wordmark and tagline), so it is
/// scaled up and anchored near the top to show the emblem alone — the wordmark
/// underneath is drawn as live text instead.
class ServiqLogoMark extends StatelessWidget {
  const ServiqLogoMark({super.key, this.size = 104});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.26),
        boxShadow: [
          BoxShadow(
            color: AppColor.indicativeBlueColor900.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.26),
      ),
      child: Transform.scale(
        scale: 1.62,
        alignment: const Alignment(0, -0.84),
        child: Image.asset(
          'assets/images/serviq_logo.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

/// "ServiQ" with the trailing Q in brand blue.
class ServiqWordmark extends StatelessWidget {
  const ServiqWordmark({super.key, this.fontSize = 34});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: AppColor.authTextPrimary,
        ),
        children: const [
          TextSpan(text: 'Servi'),
          TextSpan(
            text: 'Q',
            style: TextStyle(color: AppColor.authAccent),
          ),
        ],
      ),
    );
  }
}

/// LOCAL SERVICES. **REAL HELP.** RIGHT NEAR YOU.
class ServiqTagline extends StatelessWidget {
  const ServiqTagline({super.key});

  @override
  Widget build(BuildContext context) {
    const base = TextStyle(
      fontSize: 11,
      letterSpacing: 0.9,
      fontWeight: FontWeight.w600,
      color: AppColor.authTextSecondary,
    );
    return const Text.rich(
      TextSpan(
        style: base,
        children: [
          TextSpan(text: 'LOCAL SERVICES.  '),
          TextSpan(
            text: 'REAL HELP.',
            style: TextStyle(
              color: AppColor.authAccent,
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(text: '  RIGHT NEAR YOU.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

/// The white sheet the forms sit in.
class AuthSheet extends StatelessWidget {
  const AuthSheet({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.fromLTRB(24, 28, 24, 20),
      decoration: BoxDecoration(
        color: AppColor.authSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: AppColor.indicativeBlueColor900.withValues(alpha: 0.07),
            blurRadius: 28,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// The circular back affordance used at the top-left of the OTP screen.
class AuthBackButton extends StatelessWidget {
  const AuthBackButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppBackButton(onTap: onTap, color: AppColor.authTextPrimary);
  }
}

/// The legal line shown under the login form.
class AuthLegalFootnote extends StatelessWidget {
  const AuthLegalFootnote({
    super.key,
    required this.onTerms,
    required this.onPrivacy,
  });

  final VoidCallback onTerms;
  final VoidCallback onPrivacy;

  @override
  Widget build(BuildContext context) {
    const link = TextStyle(
      fontWeight: FontWeight.w700,
      decoration: TextDecoration.underline,
      color: AppColor.authLink,
    );
    return DefaultTextStyle(
      style: const TextStyle(
        fontSize: 12,
        color: AppColor.authTextSecondary,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          const Text('By continuing you agree to our '),
          GestureDetector(
            onTap: onTerms,
            child: const Text('Terms & Conditions', style: link),
          ),
          const Text(' and '),
          GestureDetector(
            onTap: onPrivacy,
            child: const Text('Privacy Policy', style: link),
          ),
        ],
      ),
    );
  }
}
