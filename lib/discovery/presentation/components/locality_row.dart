import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:local_markerplace/components/art/art_palette.dart';
import 'package:local_markerplace/components/art/seeded_artwork.dart';
import 'package:local_markerplace/components/motion/entrance.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_assets.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/discovery/presentation/components/status_pill.dart';

/// A 60pt drill-down row: a monogram, the area's name, and on the right
/// either the number of providers waiting behind it or a COMING SOON pill.
///
/// The monogram is a plate of artwork generated from the area's own name, so
/// a screen of a dozen societies is a column of distinguishable marks instead
/// of a column of near-identical strings.
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
    this.index = 0,
  });

  final String title;

  /// Null when the row is a coming-soon area, which has a pill instead.
  final int? providerCount;

  final VoidCallback? onTap;

  final bool isComingSoon;

  /// Inset applied to both ends. The picker's card indents its rows inside
  /// the card's own padding; the zone detail screen's rows sit flush.
  final double horizontalPadding;

  /// Position in the list, which staggers the row's entrance.
  final int index;

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      index: index,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 60,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Row(
              children: [
                _Monogram(title: title, isComingSoon: isComingSoon),
                const SizedBox(width: 12),
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
      ),
    );
  }
}

/// The area's first letter on its own plate of artwork.
class _Monogram extends StatelessWidget {
  const _Monogram({required this.title, required this.isComingSoon});

  final String title;
  final bool isComingSoon;

  static const double _size = 34;

  @override
  Widget build(BuildContext context) {
    final trimmed = title.trim();
    final letter = trimmed.isEmpty ? '?' : trimmed[0].toUpperCase();

    return SizedBox(
      width: _size,
      height: _size,
      child: SeededArtwork(
        seed: title,
        // An area that is not open yet is drawn in the flow's greys, so the
        // row reads as waiting before its label is read.
        palette: isComingSoon ? ArtPalette.dormant : null,
        borderRadius: BorderRadius.circular(11),
        intensity: 0.85,
        child: Center(
          child: Text(
            letter,
            style: DiscoveryText.tileLabel.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isComingSoon
                  ? AppColor.discoveryTextDisabled
                  : AppColor.discoveryInk,
            ),
          ),
        ),
      ),
    );
  }
}
