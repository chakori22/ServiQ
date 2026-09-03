import 'package:flutter_test/flutter_test.dart';
import 'package:local_markerplace/network/auth_session.dart';
import 'package:local_markerplace/network/failure.dart';

import 'support/fakes.dart';

/// Covers signing out: the server is told to retire the refresh token, and
/// this device is cleared whatever the server says.
void main() {
  Future<AuthSession> signedIn(
    FakePersistentStore store,
    FakeLoginRepository repository,
  ) async {
    final session = AuthSession(
      store: store,
      repository: repository,
      deviceIdentity: FakeDeviceIdentity(),
    );
    await session.save(
      tokens: testTokens(accessToken: 'a1', refreshToken: 'r1'),
      user: testUser,
    );
    return session;
  }

  test('logout retires the refresh token the device holds', () async {
    final store = FakePersistentStore();
    final repository = FakeLoginRepository();
    final session = await signedIn(store, repository);

    final result = await session.signOut();

    expect(result.isRight(), isTrue);
    // The refresh token is the credential being revoked, not the access one.
    expect(repository.logoutCalls, ['r1']);
    expect(session.isAuthenticated, isFalse);
    expect(session.user, isNull);
    expect(store.blob, isNull);
  });

  test('a failed logout still signs the device out', () async {
    final store = FakePersistentStore();
    final repository = FakeLoginRepository()
      ..logoutFailure = const Failure(
        errorMessage: 'No internet connection. Please check your network.',
        errorCode: 'CONNECTION_ERROR',
      );
    final session = await signedIn(store, repository);

    final result = await session.signOut();

    // Reported, so the UI can say the server was not reached...
    expect(result.isLeft(), isTrue);
    // ...but the user is signed out here regardless. Leaving them signed in
    // because there was no signal would be the worse outcome.
    expect(session.isAuthenticated, isFalse);
    expect(store.blob, isNull);
  });

  test('signing out without a session does not call the endpoint', () async {
    final store = FakePersistentStore();
    final repository = FakeLoginRepository();
    final session = AuthSession(
      store: store,
      repository: repository,
      deviceIdentity: FakeDeviceIdentity(),
    );

    final result = await session.signOut();

    expect(result.isRight(), isTrue);
    expect(repository.logoutCalls, isEmpty);
  });

  test('logout is never pre-emptively refreshed before it is sent', () {
    // The request body carries the refresh token; refreshing first would
    // rotate it and revoke a token the server had already retired.
    expect(authEndpointPaths, contains('/api/v1/auth/logout'));
  });
}
