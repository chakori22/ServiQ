import 'package:flutter/material.dart';

import 'package:local_markerplace/core/app_color.dart';

/// Type scale for the discovery, provider and Me screens.
///
/// The designs set half-point sizes and negative tracking throughout;
/// collecting the styles here keeps every screen on the same ramp and keeps
/// the family name out of the widgets themselves.
///
/// The family is [family] — Mulish — which the theme also sets application
/// wide, so naming it here only matters for styles built from scratch rather
/// than inherited.
class DiscoveryText {
  DiscoveryText._();

  static const String family = 'Mulish';

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

  /// The lines of a saved address.
  static TextStyle get addressLine =>
      _style(11.5, _medium, AppColor.discoveryTextSecondary, height: 16 / 11.5);

  /// The prompt inside an empty upload target.
  static TextStyle get uploadPrompt => _style(
    12.5,
    _bold,
    AppColor.discoveryTextSecondary,
    letterSpacing: -0.125,
  );

  /// The label on a primary button that cannot be pressed yet.
  static TextStyle get buttonDisabled =>
      _style(16, _bold, AppColor.discoveryTextDisabled, letterSpacing: -0.16);

  /// "Not accepted".
  static TextStyle get rejectedTitle =>
      _style(16, _extraBold, AppColor.kycRejectDeep, letterSpacing: -0.24);

  /// The reviewer's note quoted in the rejection band.
  static TextStyle get rejectedQuote =>
      _style(13, _bold, AppColor.kycRejectDeep, height: 19 / 13);

  /// The label on a wide outlined button.
  static TextStyle get outlinedAction =>
      _style(15, _bold, AppColor.discoveryGradientEnd, letterSpacing: -0.15);

  /// The seeker's name at the top of Me.
  static TextStyle get meName =>
      _style(21, _extraBold, AppColor.discoveryInk, letterSpacing: -0.42);

  /// A destructive action, e.g. "Sign out".
  static TextStyle get danger =>
      _style(14, _bold, AppColor.kycRejectText, letterSpacing: -0.14);

  /// The heading of a bottom sheet.
  static TextStyle get sheetTitle =>
      _style(19, _extraBold, AppColor.discoveryInk, letterSpacing: -0.285);

  /// A row inside a sheet.
  static TextStyle get sheetOption =>
      _style(14.5, _bold, AppColor.discoveryInk, letterSpacing: -0.145);

  /// The same row when it removes something.
  static TextStyle get sheetOptionDanger =>
      _style(14.5, _bold, AppColor.kycRejectText, letterSpacing: -0.145);

  /// A value inside a form field.
  static TextStyle get fieldInput => _style(14.5, _bold, AppColor.discoveryInk);

  /// The same field when it cannot be edited.
  static TextStyle get fieldLocked =>
      _style(14.5, _medium, AppColor.discoveryTextDisabled);

  /// A small blue action such as "Edit" or "Change photo".
  static TextStyle get inlineLink =>
      _style(12, _bold, AppColor.discoveryAccent, letterSpacing: -0.12);

  /// Its muted twin, e.g. "Delete".
  static TextStyle get inlineLinkMuted =>
      _style(12, _bold, AppColor.discoveryTextTertiary, letterSpacing: -0.12);

  /// The heading over a list of tips.
  static TextStyle get tipsHeading => _style(
    9.5,
    _extraBold,
    AppColor.discoveryTextDisabled,
    letterSpacing: 0.57,
  );

  /// One tip, or a line of small print.
  static TextStyle get smallPrint =>
      _style(11, _medium, AppColor.discoveryTextSecondary, height: 15 / 11);

  /// The date under a document's status.
  static TextStyle get statusDate =>
      _style(11, _medium, AppColor.discoveryTextTertiary);

  /// The reviewer's reason, quoted back.
  static TextStyle get rejectionReason =>
      _style(11.5, _medium, AppColor.kycRejectDeep, height: 15 / 11.5);

  /// "This page is public. Sign in to connect…".
  static TextStyle get publicNote =>
      _style(12.5, _medium, AppColor.discoveryTextSecondary, height: 18 / 12.5);

  /// Heading of the no-badge explainer.
  static TextStyle get noteTitle =>
      _style(13, _extraBold, AppColor.discoveryInkMuted, letterSpacing: -0.13);

