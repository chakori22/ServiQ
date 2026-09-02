import 'auth_tokens.dart';
import 'auth_user.dart';

/// `responseData` of `POST /api/v1/auth/otp/verify`.
class VerifyOtpResult {
  final AuthTokens tokens;
  final AuthUser user;

  const VerifyOtpResult({required this.tokens, required this.user});

  factory VerifyOtpResult.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResult(
      tokens: AuthTokens.fromJson(json['tokens'] as Map<String, dynamic>? ?? {}),
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
    );
  }
}
