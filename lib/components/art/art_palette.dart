import 'package:flutter/widgets.dart';

import 'package:local_markerplace/core/app_color.dart';

/// One family of colours the generated artwork is painted in.
///
/// [light] and [mid] are the two stops of the plate behind a card or tile;
/// [deep] is the saturated member, only ever used at low alpha for the bézier
/// curves drawn over the plate, so the flow's ink stays readable on top.
class ArtPalette {
  const ArtPalette(this.light, this.mid, this.deep);

  final Color light;
  final Color mid;
  final Color deep;

  /// The families, in the order [forSeed] cycles through them. Six is enough
  /// that a screenful of cards rarely repeats, and few enough that the flow
  /// still reads as one palette rather than a swatch book.
  static const List<ArtPalette> families = [
    ArtPalette(
      AppColor.artBlueLight,
      AppColor.artBlueMid,
      AppColor.artBlueDeep,
    ),
    ArtPalette(
      AppColor.artTealLight,
      AppColor.artTealMid,
      AppColor.artTealDeep,
    ),
    ArtPalette(
      AppColor.artVioletLight,
      AppColor.artVioletMid,
      AppColor.artVioletDeep,
    ),
    ArtPalette(
      AppColor.artAmberLight,
      AppColor.artAmberMid,
      AppColor.artAmberDeep,
    ),
    ArtPalette(
      AppColor.artRoseLight,
      AppColor.artRoseMid,
      AppColor.artRoseDeep,
    ),
    ArtPalette(
      AppColor.artGreenLight,
      AppColor.artGreenMid,
      AppColor.artGreenDeep,
    ),
  ];

  /// The greyed family, for artwork standing in for something that is not
  /// live yet — an area ServiQ has not opened, a listing still in review. It
  /// is deliberately outside [families] so no seed can ever land on it by
  /// accident; it is only ever asked for by name.
  static const dormant = ArtPalette(
    AppColor.discoveryPillMuted,
    AppColor.discoveryBorder,
    AppColor.discoveryTextTertiary,
  );

  /// The family belonging to [seed].
  ///
  /// Derived from the text itself, so a provider keeps the same colours on
  /// their card, their row and their profile, on every launch and on every
  /// device — no state is stored and nothing has to be assigned by hand.
  static ArtPalette forSeed(String seed) =>
      families[artHash(seed) % families.length];

  /// The family at [index], wrapping round.
  ///
  /// For a short, fixed set drawn together — the six category tiles — where
  /// hashing would happily hand three neighbours the same blue. Position is
  /// stable there in a way it is not in a list that comes from a server, so
  /// it can be used as the key instead.
  static ArtPalette familyAt(int index) => families[index % families.length];
}

/// A small, stable string hash — FNV-1a, 32-bit.
///
/// Dart's own [Object.hashCode] is not guaranteed to be the same between
/// runs, which would let a provider change colour on restart; this cannot.
int artHash(String seed) {
  var hash = 0x811c9dc5;
  for (var i = 0; i < seed.length; i++) {
    hash ^= seed.codeUnitAt(i);
    hash = (hash * 0x01000193) & 0x7fffffff;
  }
  return hash;
}

/// A deterministic stream of numbers in 0..1 for one seed.
///
/// Lets a painter vary a curve's control points per card without any two
/// runs disagreeing about where they went.
class ArtRandom {
  ArtRandom(String seed) : _state = artHash(seed) | 1;

  int _state;

  /// The next value, in [0, 1).
  double next() {
    // A 32-bit xorshift, kept inside Dart's safe integer range on web by
    // masking to 31 bits at every step.
    _state ^= (_state << 13) & 0x7fffffff;
    _state ^= _state >> 17;
    _state ^= (_state << 5) & 0x7fffffff;
    return (_state & 0xffffff) / 0x1000000;
  }

  /// The next value, scaled into [min, max).
  double range(double min, double max) => min + next() * (max - min);
}
