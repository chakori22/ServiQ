import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:local_markerplace/discovery/presentation/components/discovery_assets.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';

/// "Categories" or "Near you" on the left, an optional "See all" on the
/// right.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: DiscoveryText.sectionTitle),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('See all', style: DiscoveryText.link),
                const SizedBox(width: 6),
                SvgPicture.asset(
                  DiscoveryAssets.chevronLink,
                  width: 5,
                  height: 10,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// The count beside a "Societies" / "Markets" heading on zone detail.
class GroupHeader extends StatelessWidget {
  const GroupHeader({super.key, required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: DiscoveryText.groupHeading),
        Text('$count', style: DiscoveryText.groupCount),
      ],
    );
  }
}
