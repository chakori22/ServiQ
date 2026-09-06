import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:local_markerplace/components/art/seeded_artwork.dart';
import 'package:local_markerplace/components/motion/entrance.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/model/provider_summary.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/discovery/presentation/components/provider_avatar.dart';
import 'package:local_markerplace/discovery/presentation/components/rating_label.dart';
import 'package:local_markerplace/discovery/presentation/components/status_pill.dart';
import 'package:local_markerplace/discovery/presentation/components/trade_glyph.dart';

/// A provider in home's "Near you" rail.
///
/// The card leads with a cover: a plate of artwork generated from the
/// provider's own name, watermarked with the glyph for their trade, with the
/// avatar straddling its lower edge. Everything the card used to say in words
/// — who they are, what they do — it now also says in colour and shape, so
/// the rail scans as pictures rather than as a wall of names.
class ProviderCard extends StatelessWidget {
  const ProviderCard({
    super.key,
    required this.provider,
    this.onTap,
    this.index = 0,
  });

  final ProviderSummary provider;
  final VoidCallback? onTap;

  /// Position in the rail, which staggers the card's entrance.
  final int index;

  /// Height of the artwork band at the top of the card.
  static const double _coverHeight = 78;

  /// How far the avatar hangs below the cover.
  static const double _avatarOverhang = 20;

  static const double _avatarSize = 46;

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      index: index,
      offset: const Offset(0.10, 0),
      child: PressableScale(
        onTap: onTap,
        child: Container(
          width: 208,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColor.discoveryBorder, width: 1.4),
            boxShadow: [
              BoxShadow(
                color: AppColor.discoveryShadow.withValues(alpha: 0.07),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Cover(provider: provider),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(13.2, 0, 13.2, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Clears the part of the avatar hanging into this half
                      // of the card.
                      const SizedBox(height: _avatarOverhang + 6),
                      Flexible(
                        child: Text(
                          provider.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: DiscoveryText.cardTitle,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        provider.trade,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: DiscoveryText.meta,
                      ),
                      const Spacer(),
                      RatingLabel(rating: provider.rating),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The artwork band, its trade watermark, the open pill and the avatar.
class _Cover extends StatelessWidget {
  const _Cover({required this.provider});

  final ProviderSummary provider;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ProviderCard._coverHeight + ProviderCard._avatarOverhang,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: ProviderCard._coverHeight,
            child: SeededArtwork(
              seed: provider.name,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // The trade, drawn large and pale at the far corner. It
                  // runs off the edge on purpose — a glyph sitting neatly in
                  // the middle would read as an icon rather than as art.
                  Positioned(
                    right: -10,
                    bottom: -12,
                    child: Opacity(
                      opacity: 0.72,
                      child: SvgPicture.asset(
                        TradeGlyph.forTrade(provider.trade),
                        width: 62,
                        height: 62,
                        colorFilter: const ColorFilter.mode(
                          AppColor.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: provider.isOpen
                        ? const StatusPill.open()
                        : const StatusPill.comingSoon(label: 'CLOSED'),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 13.2,
            top:
                ProviderCard._coverHeight -
                ProviderCard._avatarSize +
                ProviderCard._avatarOverhang,
            child: ProviderAvatar(
              initials: provider.initials,
              seed: provider.name,
              size: ProviderCard._avatarSize,
              isVerified: provider.isVerified,
              hasRing: true,
            ),
          ),
        ],
      ),
    );
  }
}
