import 'package:flutter/material.dart';

import '../../../components/app_back_button.dart';
import '../../../core/app_color.dart';

/// The ground onboarding sits on.
///
/// The collecting steps are plain white — onboarding deliberately does not
/// carry the login flow's blue wash, so the outlined tiles and fields are the
/// only colour on the page. Only the closing step tints, and it tints mint
/// from the top down to white rather than into the auth flow's blue.
class OnboardingBackground extends StatelessWidget {
  const OnboardingBackground({
    super.key,
    required this.child,
    this.success = false,
  });

  /// Switches to the mint wash the "You're all set" screen uses.
  final bool success;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        color: success ? null : AppColor.white,
        gradient: success
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColor.onboardingSuccessWashTop,
                  AppColor.white,
                  AppColor.white,
                ],
                stops: [0, 0.55, 1],
              )
            : null,
      ),
      child: child,
    );
  }
}

/// Back arrow and "Skip" above the progress segments and the step counter.
///
/// [onBack] and [onSkip] are null where the design shows no such affordance —
/// the closing screen has neither — which hides them rather than showing a
/// dead control.
class OnboardingHeader extends StatelessWidget {
  const OnboardingHeader({
    super.key,
    required this.counter,
    required this.stepIndex,
    required this.stepCount,
    required this.onBack,
    required this.onSkip,
  });

  final String counter;
  final int stepIndex;
  final int stepCount;
  final VoidCallback? onBack;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final showControls = onBack != null || onSkip != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showControls)
          SizedBox(
            height: 44,
            child: Row(
              children: [
                if (onBack != null)
                  AppBackButton(onTap: onBack, color: AppColor.authTextPrimary),
                const Spacer(),
                if (onSkip != null)
                  TextButton(
                    onPressed: onSkip,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColor.authTextSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 18),
        _ProgressSegments(current: stepIndex, total: stepCount),
        const SizedBox(height: 14),
        Text(
          counter,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: AppColor.authTextSecondary,
          ),
        ),
      ],
    );
  }
}

/// One short bar per step, filled up to and including the current one.
class _ProgressSegments extends StatelessWidget {
  const _ProgressSegments({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < total; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              height: 4,
              decoration: BoxDecoration(
                color: i <= current
                    ? AppColor.authAccent
                    : AppColor.authFieldBorder,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// The heading, and the supporting line under it where a step has one.
class OnboardingStepTitle extends StatelessWidget {
  const OnboardingStepTitle({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
            height: 1.2,
            color: AppColor.authTextPrimary,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.45,
              color: AppColor.authTextSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

/// The quiet text link under each step's button.
class OnboardingFootnoteLink extends StatelessWidget {
  const OnboardingFootnoteLink({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 13, color: AppColor.authTextSecondary),
    );
    if (onTap == null) return Center(child: text);
    return Center(
      child: TextButton(onPressed: onTap, child: text),
    );
  }
}
