import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:local_markerplace/components/art/art_palette.dart';
import 'package:local_markerplace/core/app_color.dart';

/// A plate of artwork generated from a piece of text.
///
/// Nothing in ServiQ has photography behind it yet — a provider has a name
/// and a trade, a product has a price — so lists of them used to be lists of
/// words. This paints each one a picture instead: a two-stop gradient with
/// organic bézier blobs, a sweeping ribbon and a thin ring drawn over it, all
/// derived from [seed].
///
/// Because the composition comes from the text, a provider's card, row and
/// profile all show the same artwork, and it survives a restart without
/// anything being stored. Swapping in real photography later means replacing
/// this widget where it is used, and nothing else.
class SeededArtwork extends StatelessWidget {
  const SeededArtwork({
    super.key,
    required this.seed,
    this.child,
    this.borderRadius,
    this.palette,
    this.intensity = 1,
  });

  /// The text the composition and its colours are derived from.
  final String seed;

  /// Drawn on top of the plate — a trade glyph, an avatar, a label.
  final Widget? child;

  final BorderRadius? borderRadius;

  /// Overrides the family [seed] would otherwise pick, for the rare case
  /// where the colour has to mean something instead of just varying.
  final ArtPalette? palette;

  /// Scales how strongly the curves read against the plate. Small surfaces
  /// such as a category tile want less than a full-width cover.
  final double intensity;

  @override
  Widget build(BuildContext context) {
    final family = palette ?? ArtPalette.forSeed(seed);

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CustomPaint(
        painter: _SeededArtworkPainter(
          seed: seed,
          palette: family,
          intensity: intensity,
        ),
        child: child,
      ),
    );
  }
}

class _SeededArtworkPainter extends CustomPainter {
  _SeededArtworkPainter({
    required this.seed,
    required this.palette,
    required this.intensity,
  });

  final String seed;
  final ArtPalette palette;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final random = ArtRandom(seed);

    // The plate. Tilted rather than vertical so it does not line up with the
    // card edges it sits inside.
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.light, palette.mid],
        ).createShader(bounds),
    );

    // Two blobs, one anchored high and one low, so the composition has a
    // diagonal to it whatever the seed says.
    _paintBlob(
      canvas,
      size,
      random,
      center: Offset(
        size.width * random.range(0.12, 0.38),
        size.height * random.range(0.10, 0.34),
      ),
      radius: size.shortestSide * random.range(0.38, 0.56),
      color: palette.deep.withValues(alpha: 0.13 * intensity),
    );
    _paintBlob(
      canvas,
      size,
      random,
      center: Offset(
        size.width * random.range(0.66, 0.94),
        size.height * random.range(0.62, 0.92),
      ),
      radius: size.shortestSide * random.range(0.30, 0.48),
      color: AppColor.white.withValues(alpha: 0.42 * intensity),
    );

    // The ribbon: one cubic sweeping across the plate, filled down to the
    // bottom edge. This is what gives every plate its horizon line.
    final crest = size.height * random.range(0.52, 0.74);
    final ribbon = Path()
      ..moveTo(0, crest)
      ..cubicTo(
        size.width * 0.30,
        crest - size.height * random.range(0.14, 0.26),
        size.width * 0.64,
        crest + size.height * random.range(0.12, 0.24),
        size.width,
        crest - size.height * random.range(0.02, 0.14),
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      ribbon,
      Paint()..color = AppColor.white.withValues(alpha: 0.34 * intensity),
    );

    // A ring running off the edge, which is what stops the plate reading as
    // a flat swatch at a glance.
    canvas.drawCircle(
      Offset(
        size.width * random.range(0.62, 1.02),
        size.height * random.range(-0.10, 0.28),
      ),
      size.shortestSide * random.range(0.42, 0.68),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = palette.deep.withValues(alpha: 0.16 * intensity),
    );
  }

  /// A closed path of four cubics around [center].
  ///
  /// Each of the four anchors is pushed out by its own amount, so the result
  /// is an organic shape rather than a circle — the same trick a designer
  /// uses when drawing a blob by hand.
  void _paintBlob(
    Canvas canvas,
    Size size,
    ArtRandom random, {
    required Offset center,
    required double radius,
    required Color color,
  }) {
    // The handle length that turns four cubics into a circle. Scaling the
    // anchors while leaving this alone is what bends it out of shape.
    const kappa = 0.5523;

    final up = radius * random.range(0.78, 1.22);
    final right = radius * random.range(0.78, 1.22);
    final down = radius * random.range(0.78, 1.22);
    final left = radius * random.range(0.78, 1.22);

    final path = Path()
      ..moveTo(center.dx, center.dy - up)
      ..cubicTo(
        center.dx + right * kappa,
        center.dy - up,
        center.dx + right,
        center.dy - up * kappa,
        center.dx + right,
        center.dy,
      )
      ..cubicTo(
        center.dx + right,
        center.dy + down * kappa,
        center.dx + right * kappa,
        center.dy + down,
        center.dx,
        center.dy + down,
      )
      ..cubicTo(
        center.dx - left * kappa,
        center.dy + down,
        center.dx - left,
        center.dy + down * kappa,
        center.dx - left,
        center.dy,
      )
      ..cubicTo(
        center.dx - left,
        center.dy - up * kappa,
        center.dx - left * kappa,
        center.dy - up,
        center.dx,
        center.dy - up,
      )
      ..close();

    canvas.save();
    // A slight rotation about the blob's own centre, so two blobs built from
    // similar numbers still land differently.
    canvas.translate(center.dx, center.dy);
    canvas.rotate(random.range(-math.pi / 5, math.pi / 5));
    canvas.translate(-center.dx, -center.dy);
    canvas.drawPath(path, Paint()..color = color);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SeededArtworkPainter oldDelegate) =>
      oldDelegate.seed != seed ||
      oldDelegate.palette != palette ||
      oldDelegate.intensity != intensity;
}
