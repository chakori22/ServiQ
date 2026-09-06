import 'package:flutter/widgets.dart';

/// The app's motion vocabulary.
///
/// Every animation in ServiQ picks its timing and its easing from here rather
/// than naming its own, so a tap on a category tile, a tab swap and a hero
/// settling all move with the same hand. The curves are cubic béziers chosen
/// to feel physical: things leave quickly and arrive slowly, and nothing uses
/// a plain linear ramp.
///
/// Nothing here loops. Motion is either an entrance that finishes or a
/// response to a touch, which keeps the flow calm and keeps widget tests able
/// to settle.
class AppMotion {
  AppMotion._();

  /// A press reacting under a finger.
  static const Duration instant = Duration(milliseconds: 120);

  /// A chip filling, a pill swapping colour.
  static const Duration quick = Duration(milliseconds: 200);

  /// The default: a tab indicator sliding, a body cross-fading.
  static const Duration standard = Duration(milliseconds: 320);

  /// A card or a row arriving on screen.
  static const Duration entrance = Duration(milliseconds: 460);

  /// A hero's artwork drifting into place behind everything else.
  static const Duration ambient = Duration(milliseconds: 1400);

  /// Material's emphasised easing — the workhorse. Fast out, long settle.
  static const Curve emphasized = Cubic(0.2, 0, 0, 1);

  /// A softer arrival for large surfaces, where [emphasized] reads as abrupt.
  static const Curve settle = Cubic(0.16, 1, 0.3, 1);

  /// Something entering the screen, which should not start at full speed.
  static const Curve decelerate = Cubic(0.05, 0.7, 0.1, 1);

  /// A small element that is allowed to overshoot and come back — the post
  /// button, a filter chip.
  static const Curve overshoot = Cubic(0.34, 1.42, 0.64, 1);

  /// How far apart two neighbouring items start.
  static const Duration _step = Duration(milliseconds: 55);

  /// The delay before item [index] of a list begins its entrance.
  ///
  /// Capped so a long list does not end with rows arriving seconds after the
  /// first — past [cap] everything moves together.
  static Duration stagger(int index, {int cap = 7}) =>
      _step * index.clamp(0, cap);
}
