import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_assets.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';

/// A provider's initials on a dark navy square, with the verified check
/// tucked into its bottom-right corner.
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
  });

  final String initials;
  final double size;
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    final badgeSize = size * 0.3;

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
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColor.discoveryAvatarTop,
                  AppColor.discoveryAvatarBottom,
                ],
              ),
            ),
            child: Text(
              initials,
              style: TextStyle(
                fontFamily: DiscoveryText.family,
                fontSize: size * 0.34,
                fontWeight: FontWeight.w800,
                color: AppColor.discoveryAvatarText,
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
