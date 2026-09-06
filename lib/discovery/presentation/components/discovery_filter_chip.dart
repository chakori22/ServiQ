import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:local_markerplace/components/motion/app_motion.dart';
import 'package:local_markerplace/components/motion/entrance.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_assets.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';

/// A pill above the search results. Selected chips fill with the accent;
/// chips that open a picker carry a caret instead.
class DiscoveryFilterChip extends StatelessWidget {
  const DiscoveryFilterChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.hasCaret = false,
    this.onTap,
  });

  final String label;
  final bool isSelected;

  /// Marks a chip that opens a picker — the locality and rating scopes.
  final bool hasCaret;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      pressedScale: 0.93,
      child: AnimatedContainer(
        duration: AppMotion.quick,
        curve: AppMotion.emphasized,
        padding: EdgeInsets.only(
          left: 14,
          right: hasCaret ? 11 : 14,
          top: 9,
          bottom: 9,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.discoveryAccent : AppColor.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected
                ? AppColor.discoveryAccent
                : AppColor.discoveryBorder,
            width: 1.4,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColor.discoveryAccent.withValues(alpha: 0.30),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedDefaultTextStyle(
              duration: AppMotion.quick,
              curve: AppMotion.emphasized,
              style: isSelected
                  ? DiscoveryText.chipSelected
                  : DiscoveryText.chip,
              child: Text(label),
            ),
            if (hasCaret) ...[
              const SizedBox(width: 6),
              SvgPicture.asset(
                DiscoveryAssets.caretDown,
                width: 9.7,
                height: 5.7,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
