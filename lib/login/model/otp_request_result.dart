/// `responseData` of `POST /api/v1/auth/otp/request`.
class OtpRequestResult {
  /// How long the issued OTP stays valid.
  final int expiresInSeconds;

  /// How long the user must wait before another OTP can be requested. The OTP
  /// screen counts down from this rather than a hardcoded value, so the client
  /// and the server's rate limit stay in step.
  final int resendAfterSeconds;

  /// Which channel actually delivered the OTP. `log` means the backend only
  /// wrote it to its own logs and nothing was sent to the handset.
  final String provider;

  /// Present only while the backend runs in dev mode, where it echoes the OTP
  /// back instead of delivering it. Never returned by a production provider.
  final String? devOtp;

  const OtpRequestResult({
    required this.expiresInSeconds,
    required this.resendAfterSeconds,
    required this.provider,
    this.devOtp,
  });

  factory OtpRequestResult.fromJson(Map<String, dynamic> json) {
    return OtpRequestResult(
      expiresInSeconds: json['expiresInSeconds'] as int? ?? 0,
      resendAfterSeconds: json['resendAfterSeconds'] as int? ?? 0,
      provider: json['provider'] as String? ?? '',
      devOtp: json['devOtp'] as String?,
    );
  }
}
