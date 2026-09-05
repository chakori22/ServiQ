import 'package:flutter/material.dart';

import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/provider/presentation/components/star_row.dart';

/// The card at the top of the Reviews tab: the score on the left, and how the
/// stars are distributed on the right.
class RatingSummaryCard extends StatelessWidget {
  const RatingSummaryCard({
    super.key,
    required this.rating,
    required this.reviewCount,
    required this.breakdown,
  });

  final double rating;
  final int reviewCount;

  /// Share of reviews at 5, 4, 3, 2 and 1 stars.
  final List<double> breakdown;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(19.2),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColor.discoveryBorder, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: AppColor.discoveryShadow.withValues(alpha: 0.05),
            blurRadius: 7,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rating.toStringAsFixed(1),
                style: DiscoveryText.ratingHeadline,
              ),
              const SizedBox(height: 6),
              StarRow(rating: rating, size: 14, gap: 3.5),
              const SizedBox(height: 6),
              Text('$reviewCount reviews', style: DiscoveryText.meta),
            ],
          ),
          const SizedBox(width: 26),
          Expanded(
            child: Column(
              children: [
                for (var i = 0; i < breakdown.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  _BreakdownBar(star: 5 - i, share: breakdown[i]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownBar extends StatelessWidget {
  const _BreakdownBar({required this.star, required this.share});

  final int star;
  final double share;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 12,
          child: Text('$star', style: DiscoveryText.breakdownStar),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              height: 6,
              child: Stack(
                children: [
                  const ColoredBox(
                    color: AppColor.discoveryClearFill,
                    child: SizedBox.expand(),
                  ),
                  FractionallySizedBox(
                    // A share of zero still shows a stub, matching the
                    // design's 2% rows, which are drawn as a dot rather than
                    // nothing at all.
                    widthFactor: share.clamp(0.017, 1.0),
                    child: const ColoredBox(
                      color: AppColor.discoveryStar,
                      child: SizedBox.expand(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 30,
          child: Text(
            '${(share * 100).round()}%',
            textAlign: TextAlign.right,
            style: DiscoveryText.breakdownPercent,
          ),
        ),
      ],
    );
  }
}
