import 'package:flutter_test/flutter_test.dart';
import 'package:local_markerplace/login/model/auth_tokens.dart';
import 'package:local_markerplace/network/api_client.dart';
import 'package:local_markerplace/login/repository/login_repository.dart';

/// Hits the real dev backend. Tagged so it can be excluded from CI once the
/// suite grows: `flutter test --exclude-tags live`.
void main() {
  final repository = LoginRepository(
    apiClient: APIClient(baseUrl: 'http://13.207.78.186:8080'),
  );

  /// A fresh 10-digit number for every run. Reusing one would trip the
  /// server's own 30s resend cooldown and fail the next run instead.
  String uniqueNumber() {
    final tail = DateTime.now().microsecondsSinceEpoch % 1000000000;
    return '9${tail.toString().padLeft(9, '0')}';
  }

  test('requestOtp returns the cooldown and expiry on success', () async {
    final result = await repository.requestOtp(
      countryCode: '+91',
      phoneNumber: uniqueNumber(),
    );

    result.fold((failure) => fail('expected success, got: $failure'), (otp) {
      expect(otp.expiresInSeconds, greaterThan(0));
      expect(otp.resendAfterSeconds, greaterThan(0));
      expect(otp.provider, isNotEmpty);
    });
  }, tags: 'live');

  test('requestOtp surfaces the server validation message', () async {
    final result = await repository.requestOtp(
      countryCode: '+91',
      phoneNumber: '123',
    );

    result.fold((failure) {
      expect(failure.errorCode, 'VALIDATION_ERROR');
      expect(failure.errorMessage, contains('10 digits'));
    }, (otp) => fail('expected a validation failure, got: $otp'));
  }, tags: 'live');

  test('requestOtp surfaces the resend cooldown rejection', () async {
    final number = uniqueNumber();
    await repository.requestOtp(countryCode: '+91', phoneNumber: number);
    final second = await repository.requestOtp(
      countryCode: '+91',
      phoneNumber: number,
    );

    second.fold((failure) {
      expect(failure.errorCode, 'OTP_RESEND_TOO_SOON');
    }, (otp) => fail('expected a cooldown failure, got: $otp'));
  }, tags: 'live');

  test('verifyOtp exchanges a correct OTP for tokens and the user', () async {
    final number = uniqueNumber();
    final requested = await repository.requestOtp(
      countryCode: '+91',
      phoneNumber: number,
    );
    // Only possible because the backend runs the `log` provider and echoes the
    // code back; a real provider would make this untestable from here.
    final devOtp = requested.fold((f) => fail('request failed: $f'), (o) {
      expect(o.devOtp, isNotNull, reason: 'needs the log provider');
      return o.devOtp!;
    });

    final result = await repository.verifyOtp(
      countryCode: '+91',
      phoneNumber: number,
      otp: devOtp,
      deviceId: 'integration-test-device',
    );

    result.fold((failure) => fail('expected success, got: $failure'), (
      verified,
    ) {
      expect(verified.tokens.accessToken, isNotEmpty);
      expect(verified.tokens.refreshToken, isNotEmpty);
      expect(verified.tokens.tokenType, 'Bearer');
      expect(verified.tokens.authorizationHeader, startsWith('Bearer '));
      expect(verified.tokens.isAccessTokenExpired, isFalse);
      expect(verified.user.userId, isNotEmpty);
      expect(verified.user.phoneNumber, number);
      expect(verified.user.verified, isTrue);
    });
  }, tags: 'live');

  test('verifyOtp reports a wrong code with the attempts remaining', () async {
    final number = uniqueNumber();
    await repository.requestOtp(countryCode: '+91', phoneNumber: number);

    final result = await repository.verifyOtp(
      countryCode: '+91',
      phoneNumber: number,
      otp: '000000',
      deviceId: 'integration-test-device',
    );

    result.fold((failure) {
      expect(failure.errorCode, 'INVALID_OTP');
      expect(failure.errorMessage, contains('attempt'));
    }, (verified) => fail('expected a rejection, got: $verified'));
  }, tags: 'live');

  /// Drives a full sign-in and hands back the tokens, so refresh tests start
  /// from a genuine session.
  Future<AuthTokens> signIn(String deviceId) async {
    final number = uniqueNumber();
    final requested = await repository.requestOtp(
      countryCode: '+91',
      phoneNumber: number,
    );
    final devOtp = requested.fold((f) => fail('request failed: $f'), (o) {
      expect(o.devOtp, isNotNull, reason: 'needs the log provider');
      return o.devOtp!;
    });
    final verified = await repository.verifyOtp(
      countryCode: '+91',
      phoneNumber: number,
      otp: devOtp,
      deviceId: deviceId,
    );
    return verified.fold((f) => fail('verify failed: $f'), (v) => v.tokens);
  }

  test('refreshTokens returns a new pair and rotates the refresh token',
      () async {
    const deviceId = 'integration-test-device';
    final original = await signIn(deviceId);

    final result = await repository.refreshTokens(
      refreshToken: original.refreshToken,
      deviceId: deviceId,
    );

    result.fold((failure) => fail('expected success, got: $failure'), (
      tokens,
    ) {
      expect(tokens.accessToken, isNotEmpty);
      expect(tokens.tokenType, 'Bearer');
      // Note the access token is deliberately not asserted to differ: the JWT
      // carries iat/exp at one-second resolution, so a refresh inside the same
      // second re-signs an identical payload and returns the same string.
      expect(tokens.isAccessTokenExpired, isFalse);
      // The rotation that makes replaying the old token dangerous.
      expect(tokens.refreshToken, isNot(original.refreshToken));
    });
  }, tags: 'live');

  test('replaying a spent refresh token ends the session', () async {
    const deviceId = 'integration-test-device';
    final original = await signIn(deviceId);

    await repository.refreshTokens(
      refreshToken: original.refreshToken,
      deviceId: deviceId,
    );
    // Presenting the same token a second time is what AuthSession's
    // single-flight guard exists to prevent.
    final replayed = await repository.refreshTokens(
      refreshToken: original.refreshToken,
      deviceId: deviceId,
    );

    replayed.fold((failure) {
      expect(failure.errorCode, 'REFRESH_TOKEN_REUSED');
    }, (tokens) => fail('a spent token should not be accepted: $tokens'));
  }, tags: 'live');

  test('an unknown refresh token is rejected', () async {
    final result = await repository.refreshTokens(
      refreshToken: 'not-a-real-token',
      deviceId: 'integration-test-device',
    );

    result.fold((failure) {
      expect(failure.errorCode, 'REFRESH_TOKEN_INVALID');
    }, (tokens) => fail('expected a rejection, got: $tokens'));
  }, tags: 'live');
}
