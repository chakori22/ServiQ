import 'package:flutter/material.dart';

import 'package:local_markerplace/core/app_color.dart';

/// Type scale for the discovery flow.
///
/// The design sets Plus Jakarta Sans at half-point sizes and negative
/// tracking throughout; collecting the styles here keeps every screen on the
/// same ramp and keeps the family name out of the widgets themselves.
class DiscoveryText {
  DiscoveryText._();

  static const String family = 'Plus Jakarta Sans';

  static const FontWeight _medium = FontWeight.w500;
  static const FontWeight _bold = FontWeight.w700;
  static const FontWeight _extraBold = FontWeight.w800;

  static TextStyle _style(
    double size,
    FontWeight weight,
    Color color, {
    double? letterSpacing,
    double? height,
  }) => TextStyle(
    fontFamily: family,
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
  );

  /// "Where do you need help?" — the area picker's hero.
  static TextStyle get hero =>
      _style(26, _extraBold, AppColor.discoveryInk, letterSpacing: -0.52);

  /// "What do you need done?" — home's headline.
  static TextStyle get headline =>
      _style(22, _extraBold, AppColor.discoveryInk, letterSpacing: -0.44);

  /// The title in a screen's header row.
  static TextStyle get appBarTitle =>
      _style(17, _extraBold, AppColor.discoveryInk, letterSpacing: -0.255);

  /// "Categories", "Near you", and a zone card's name.
  static TextStyle get sectionTitle =>
      _style(16.5, _extraBold, AppColor.discoveryInk, letterSpacing: -0.2475);

  /// A zone's name inside the area picker's grouped card.
  static TextStyle get groupTitle =>
      _style(15.5, _extraBold, AppColor.discoveryInk, letterSpacing: -0.155);

  /// "Societies" / "Markets".
  static TextStyle get groupHeading =>
      _style(15, _extraBold, AppColor.discoveryInk, letterSpacing: -0.15);

  /// The title of a drill-down row, and a provider's name in a list.
  static TextStyle get rowTitle =>
      _style(14.5, _bold, AppColor.discoveryInk, letterSpacing: -0.145);

  /// The same row, when the area behind it is not open yet.
  static TextStyle get rowTitleDisabled => _style(
    14.5,
    _bold,
    AppColor.discoveryTextDisabled,
    letterSpacing: -0.145,
  );

  /// "We'll show providers near you".
  static TextStyle get heroSubtitle =>
      _style(14, _medium, AppColor.discoveryTextSecondary);

  /// Text the seeker has typed into the search field.
  static TextStyle get searchValue => _style(14, _bold, AppColor.discoveryInk);

  /// The search field's placeholder.
  static TextStyle get searchHint =>
      _style(14, _medium, AppColor.discoveryTextTertiary);

  /// A provider's name on the "Near you" card, which wraps to two lines.
  static TextStyle get cardTitle => _style(
    13.5,
    _extraBold,
    AppColor.discoveryInk,
    letterSpacing: -0.135,
    height: 17 / 13.5,
  );

  /// The provider count at the end of a drill-down row.
  static TextStyle get rowCount =>
      _style(13, _extraBold, AppColor.discoveryAccent, letterSpacing: -0.13);

  /// The count beside a "Societies" / "Markets" heading.
  static TextStyle get groupCount =>
      _style(13, _extraBold, AppColor.discoveryTextTertiary);

  /// "Pick an area to see who works there".
  static TextStyle get subtitle =>
      _style(13, _medium, AppColor.discoveryTextSecondary);

  /// "See all", and the "10 societies · 6 markets" links on a zone card.
  static TextStyle get link =>
      _style(12.5, _bold, AppColor.discoveryAccent, letterSpacing: -0.125);

  /// A filter chip at rest, and the number beside a rating star.
  static TextStyle get chip =>
      _style(12.5, _bold, AppColor.discoveryInkMuted, letterSpacing: -0.125);

  /// The selected filter chip.
  static TextStyle get chipSelected =>
      _style(12.5, _bold, AppColor.white, letterSpacing: -0.125);

  /// "12 providers · Crossing Republik" under a locality's title.
  static TextStyle get caption =>
      _style(12.5, _medium, AppColor.discoveryTextSecondary);

  /// "Ghaziabad, UP", "7 results in Ajnara Gen X", and the footnote under the
  /// coming-soon zones.
  static TextStyle get footnote =>
      _style(12, _medium, AppColor.discoveryTextTertiary);

  /// The same footnote where it needs to read as body copy.
  static TextStyle get footnoteStrong =>
      _style(12, _medium, AppColor.discoveryTextSecondary);

  /// A provider's trade, under their name.
  static TextStyle get meta =>
      _style(11.5, _medium, AppColor.discoveryTextSecondary);

  /// The review count in brackets after a rating.
  static TextStyle get metaMuted =>
      _style(11.5, _medium, AppColor.discoveryTextTertiary);

  /// The caption under a category tile.
  static TextStyle get tileLabel =>
      _style(11.5, _bold, AppColor.discoveryInkMuted, letterSpacing: -0.115);

  /// A tab's label when it is the current one.
  static TextStyle get tabActive =>
      _style(10, _extraBold, AppColor.discoveryAccent, letterSpacing: 0.1);

  /// A tab's label at rest.
  static TextStyle get tabInactive =>
      _style(10, _bold, AppColor.discoveryTextDisabled, letterSpacing: 0.1);

  /// The "COMING SOON" heading over the unopened zones.
  static TextStyle get overline => _style(
    10,
    _extraBold,
    AppColor.discoveryTextTertiary,
    letterSpacing: 0.8,
  );

  /// Text inside a LIVE / OPEN pill.
  static TextStyle get pill =>
      _style(9.5, _extraBold, AppColor.discoveryLiveText, letterSpacing: 0.38);

  /// Text inside a COMING SOON pill.
  static TextStyle get pillMuted => _style(
    9.5,
    _extraBold,
    AppColor.discoveryPillMutedText,
    letterSpacing: 0.38,
  );

  /// White text on the gradient — the location button and the pending bar.
  static TextStyle onAccent(double size, {double? letterSpacing}) =>
      _style(size, _extraBold, AppColor.white, letterSpacing: letterSpacing);
}
