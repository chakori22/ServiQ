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

  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color accentColor = Color(0xFFC031C0);
  static const Color dropDownShadowColor = Color(0x47B7BAC6);
  static const Color footerShadowColorBlur30 = Color(0x7FC6C6C6);
  static const Color footerShadowColorBlur4 = Color(0x3FFFFFFF);
}
