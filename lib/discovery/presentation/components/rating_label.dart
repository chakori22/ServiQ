import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:local_markerplace/discovery/presentation/components/discovery_assets.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';

/// A star, the score, and — where the design shows it — the number of
/// reviews in brackets.
class RatingLabel extends StatelessWidget {
  const RatingLabel({super.key, required this.rating, this.reviewCount});

  final double rating;

  /// Omitted on the home cards, which only have room for the score.
  final int? reviewCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(DiscoveryAssets.star, width: 12, height: 12),
        const SizedBox(width: 4),
        Text(rating.toStringAsFixed(1), style: DiscoveryText.chip),
        if (reviewCount != null) ...[
          const SizedBox(width: 4),
          Text('($reviewCount)', style: DiscoveryText.metaMuted),
        ],
      ],
    );
  }
}
