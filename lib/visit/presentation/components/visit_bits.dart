import 'package:flutter/material.dart';

import 'package:local_markerplace/components/motion/app_motion.dart';
import 'package:local_markerplace/components/motion/entrance.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/discovery/presentation/components/provider_avatar.dart';
import 'package:local_markerplace/visit/model/visit.dart';

/// Who the visit is with. Every screen in the flow repeats it, because the
/// whole point of a visit is that it is one provider making one trip.
class ProviderStrip extends StatelessWidget {
  const ProviderStrip({super.key, required this.visit});

  final Visit visit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.providerNoteFill,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ProviderAvatar(
            initials: _initials(visit.providerName),
            seed: visit.providerName,
            size: 40,
            isVerified: visit.isVerifiedProvider,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visit.providerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DiscoveryText.rowTitle.copyWith(fontSize: 13.5),
                ),
                const SizedBox(height: 4),
                Text(
                  visit.providerLine,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DiscoveryText.smallPrint,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _initials(String name) {
  final words = name.trim().split(RegExp(r'\s+'));
  if (words.isEmpty || words.first.isEmpty) return '?';
  if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
  return (words[0][0] + words[1][0]).toUpperCase();
}

/// One line of a bill: a label on the left, an amount on the right.
class TotalRow extends StatelessWidget {
  const TotalRow({
    super.key,
    required this.label,
    required this.value,
    this.isTotal = false,
    this.footnote,
  });

  final String label;
  final String value;

  /// The closing line, which carries the weight.
  final bool isTotal;

  /// Small print under the row, e.g. "waived once you confirm".
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: isTotal
                      ? DiscoveryText.offerName
                      : DiscoveryText.caption,
                ),
              ),
              Text(
                value,
                style: isTotal ? DiscoveryText.visitTotal : DiscoveryText.chip,
              ),
            ],
          ),
          if (footnote != null) ...[
            const SizedBox(height: 4),
            Text(footnote!, style: DiscoveryText.fine),
          ],
        ],
      ),
    );
  }
}

/// The flow's primary action, which is the same shape on every screen.
class VisitCta extends StatelessWidget {
  const VisitCta({
    super.key,
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.leading,
  });

  final String label;
  final VoidCallback onTap;
  final bool enabled;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: enabled ? onTap : null,
      pressedScale: 0.97,
      child: AnimatedContainer(
        duration: AppMotion.quick,
        curve: AppMotion.emphasized,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: enabled ? null : AppColor.buttonDisabledFill,
          gradient: enabled
              ? const LinearGradient(
                  colors: [
                    AppColor.discoveryGradientStart,
                    AppColor.discoveryGradientEnd,
                  ],
                )
              : null,
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColor.discoveryGradientEnd.withValues(
                      alpha: 0.32,
                    ),
                    blurRadius: 11,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 10)],
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: enabled
                  ? DiscoveryText.onAccent(16.5, letterSpacing: -0.165)
                  : DiscoveryText.buttonDisabled,
            ),
          ],
        ),
      ),
    );
  }
}

/// The hairline the flow separates its blocks with.
class VisitRule extends StatelessWidget {
  const VisitRule({super.key, this.top = 16, this.bottom = 16});

  final double top;
  final double bottom;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: top, bottom: bottom),
    child: const Divider(
      height: 1,
      thickness: 1,
      color: AppColor.discoveryBorder,
    ),
  );
}
