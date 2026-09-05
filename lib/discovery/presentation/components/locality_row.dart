import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:local_markerplace/discovery/presentation/components/discovery_assets.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/discovery/presentation/components/status_pill.dart';

/// A 56pt drill-down row: a name on the left, and on the right either the
/// number of providers waiting behind it or a COMING SOON pill.
///
/// Used by the area picker's grouped card and by the zone detail lists, which
/// differ only in how much they indent the text.
class LocalityRow extends StatelessWidget {
  const LocalityRow({
    super.key,
    required this.title,
    this.providerCount,
    this.onTap,
    this.isComingSoon = false,
    this.horizontalPadding = 0,
  });

  final String title;

  /// Null when the row is a coming-soon area, which has a pill instead.
  final int? providerCount;

  final VoidCallback? onTap;

  final bool isComingSoon;

  /// Inset applied to both ends. The picker's card indents its rows inside
  /// the card's own padding; the zone detail screen's rows sit flush.
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 56,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: isComingSoon
                      ? DiscoveryText.rowTitleDisabled
                      : DiscoveryText.rowTitle,
                ),
              ),
              if (isComingSoon)
                const StatusPill.comingSoon()
              else ...[
                if (providerCount != null)
                  Text('$providerCount', style: DiscoveryText.rowCount),
                const SizedBox(width: 8),
                SvgPicture.asset(
                  DiscoveryAssets.chevronRight,
                  width: 6.9,
                  height: 12.9,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
