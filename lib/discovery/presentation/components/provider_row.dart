import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:local_markerplace/discovery/model/provider_summary.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_assets.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/discovery/presentation/components/provider_avatar.dart';
import 'package:local_markerplace/discovery/presentation/components/rating_label.dart';

/// A provider in a list — the locality screen and the search results both use
/// this 78pt row. They differ only in the line under the rating, which the
/// caller supplies through [subtitle].
class ProviderRow extends StatelessWidget {
  const ProviderRow({
    super.key,
    required this.provider,
    required this.subtitle,
    this.showReviewCount = true,
    this.onTap,
  });

  final ProviderSummary provider;

  /// "RO Repair · Chimney" on a locality, "Ajnara Gen X · Open now" in
  /// search results.
  final String subtitle;

  /// Search results drop the bracketed review count; a locality keeps it.
  final bool showReviewCount;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 78,
        child: Row(
          children: [
            ProviderAvatar(
              initials: provider.initials,
              size: 44,
              isVerified: provider.isVerified,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: DiscoveryText.rowTitle,
                  ),
                  const SizedBox(height: 4),
                  RatingLabel(
                    rating: provider.rating,
                    reviewCount: showReviewCount ? provider.reviewCount : null,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: DiscoveryText.meta,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SvgPicture.asset(
              DiscoveryAssets.chevronRight,
              width: 6.9,
              height: 12.9,
            ),
          ],
        ),
      ),
    );
  }
}
