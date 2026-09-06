import 'package:flutter/material.dart';

import 'package:local_markerplace/components/motion/app_motion.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';

/// The four sections of a provider's page.
enum ProviderTab {
  services('Services'),
  store('Store'),
  reviews('Reviews'),
  about('About');

  const ProviderTab(this.label);

  final String label;
}

/// The underlined tab strip under a provider's hero.
///
/// The rule slides from the old tab to the new one rather than blinking
/// between them, which is what makes the four sections read as one page the
/// seeker is moving along.
///
/// The design fixes each label's x so the four sit at 20 / 128 / 217 / 321 on
/// a 390pt screen; laying them out as equal columns keeps that rhythm and
/// survives a narrower phone, which fixed offsets would not.
class ProviderSegmentedTabs extends StatelessWidget {
  const ProviderSegmentedTabs({
    super.key,
    required this.current,
    required this.onSelect,
  });

  final ProviderTab current;
  final ValueChanged<ProviderTab> onSelect;

  /// The strip's inset, which the sliding rule has to start from too.
  static const double _inset = 20;

  /// The rule is narrower than its column: it underlines the label, not the
  /// whole quarter of the screen.
  static const double _ruleWidth = 44;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columnWidth =
              (constraints.maxWidth - _inset * 2) / ProviderTab.values.length;

          return Stack(
            children: [
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColor.discoveryBorder,
                ),
              ),
              AnimatedPositioned(
                duration: AppMotion.standard,
                curve: AppMotion.emphasized,
                left: _inset + columnWidth * current.index,
                bottom: 0,
                child: Container(
                  width: _ruleWidth,
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColor.discoveryAccent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: _inset),
                child: Row(
                  children: [
                    for (final tab in ProviderTab.values)
                      Expanded(
                        child: _Tab(
                          tab: tab,
                          isCurrent: tab == current,
                          onTap: () => onSelect(tab),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.tab, required this.isCurrent, required this.onTap});

  final ProviderTab tab;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 13),
          AnimatedDefaultTextStyle(
            duration: AppMotion.standard,
            curve: AppMotion.emphasized,
            style: isCurrent
                ? DiscoveryText.tabLabelActive
                : DiscoveryText.tabLabelInactive,
            child: Text(tab.label),
          ),
        ],
      ),
    );
  }
}
