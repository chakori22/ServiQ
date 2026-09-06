import 'package:flutter/widgets.dart';

import 'package:local_markerplace/components/motion/app_motion.dart';

/// Fades and lifts its child into place once, when it first builds.
///
/// [index] staggers a list: each row starts a little after the one above it,
/// so a screen assembles itself rather than appearing all at once. The delay
/// is an [Interval] on a single controller rather than a timer, which keeps
/// the whole entrance inside one animation — a pending timer would outlive a
/// widget test.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.index = 0,
    this.offset = const Offset(0, 0.14),
    this.duration = AppMotion.entrance,
    this.curve = AppMotion.settle,
  });

  final Widget child;

  /// Position in the list this child belongs to; 0 starts immediately.
  final int index;

  /// Where the child starts, as a fraction of its own size.
  final Offset offset;

  final Duration duration;
  final Curve curve;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final Duration _delay = AppMotion.stagger(widget.index);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration + _delay,
  );

  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    // The delay is spent at rest at the start of the controller's run, so
    // the child holds still until its turn and then takes its full duration.
    curve: Interval(
      _delay.inMicroseconds / (widget.duration + _delay).inMicroseconds,
      1,
      curve: widget.curve,
    ),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: widget.offset,
          end: Offset.zero,
        ).animate(_animation),
        child: widget.child,
      ),
    );
  }
}

/// Shrinks its child slightly while a finger is down on it.
///
/// Used instead of a bare [GestureDetector] on every card and tile in the
/// flow: the cards have no ink surface under them, so without this a tap has
/// no feedback at all until the next screen arrives.
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.965,
  });

  final Widget child;
  final VoidCallback? onTap;

  /// How far down the press goes. Smaller surfaces can take more.
  final double pressedScale;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value) return;
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    // A disabled target still renders, but must not appear to react.
    final isEnabled = widget.onTap != null;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: isEnabled ? (_) => _setPressed(true) : null,
      onTapUp: isEnabled ? (_) => _setPressed(false) : null,
      onTapCancel: isEnabled ? () => _setPressed(false) : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? widget.pressedScale : 1,
        duration: AppMotion.instant,
        curve: AppMotion.emphasized,
        child: widget.child,
      ),
    );
  }
}
