import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_assets.dart';

/// The stand-in map on the About tab.
///
/// No map SDK is wired up yet, so the design draws a stylised street grid with
/// the shop pinned on it. Swapping in a real map means replacing this widget
/// and nothing else.
class MapThumbnail extends StatelessWidget {
  const MapThumbnail({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 132,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: AppColor.providerMapFill,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColor.discoveryBorder, width: 1.4),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            return Stack(
              children: [
                for (final y in const [28.6, 64.6, 100.6])
                  Positioned(
                    left: 0,
                    right: 0,
                    top: y,
                    child: const ColoredBox(
                      color: AppColor.white,
                      child: SizedBox(height: 3, width: double.infinity),
                    ),
                  ),
                // Streets run at the design's fractions of the width so the
                // grid keeps its spacing on a narrower screen.
                for (final fraction in const [0.168, 0.425, 0.71])
                  Positioned(
                    left: width * fraction,
                    top: 0,
                    bottom: 0,
                    child: const ColoredBox(
                      color: AppColor.white,
                      child: SizedBox(width: 3),
                    ),
                  ),
                Positioned(
                  left: width * 0.425,
                  top: 28.6,
                  child: Container(
                    width: width * 0.285,
                    height: 36,
                    color: AppColor.providerMapBlock,
                  ),
                ),
                Positioned(
                  left: width * 0.465,
                  top: 42.6,
                  child: SvgPicture.asset(
                    DiscoveryAssets.mapPin,
                    width: 22,
                    height: 30,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
