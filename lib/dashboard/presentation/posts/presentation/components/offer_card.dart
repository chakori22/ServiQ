import 'package:flutter/material.dart';

import 'package:local_markerplace/components/motion/entrance.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/dashboard/model/post_offer.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/discovery/presentation/components/provider_avatar.dart';
import 'package:local_markerplace/discovery/presentation/components/status_pill.dart';

/// One offer on a requirement: who is offering, what vouches for them, what
/// they want for it and when they can come.
///
/// What the seeker is really choosing between is trust and price, so those
/// are the two things given weight — the badge under the name, the amount in
/// the accent, everything else quiet.
class OfferCard extends StatelessWidget {
  const OfferCard({
    super.key,
    required this.offer,
    this.onAccept,
    this.index = 0,
  });

  final PostOffer offer;
  final VoidCallback? onAccept;

  /// Position in the list, which staggers the card's entrance.
  final int index;

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      index: index,
      child: Container(
        padding: const EdgeInsets.all(14.6),
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
                  initials: offer.initials,
                  seed: offer.name,
                  size: 40,
                  isVerified: offer.badge == OfferBadge.verified,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: DiscoveryText.offerName,
                      ),
                      const SizedBox(height: 5),
                      _OfferBadge(badge: offer.badge),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(offer.price, style: DiscoveryText.offerPrice),
                    const SizedBox(height: 4),
                    Text(offer.timing, style: DiscoveryText.meta),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    offer.note,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: DiscoveryText.offerNote,
                  ),
                ),
                // Only the seeker who posted the requirement can take an
                // offer, so for everybody else the button is absent rather
                // than present and dead.
                if (onAccept != null) ...[
                  const SizedBox(width: 12),
                  _AcceptButton(onTap: onAccept!),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// VERIFIED / PROVIDER as pills; a neighbour is not a business, so they get
/// a plain word rather than a badge that would overstate them.
class _OfferBadge extends StatelessWidget {
  const _OfferBadge({required this.badge});

  final OfferBadge badge;

  @override
  Widget build(BuildContext context) {
    return switch (badge) {
      OfferBadge.verified => const StatusPill.accepted(label: 'VERIFIED'),
      OfferBadge.provider => const StatusPill.comingSoon(label: 'PROVIDER'),
      OfferBadge.neighbour => Text('Neighbour', style: DiscoveryText.metaMuted),
    };
  }
}

class _AcceptButton extends StatelessWidget {
  const _AcceptButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      pressedScale: 0.92,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: const LinearGradient(
            colors: [
              AppColor.discoveryGradientStart,
              AppColor.discoveryGradientEnd,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColor.discoveryGradientEnd.withValues(alpha: 0.28),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Text('Accept', style: DiscoveryText.chipSelected),
      ),
    );
  }
}
