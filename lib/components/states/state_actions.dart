import 'package:flutter/material.dart';

import 'package:local_markerplace/components/motion/entrance.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';

/// The gradient call to action every full-screen state ends on — 56pt, r16,
/// the same button whether it is retrying a load or posting a requirement.
///
/// Lives beside the states rather than inside one of them because the design
/// draws the identical pair on the error frames and the empty ones; two
/// copies would be two things to keep in step.
class StatePrimaryButton extends StatelessWidget {
  const StatePrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
  });

  final String label;
  final VoidCallback onTap;

  /// Sits before the label, as "Post what you need" carries a plus.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final glyph = icon;

    return PressableScale(
      onTap: onTap,
      pressedScale: 0.97,
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [
              AppColor.discoveryGradientStart,
              AppColor.discoveryGradientEnd,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColor.discoveryGradientEnd.withValues(alpha: 0.32),
              blurRadius: 11,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (glyph != null) ...[
              Icon(glyph, size: 18, color: AppColor.white),
              const SizedBox(width: 10),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: DiscoveryText.onAccent(16, letterSpacing: -0.16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The quieter way out under it — 52pt, outlined rather than filled, because
/// it is the alternative and not the answer.
class StateSecondaryButton extends StatelessWidget {
  const StateSecondaryButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      pressedScale: 0.97,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColor.discoveryAccent.withValues(alpha: 0.35),
            width: 1.6,
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: DiscoveryText.actionOutlined.copyWith(fontSize: 15),
        ),
      ),
    );
  }
}
