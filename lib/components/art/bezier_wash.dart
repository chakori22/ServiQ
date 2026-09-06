import 'package:flutter/widgets.dart';

import 'package:local_markerplace/components/motion/app_motion.dart';
import 'package:local_markerplace/core/app_color.dart';

/// The flowing backdrop behind a hero.
///
/// Three cubic-bézier ribbons drift up into place over a soft gradient, with
/// a pair of radial glows behind them. It replaces the flat washes the heroes
/// used to sit on: the curves give a screen a horizon and a sense of depth
/// without needing an illustration.
///
/// The drift runs once, on the first build, and settles — nothing here loops,
/// so a screen is still after it has arrived.
class BezierWash extends StatefulWidget {
  const BezierWash({
    super.key,
    this.child,
    this.colors = const [
      AppColor.discoveryHeroTop,
      AppColor.discoveryHeroMid,
      AppColor.white,
    ],
    this.accent = AppColor.discoveryAccent,
    this.animate = true,
    this.intensity = 1,
  });

  /// Drawn over the backdrop.
  final Widget? child;

  /// Stops of the wash, top to bottom.
  final List<Color> colors;

  /// The colour the ribbons and glows are tinted with.
  final Color accent;

  /// False pins the artwork at rest — for a backdrop that is already on
  /// screen when its screen appears, where a second entrance reads as a
  /// flicker.
  final bool animate;

  /// Scales how strongly the ribbons read. Small headers want less.
  final double intensity;

  @override
  State<BezierWash> createState() => _BezierWashState();
}

class _BezierWashState extends State<BezierWash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.ambient,
    value: widget.animate ? 0 : 1,
  );

  late final Animation<double> _drift = CurvedAnimation(
    parent: _controller,
    curve: AppMotion.settle,
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _drift,
      child: widget.child,
      builder: (context, child) => CustomPaint(
        painter: _BezierWashPainter(
          colors: widget.colors,
          accent: widget.accent,
          intensity: widget.intensity,
          drift: _drift.value,
        ),
        child: child,
      ),
    );
  }
}

class _BezierWashPainter extends CustomPainter {
  _BezierWashPainter({
    required this.colors,
    required this.accent,
    required this.intensity,
    required this.drift,
  });

  final List<Color> colors;
  final Color accent;
  final double intensity;

  /// 0 while the ribbons are still low and flat, 1 once they have settled.
  final double drift;

  /// The three ribbons, as (baseline, amplitude, alpha) fractions. Reading
  /// them off one table keeps the bands from crowding each other.
  static const _bands = [
    (0.58, 0.20, 0.10),
    (0.72, 0.15, 0.07),
    (0.86, 0.11, 0.05),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;

    canvas.drawRect(
      bounds,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ).createShader(bounds),
    );

    // Two glows, sitting off opposite edges so the light does not read as
    // coming from the middle of the screen.
    _paintGlow(
      canvas,
      Offset(size.width * -0.05, size.height * 0.06),
      size.shortestSide * 0.62,
      0.11 * intensity,
    );
    _paintGlow(
      canvas,
      Offset(size.width * 0.92, size.height * 0.30),
      size.shortestSide * 0.48,
      0.09 * intensity,
    );

    for (var i = 0; i < _bands.length; i++) {
      final (baseline, amplitude, alpha) = _bands[i];
      // Each band starts a little lower and flatter than it ends, and the
      // ones further back move further — which is what reads as depth.
      final depth = 1 - i * 0.22;
      final rise = (1 - drift) * size.height * 0.10 * depth;
      final crest = size.height * baseline + rise;
      final swell = size.height * amplitude * (0.55 + 0.45 * drift) * depth;

      final path = Path()
        ..moveTo(-size.width * 0.05, crest)
        ..cubicTo(
          size.width * 0.24,
          crest - swell,
          size.width * 0.58,
          crest + swell * 0.72,
          size.width * 1.05,
          crest - swell * 0.34,
        )
        ..lineTo(size.width * 1.05, size.height + 1)
        ..lineTo(-size.width * 0.05, size.height + 1)
        ..close();

      canvas.drawPath(
        path,
        Paint()..color = accent.withValues(alpha: alpha * intensity),
      );
    }

    // The ribbons are dissolved into the last stop over the bottom third.
    // Without this the wash ends on a visible line wherever the page behind
    // it is white, because the ribbons tint the gradient's final stop.
    final fade = Rect.fromLTWH(
      0,
      size.height * 0.62,
      size.width,
      size.height * 0.38 + 1,
    );
    canvas.drawRect(
      fade,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colors.last.withValues(alpha: 0), colors.last],
        ).createShader(fade),
    );
  }

  void _paintGlow(Canvas canvas, Offset center, double radius, double alpha) {
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            accent.withValues(alpha: alpha),
            accent.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  @override
  bool shouldRepaint(_BezierWashPainter oldDelegate) =>
      oldDelegate.drift != drift ||
      oldDelegate.accent != accent ||
      oldDelegate.intensity != intensity ||
      oldDelegate.colors != colors;
}
