import 'package:flutter/material.dart';

import 'package:local_markerplace/components/motion/app_motion.dart';
import 'package:local_markerplace/components/motion/entrance.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/visit/model/visit_mode.dart';

/// Instant or scheduled, as the design's pair of cards.
///
/// The choice is deliberately not defaulted: a visit that quietly assumed
/// "instant" would charge ₹99 nobody asked for, so the screen waits.
class ModeCard extends StatelessWidget {
  const ModeCard({
    super.key,
    required this.mode,
    required this.isSelected,
    required this.onTap,
  });

  final VisitMode mode;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      pressedScale: 0.97,
      child: AnimatedContainer(
        duration: AppMotion.quick,
        curve: AppMotion.emphasized,
        height: 116,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? AppColor.discoveryAccent
                : AppColor.discoveryBorder,
            width: isSelected ? 2 : 1.4,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColor.discoveryAccent.withValues(alpha: 0.16),
                    blurRadius: 9,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The radio sits over the corner rather than in the row, so the
            // label has the card's full width — "Scheduled" does not fit
            // beside it otherwise.
            Stack(
              clipBehavior: Clip.none,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColor.visitEtaTint
                            : AppColor.discoveryTint,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        mode == VisitMode.instant
                            ? Icons.bolt_rounded
                            : Icons.schedule_rounded,
                        size: 20,
                        color: isSelected
                            ? AppColor.discoveryAccent
                            : AppColor.discoveryTextTertiary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            // Clears the radio parked in the corner.
                            padding: const EdgeInsets.only(right: 18),
                            child: Text(
                              mode.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: DiscoveryText.groupHeading,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            mode.feeLabel,
                            style: DiscoveryText.offerName.copyWith(
                              fontSize: 12,
                              letterSpacing: -0.12,
                              color: isSelected
                                  ? AppColor.discoveryGradientEnd
                                  : AppColor.discoveryTextTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: _Radio(isSelected: isSelected),
                ),
              ],
            ),
            const Spacer(),
            Text(
              mode.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: DiscoveryText.meta.copyWith(height: 16 / 11.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected
              ? AppColor.discoveryAccent
              : AppColor.uploadDashedBorder,
          width: 2,
        ),
      ),
      child: AnimatedScale(
        scale: isSelected ? 1 : 0,
        duration: AppMotion.quick,
        curve: AppMotion.overshoot,
        child: Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: AppColor.discoveryAccent,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
