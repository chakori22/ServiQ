import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_assets.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';

/// The illustration at the top of the area picker: a pin inside two rings,
/// over a pale wash with two blue glows drifting behind it.
class LocationHero extends StatelessWidget {
  const LocationHero({super.key});

  /// Where the sheet's top edge crosses the hero. [LocationPage] offsets the
  /// sheet by the same amount.
  static const double sheetTop = 312;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 366,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColor.discoveryHeroTop,
                    AppColor.discoveryHeroMid,
                    AppColor.white,
                  ],
                  stops: [0, 0.65, 1],
                ),
              ),
            ),
          ),
          // Figma paints these as blurred circles. A Gaussian blur is not a
          // primitive here, so the same falloff is drawn as a radial fade —
          // visually equivalent and far cheaper than a real blur pass.
          const _At(top: -30, x: -0.154, size: 250, child: _Glow(size: 250)),
          const _At(top: 90, x: 0.692, size: 200, child: _Glow(size: 200)),
          _At(
            top: 78,
            size: 180,
            child: Image.asset(
              DiscoveryAssets.heroRingOuter,
              width: 180,
              height: 180,
            ),
          ),
          _At(
            top: 108,
            size: 120,
            child: SvgPicture.asset(
              DiscoveryAssets.heroRingInner,
              width: 120,
              height: 120,
            ),
          ),
          _At(
            top: 72,
            size: 12,
            child: SvgPicture.asset(
              DiscoveryAssets.heroDotCyan,
              width: 12,
              height: 12,
            ),
          ),
          _At(
            top: 226,
            x: 0.372,
            size: 11,
            child: SvgPicture.asset(
              DiscoveryAssets.heroDotBlue,
              width: 11,
              height: 11,
            ),
          ),
          const _At(top: 131, size: 74, child: _HeroPin()),
          // Anchored to the sheet rather than to a fixed offset from the top.
          // The sheet sits at a fixed 312pt, so the headline has to grow up
          // into the illustration when it wraps on a narrow screen or at a
          // large text size, instead of down behind the sheet. 62 puts its
          // baseline where the design has it on a 390pt screen.
          Positioned(
            left: 0,
            right: 0,
            bottom: 62,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Where do you need help?',
                textAlign: TextAlign.center,
                style: DiscoveryText.hero,
              ),
            ),
          ),
          // The design tucks the subtitle under the sheet, so it starts on
          // the sheet's own line — that way it is wholly hidden at every text
          // size rather than peeking out by however much it has grown.
          Positioned(
            left: 0,
            right: 0,
            top: sheetTop,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "We'll show providers near you",
                textAlign: TextAlign.center,
                style: DiscoveryText.heroSubtitle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Places a piece of the hero at a fixed distance from the top and a
/// fraction of the way across, so the illustration keeps its composition on
/// a 320pt screen and a 430pt one alike. Figma's absolute offsets are all
/// measured against a 390pt canvas and would drift off-centre anywhere else.
class _At extends StatelessWidget {
  const _At({
    required this.top,
    required this.size,
    required this.child,
    this.x = 0,
  });

  final double top;

  /// Horizontal placement as an [Alignment] x: 0 is centred, -1 the left
  /// edge, 1 the right.
  final double x;

  /// The child's own size, which the alignment box has to match for the
  /// fraction to land where the design puts it.
  final double size;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: 0,
      right: 0,
      height: size,
      child: Align(alignment: Alignment(x, 0), child: child),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColor.discoveryAccent.withValues(alpha: 0.10),
              AppColor.discoveryAccent.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroPin extends StatelessWidget {
  const _HeroPin();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 74,
      height: 74,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.discoveryGradientStart,
            AppColor.discoveryGradientEnd,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.discoveryGradientStart.withValues(alpha: 0.36),
            blurRadius: 28,
            spreadRadius: -4,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: SvgPicture.asset(DiscoveryAssets.pin, width: 26, height: 36),
    );
  }
}
