import 'package:flutter/material.dart';

class AppColor {
  AppColor._();

  static const Color neutralGreyColor50 = Color(0xFFF4F4F4);
  static const Color neutralGreyColor60 = Color(0xFFF7F7F7);
  static const Color neutralGreyColor70 = Color(0xFFE7E8E9);
  static const Color neutralGreyColor80 = Color(0xFFCCCED0);
  static const Color neutralGreyColor100 = Color(0xFFE0E0E0);
  static const Color neutralGreyColor110 = Color(0xFF7D8287);
  static const Color neutralGreyColor130 = Color(0xFF4C4F52);
  static const Color neutralGreyColor140 = Color(0xFF333638);
  static const Color neutralGreyColor150 = Color(0xFF202428);
  static const Color neutralGreyColor200 = Color(0xFFC6C6C6);
  static const Color neutralGreyColor300 = Color(0xFFA8A8A8);
  static const Color neutralGreyColor400 = Color(0xFF8D8D8D);
  static const Color neutralGreyColor500 = Color(0xFF6F6F6F);
  static const Color neutralGreyColor600 = Color(0xFF525252);
  static const Color neutralGreyColor700 = Color(0xFF393939);
  static const Color neutralGreyColor800 = Color(0xFF262626);
  static const Color neutralGreyColor900 = Color(0xFF161616);

  static const Color indicativeBlueColor50 = Color(0xFFEDF5FF);
  static const Color indicativeBlueColor100 = Color(0xFFD0E2FF);
  static const Color indicativeBlueColor200 = Color(0xFFA6C8FF);
  static const Color indicativeBlueColor300 = Color(0xFF78A9FF);
  static const Color indicativeBlueColor400 = Color(0xFF4589FF);
  static const Color indicativeBlueColor500 = Color(0xFF0F62FE);
  static const Color indicativeBlueColor600 = Color(0xFF0043CE);
  static const Color indicativeBlueColor700 = Color(0xFF002D9C);
  static const Color indicativeBlueColor800 = Color(0xFF001D6C);
  static const Color indicativeBlueColor900 = Color(0xFF001141);

  static const Color indicativePurpleColor500 = Color(0xFF970EFF);
  static const Color indicativePurpleColor100 = Color(0xFFF8EDFF);

  // --- Auth screens -------------------------------------------------------
  // Tokens for the sign-in flow's lighter, gradient-led look. Kept separate
  // from the numbered ramps above so restyling auth cannot bleed into the
  // dashboard, which still uses those.

  /// Top of the page wash behind the logo.
  static const Color authBackgroundTop = Color(0xFFF7FAFF);

  /// Bottom of the page wash, a touch bluer than the top.
  static const Color authBackgroundBottom = Color(0xFFE8F0FD);

  /// Soft blue glow painted behind the logo.
  static const Color authGlow = Color(0xFFD5E4FB);

  /// The sheet the form sits on.
  static const Color authSurface = Color(0xFFFFFFFF);

  /// Headings.
  static const Color authTextPrimary = Color(0xFF0F1720);

  /// Supporting copy and hints.
  static const Color authTextSecondary = Color(0xFF6B7684);

  /// Fill of an input at rest.
  static const Color authFieldFill = Color(0xFFF7F9FC);

  /// Border of an input at rest.
  static const Color authFieldBorder = Color(0xFFE4EAF3);

  /// Border of the focused input and the filled OTP boxes.
  static const Color authAccent = Color(0xFF2F6BFF);

  /// Darker stop of the primary call-to-action gradient.
  static const Color authAccentDeep = Color(0xFF1B5AF0);

  /// Link and emphasised-number blue.
  static const Color authLink = Color(0xFF1E63F5);

  /// Error border, digits and message.
  static const Color authError = Color(0xFFE5484D);

  /// Tint behind an errored OTP box.
  static const Color authErrorTint = Color(0xFFFDF2F2);

  /// "Code detected from SMS" confirmation.
  static const Color authSuccess = Color(0xFF12A594);

  /// Light stop of the verified check's gradient.
  static const Color authSuccessLight = Color(0xFF3ED6B5);

  /// WhatsApp green used on the resend chip.
  static const Color authWhatsApp = Color(0xFF25D366);

  /// Mint tint at the top of the "You're all set" wash, which the rest of
  /// onboarding does not use.
  static const Color onboardingSuccessWashTop = Color(0xFFEAF8F3);

  // --- Discovery flow ------------------------------------------------------
  // Tokens for the "02 · Discovery" screens (area picker, home, explore,
  // search). Kept in their own block for the same reason as auth: the flow
  // has a colder, higher-contrast palette than the dashboard, and restyling
  // one must not drag the other with it.

  /// Headings and row titles.
  static const Color discoveryInk = Color(0xFF0B1220);

  /// Strong secondary text — chip labels, ratings, category captions.
  static const Color discoveryInkMuted = Color(0xFF33415C);

