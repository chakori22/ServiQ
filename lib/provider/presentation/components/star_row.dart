import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_assets.dart';

/// Five stars, the earned ones amber and the rest greyed.
///
/// Built from the exported star rather than a per-rating strip, so any score
/// renders — the design only drew the 4- and 5-star cases.
class StarRow extends StatelessWidget {
  const StarRow({super.key, required this.rating, this.size = 12, this.gap});

  final double rating;
  final double size;

  /// Space between stars. Defaults to the design's ratio — 2.5 at 12pt, 3.5
  /// at 14pt.
  final double? gap;

  @override
  Widget build(BuildContext context) {
    final spacing = gap ?? size * 0.25;
    final filled = rating.round().clamp(0, 5);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 5; i++) ...[
          if (i > 0) SizedBox(width: spacing),
          if (i < filled)
            SvgPicture.asset(DiscoveryAssets.star, width: size, height: size)
          else
            ColorFiltered(
              colorFilter: const ColorFilter.mode(
                AppColor.discoveryClearFill,
                BlendMode.srcIn,
              ),
              child: SvgPicture.asset(
                DiscoveryAssets.star,
                width: size,
                height: size,
              ),
            ),
        ],
      ],
    );
  }
}
