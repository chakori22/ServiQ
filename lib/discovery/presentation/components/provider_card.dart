import 'package:flutter/material.dart';

import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/model/provider_summary.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/discovery/presentation/components/provider_avatar.dart';
import 'package:local_markerplace/discovery/presentation/components/rating_label.dart';
import 'package:local_markerplace/discovery/presentation/components/status_pill.dart';

/// A provider in home's "Near you" rail — a 200pt card carrying the avatar,
/// an open/closed pill, the business name over two lines, its trades and the
/// rating.
class ProviderCard extends StatelessWidget {
  const ProviderCard({super.key, required this.provider, this.onTap});

  final ProviderSummary provider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 200,
        height: 152,
        // The design's insets are measured from the card's edge, so the
        // 1.4pt border comes out of them here.
        padding: const EdgeInsets.fromLTRB(13.2, 13.2, 13.2, 8),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProviderAvatar(
                  initials: provider.initials,
                  isVerified: provider.isVerified,
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: provider.isOpen
                      ? const StatusPill.open()
                      : const StatusPill.comingSoon(label: 'CLOSED'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Two lines at the design's 17pt leading, held open so a
            // one-line name does not pull the rest of the card up.
            SizedBox(
              height: 34,
              child: Text(
                provider.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: DiscoveryText.cardTitle,
              ),
            ),
            const SizedBox(height: 2),
            SizedBox(
              height: 14,
              child: Text(
                provider.trade,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: DiscoveryText.meta,
              ),
            ),
            const SizedBox(height: 2),
            SizedBox(height: 16, child: RatingLabel(rating: provider.rating)),
          ],
        ),
      ),
    );
  }
}
