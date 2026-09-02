import 'package:flutter/foundation.dart';

/// Build-time switches for development conveniences.
class AppConfig {
  AppConfig._();

  /// Fills the OTP boxes automatically with the `devOtp` the backend echoes
  /// back while it runs the `log` provider (which delivers no SMS at all).
  ///
  /// Doubly guarded: the flag itself, and [kDebugMode] — so even if the flag
  /// is left on, a release build never auto-fills a one-time code, which
  /// would defeat the point of having one.
  ///
  /// Flip to false to exercise manual entry, and remove this once a real SMS
  /// provider is delivering codes.
  static const bool autoPopulateOtp = true;

  /// Whether auto-population should actually happen in this build.
  static bool get shouldAutoPopulateOtp => autoPopulateOtp && kDebugMode;
}
