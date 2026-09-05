import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: Stack(
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
          Text(
            tab.label,
            style: isCurrent
                ? DiscoveryText.tabLabelActive
                : DiscoveryText.tabLabelInactive,
          ),
          const Spacer(),
          // The rule sits under the label, not the whole column.
          Container(
            width: 44,
            height: 3,
            decoration: BoxDecoration(
              color: isCurrent ? AppColor.discoveryAccent : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