  /// Body and supporting copy.
  static const Color discoveryTextSecondary = Color(0xFF64748B);

  /// Hints, counts and captions.
  static const Color discoveryTextTertiary = Color(0xFF94A3B8);

  /// Text of a row that is not tappable yet, e.g. a coming-soon area.
  static const Color discoveryTextDisabled = Color(0xFFA7B2C6);

  /// Hairlines, card borders and dividers.
  static const Color discoveryBorder = Color(0xFFE2E9F7);

  /// Fill of a category tile, the idle search field and the header buttons.
  static const Color discoveryTint = Color(0xFFF4F9FE);

  /// Fill of a card whose content is not live yet.
  static const Color discoverySurfaceMuted = Color(0xFFFAFCFF);

  /// Fill and text of the COMING SOON pill.
  static const Color discoveryPillMuted = Color(0xFFF1F5FB);
  static const Color discoveryPillMutedText = Color(0xFF8FA0BC);

  /// The flow's link and active-tab blue.
  static const Color discoveryAccent = Color(0xFF1E6FE8);

  /// Stops of the primary call-to-action gradient, used on the location
  /// button, the pending-booking bar and the post FAB.
  static const Color discoveryGradientStart = Color(0xFF3B8AF5);
  static const Color discoveryGradientEnd = Color(0xFF1553BE);

  /// Fill, text and dot of the LIVE / OPEN pill.
  static const Color discoveryLiveTint = Color(0xFFE6F9F1);
  static const Color discoveryLiveText = Color(0xFF059669);

  /// The verified check on a provider avatar.
  static const Color discoveryVerified = Color(0xFF10B981);

  /// Rating star.
  static const Color discoveryStar = Color(0xFFF59E0B);

  /// Provider avatar: a dark navy gradient behind light initials.
  static const Color discoveryAvatarTop = Color(0xFF1F3466);
  static const Color discoveryAvatarBottom = Color(0xFF101A33);
  static const Color discoveryAvatarText = Color(0xFFC9D4E5);

  /// Chevron at the end of a drill-down row.
  static const Color discoveryChevron = Color(0xFFC9D4E5);

  /// Wash behind the area picker's hero, top to bottom.
  static const Color discoveryHeroTop = Color(0xFFEDF3FF);
  static const Color discoveryHeroMid = Color(0xFFF7FAFF);

  /// Subtitle inside the blue pending-booking bar.
  static const Color discoveryOnAccentMuted = Color(0xFFBBD4FF);

  /// Fill of the search field's clear button.
  static const Color discoveryClearFill = Color(0xFFEEF3FB);

  /// Colour the flow's shadows are tinted with.
  static const Color discoveryShadow = Color(0xFF17244A);

  // --- Provider profile ----------------------------------------------------
  // The public provider page shares discovery's palette; these are the few
  // surfaces it adds.

  /// Middle stop of the profile hero's wash, at 70%.
  static const Color providerHeroMid = Color(0xFFF8FBFF);

  /// Fill of the "no verified badge" explainer.
  static const Color providerNoteFill = Color(0xFFF7FAFF);

  /// The map thumbnail's ground, and the placeholder behind a product photo.
  static const Color providerMapFill = Color(0xFFEAF1FB);

  /// A block of buildings on the map thumbnail.
  static const Color providerMapBlock = Color(0xFFDCE9FF);

  /// The shape standing in for a product photo.
  static const Color providerImageShape = Color(0xFFC3D4EC);

  /// Fill of the small "Add" chip on a product card.
  static const Color providerChipFill = Color(0xFFEEF4FF);

  // --- Me & identity verification ------------------------------------------
  // Statuses carry most of the meaning on these screens, so each one gets a
  // tint and a text colour rather than being spelled out inline.

  /// A document waiting on a reviewer.
  static const Color kycPendingTint = Color(0xFFFEF6E7);
  static const Color kycPendingText = Color(0xFFB45309);

  /// One that came back rejected, and the band that carries the reason.
  static const Color kycRejectTint = Color(0xFFFEF3F3);
  static const Color kycRejectText = Color(0xFFDC2626);
  static const Color kycRejectDeep = Color(0xFFB42318);

  /// The circle behind the rejection mark.
  static const Color kycRejectMark = Color(0xFFEF4444);

  /// The DEFAULT pill on a saved address.
  static const Color addressDefaultTint = Color(0xFFEAF1FE);

  /// Border of an empty upload target.
  static const Color uploadDashedBorder = Color(0xFFC9D4E5);

  /// A primary button that cannot be pressed yet.
  static const Color buttonDisabledFill = Color(0xFFE7ECF6);

  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color accentColor = Color(0xFFC031C0);
  static const Color dropDownShadowColor = Color(0x47B7BAC6);
  static const Color footerShadowColorBlur30 = Color(0x7FC6C6C6);
  static const Color footerShadowColorBlur4 = Color(0x3FFFFFFF);
}
