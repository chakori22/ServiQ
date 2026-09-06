import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:local_markerplace/components/art/art_palette.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_assets.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';

/// A provider's initials on a dark square, with the verified check tucked
/// into its bottom-right corner.
///
/// The square is navy tinted towards the provider's own artwork colour, so a
/// list of them is not a column of identical dark tiles — the tint is pulled
/// in far enough to be seen and no further, because the initials on top are
/// light and have to stay legible.
///
/// Every measurement in the design scales with the square, so the widget
/// derives the radius, the type size and the badge from [size] rather than
/// taking three more arguments.
class ProviderAvatar extends StatelessWidget {
  const ProviderAvatar({
    super.key,
    required this.initials,
    this.size = 48,
    this.isVerified = true,
    this.seed,
    this.hasRing = false,
  });

  final String initials;
  final double size;
  final bool isVerified;

  /// What the tint is derived from — the provider's name, so it matches the
  /// artwork on their card. Null leaves the avatar the flow's plain navy.
  final String? seed;

  /// Draws a white ring around the square, for an avatar that overlaps
  /// artwork and would otherwise sit on it without separation.
  final bool hasRing;

  @override
  Widget build(BuildContext context) {
    final badgeSize = size * 0.3;
    final seed = this.seed;

    // How far the tint is allowed to pull the navy: enough to tell two
    // providers apart, not enough to lift the square towards the initials.
    final (top, bottom) = seed == null
        ? (AppColor.discoveryAvatarTop, AppColor.discoveryAvatarBottom)
        : (
            Color.lerp(
              AppColor.discoveryAvatarTop,
              ArtPalette.forSeed(seed).deep,
              0.38,
            )!,
            Color.lerp(
              AppColor.discoveryAvatarBottom,
              ArtPalette.forSeed(seed).deep,
              0.14,
            )!,
          );

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size * 0.3),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [top, bottom],
              ),
              border: hasRing
                  ? Border.all(color: AppColor.white, width: size * 0.055)
                  : null,
              boxShadow: hasRing
                  ? [
                      BoxShadow(
                        color: AppColor.discoveryShadow.withValues(alpha: 0.18),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              initials,
              style: TextStyle(
                fontFamily: DiscoveryText.family,
                fontSize: size * 0.34,
                fontWeight: FontWeight.w800,
                color: AppColor.white,
                letterSpacing: size * 0.0034,
              ),
            ),
          ),
          if (isVerified)
            Positioned(
              // The badge straddles the corner, half on and half off, which
              // is what puts its white ring against the page behind it.
              right: -badgeSize / 4,
              bottom: -badgeSize / 4,
              child: SvgPicture.asset(
                DiscoveryAssets.verified,
                width: badgeSize,
                height: badgeSize,
              ),
            ),
        ],
      ),
    );
  }
}
