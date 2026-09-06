import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_assets.dart';

/// The stand-in map on the About tab.
///
/// No map SDK is wired up yet. The design falls back to a grid of straight
/// white lines, which reads as a spreadsheet rather than a place; this paints
/// the same idea as béziers instead — roads that bend, a river running under
/// them and a patch of green — so the About tab has something map-shaped on
/// it while the real thing is still to come.
///
/// Swapping in a real map means replacing this widget and nothing else.
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
        child: Stack(
          children: [
            const Positioned.fill(child: CustomPaint(painter: _MapPainter())),
            // The shop, on the corner the roads meet at.
            Positioned(
              left: 0,
              right: 0,
              top: 40,
              child: Center(
                child: SvgPicture.asset(
                  DiscoveryAssets.mapPin,
                  width: 24,
                  height: 33,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  const _MapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // The green, tucked into the bottom-left corner.
    canvas.drawPath(
      Path()
        ..moveTo(0, h * 0.58)
        ..cubicTo(w * 0.10, h * 0.48, w * 0.26, h * 0.54, w * 0.32, h * 0.72)
        ..cubicTo(w * 0.36, h * 0.86, w * 0.20, h + 2, w * 0.04, h + 2)
        ..lineTo(0, h + 2)
        ..close(),
      Paint()..color = AppColor.artGreenMid.withValues(alpha: 0.55),
    );

    // The water, crossing the whole thumbnail on a long diagonal.
    canvas.drawPath(
      Path()
        ..moveTo(-4, h * 0.24)
        ..cubicTo(w * 0.30, h * 0.34, w * 0.52, h * 0.06, w + 4, h * 0.20),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round
        ..color = AppColor.artBlueMid.withValues(alpha: 0.85),
    );

    // Two blocks of buildings, sitting in the angle the roads make.
    final block = Paint()..color = AppColor.providerMapBlock;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.44, h * 0.30, w * 0.26, h * 0.24),
        const Radius.circular(5),
      ),
      block,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.74, h * 0.58, w * 0.22, h * 0.28),
        const Radius.circular(5),
      ),
      block,
    );

    // The roads. Drawn twice — a wide pale casing under a narrower white
    // surface — which is what makes them read as roads rather than as
    // scribbles over the ground.
    final roads = [
      Path()
        ..moveTo(-4, h * 0.62)
        ..cubicTo(w * 0.26, h * 0.52, w * 0.58, h * 0.74, w + 4, h * 0.56),
      Path()
        ..moveTo(w * 0.36, -4)
        ..cubicTo(w * 0.42, h * 0.34, w * 0.30, h * 0.66, w * 0.44, h + 4),
      Path()
        ..moveTo(w * 0.82, -4)
        ..cubicTo(w * 0.78, h * 0.30, w * 0.92, h * 0.62, w * 0.86, h + 4),
    ];

    final casing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..color = AppColor.discoveryBorder;
    final surface = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..color = AppColor.white;

    for (final road in roads) {
      canvas.drawPath(road, casing);
    }
    for (final road in roads) {
      canvas.drawPath(road, surface);
    }
  }

  @override
  bool shouldRepaint(_MapPainter oldDelegate) => false;
}
