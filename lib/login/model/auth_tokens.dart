/// The `tokens` block of a successful OTP verification.
class AuthTokens {
  final String accessToken;

  /// Scheme to put in front of [accessToken] in the Authorization header —
  /// "Bearer" today, but taken from the response rather than assumed.
  final String tokenType;

  /// Access token lifetime in seconds (900 = 15 minutes).
  final int expiresIn;

  final String refreshToken;

  /// Refresh token lifetime in seconds (7776000 = 90 days).
  final int refreshExpiresIn;

  /// When this set was received, so expiry can be judged without trusting the
  /// device clock to agree with the server's.
  final DateTime issuedAt;

  AuthTokens({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.refreshToken,
    required this.refreshExpiresIn,
    DateTime? issuedAt,
  }) : issuedAt = issuedAt ?? DateTime.now();

  /// Value for the Authorization header, e.g. "Bearer eyJhbGci…".
  String get authorizationHeader => '$tokenType $accessToken';

  DateTime get accessTokenExpiresAt =>
      issuedAt.add(Duration(seconds: expiresIn));

  DateTime get refreshTokenExpiresAt =>
      issuedAt.add(Duration(seconds: refreshExpiresIn));

  /// Treats the token as spent slightly early, so a request is not sent with a
  /// token that expires while it is in flight.
  bool get isAccessTokenExpired => DateTime.now().isAfter(
    accessTokenExpiresAt.subtract(const Duration(seconds: 30)),
  );

  bool get isRefreshTokenExpired =>
      DateTime.now().isAfter(refreshTokenExpiresAt);

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['accessToken'] as String? ?? '',
      tokenType: json['tokenType'] as String? ?? 'Bearer',
      expiresIn: json['expiresIn'] as int? ?? 0,
      refreshToken: json['refreshToken'] as String? ?? '',
      refreshExpiresIn: json['refreshExpiresIn'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'tokenType': tokenType,
    'expiresIn': expiresIn,
    'refreshToken': refreshToken,
    'refreshExpiresIn': refreshExpiresIn,
    'issuedAt': issuedAt.toIso8601String(),
  };
}