  /// Its body.
  static TextStyle get noteBody =>
      _style(11.5, _medium, AppColor.discoveryTextSecondary, height: 16 / 11.5);

  /// Who left a review.
  static TextStyle get reviewAuthor =>
      _style(13.5, _bold, AppColor.discoveryInk, letterSpacing: -0.135);

  /// When they left it.
  static TextStyle get reviewAge =>
      _style(11, _medium, AppColor.discoveryTextDisabled);

  /// What they wrote.
  static TextStyle get reviewBody =>
      _style(12.5, _medium, AppColor.discoveryInkMuted, height: 19 / 12.5);

  /// An "ADDRESS" / "HOURS" / "SERVES" heading on the About tab.
  static TextStyle get fieldLabel => _style(
    10,
    _extraBold,
    AppColor.discoveryTextTertiary,
    letterSpacing: 0.6,
  );

  /// The value under it.
  static TextStyle get fieldValue =>
      _style(13, _medium, AppColor.discoveryInk, height: 20 / 13);

  /// The paragraph at the top of the About tab.
  static TextStyle get body =>
      _style(13, _medium, AppColor.discoveryInkMuted, height: 20 / 13);

  /// A product's name on its store card.
  static TextStyle get productName =>
      _style(12.5, _bold, AppColor.discoveryInk, height: 16 / 12.5);

  /// Its price.
  static TextStyle get productPrice =>
      _style(14.5, _extraBold, AppColor.discoveryInk, letterSpacing: -0.145);

  /// "In stock".
  static TextStyle get stockIn =>
      _style(10.5, _bold, AppColor.discoveryLiveText);

  /// "Only 2 left".
  static TextStyle get stockLow => _style(10.5, _bold, AppColor.authError);

  /// The "Add" chip's label.
  static TextStyle get addChip =>
      _style(11.5, _bold, AppColor.discoveryGradientEnd, letterSpacing: -0.115);

  /// The big score on the reviews summary.
  static TextStyle get ratingHeadline =>
      _style(38, _extraBold, AppColor.discoveryInk, letterSpacing: -1.14);

  /// The star number beside a distribution bar.
  static TextStyle get breakdownStar =>
      _style(10.5, _bold, AppColor.discoveryTextTertiary);

  /// The percentage after it.
  static TextStyle get breakdownPercent =>
      _style(10, _medium, AppColor.discoveryTextDisabled);

  /// A "from ₹499" price beside a service.
  static TextStyle get price => _style(
    13,
    _extraBold,
    AppColor.discoveryGradientEnd,
    letterSpacing: -0.13,
  );

  /// The name of a service on its card.
  static TextStyle get sectionTitleSmall =>
      _style(14.5, _extraBold, AppColor.discoveryInk, letterSpacing: -0.145);

  /// The "Book" action on a service card.
  static TextStyle get bookLink =>
      _style(12, _bold, AppColor.discoveryAccent, letterSpacing: -0.12);

  /// A provider's business name, centred under their avatar.
  static TextStyle get providerName => _style(
    24,
    _extraBold,
    AppColor.discoveryInk,
    letterSpacing: -0.48,
    height: 30 / 24,
  );

  /// The label on the profile's filled action.
  static TextStyle get actionOnAccent =>
      _style(15.5, _bold, AppColor.white, letterSpacing: -0.155);

  /// The label on its outlined twin.
  static TextStyle get actionOutlined =>
      _style(15.5, _bold, AppColor.discoveryGradientEnd, letterSpacing: -0.155);

  /// Initials drawn on an avatar, at whatever size the avatar is.
  static TextStyle avatarInitials(double size) => _style(
    size,
    _extraBold,
    AppColor.discoveryAvatarText,
    letterSpacing: size * 0.01,
  );

  /// The current section in a provider's segmented tab strip.
  static TextStyle get tabLabelActive =>
      _style(13.5, _extraBold, AppColor.discoveryAccent, letterSpacing: -0.135);

  /// A section the seeker is not looking at.
  static TextStyle get tabLabelInactive => _style(
    13.5,
    _medium,
    AppColor.discoveryTextSecondary,
    letterSpacing: -0.135,
  );

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
