import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_markerplace/network/auth_session.dart';
import 'package:local_markerplace/network/token_refresh_interceptor.dart';
import 'package:local_markerplace/network/failure.dart';

import 'support/fakes.dart';

/// Answers 401 until [failuresBeforeSuccess] responses have been given, then
/// 200 — modelling an access token that expires and is renewed.
class ExpiringAdapter implements HttpClientAdapter {
  ExpiringAdapter({this.failuresBeforeSuccess = 1});

  final int failuresBeforeSuccess;
  final List<String> authorizationHeaders = [];
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    authorizationHeaders.add(
      options.headers['Authorization']?.toString() ?? '(none)',
    );
    final expired = calls <= failuresBeforeSuccess;
    return ResponseBody.fromString(
      jsonEncode({
        'responseCode': expired ? '401 Unauthorized' : '200 OK',
        'errorCode': expired ? 'AUTH_TOKEN_EXPIRED' : null,
        'responseMessage': expired ? 'Access token expired' : 'Success',
        'responseData': expired ? null : {'userId': 'USR1'},
      }),
      expired ? 401 : 200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Always answers 200, recording what Authorization each request carried —
/// used to show a request went out already bearing a renewed token, rather
/// than being corrected after a 401.
class RecordingAdapter implements HttpClientAdapter {
  final List<String> authorizationHeaders = [];
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    authorizationHeaders.add(
      options.headers['Authorization']?.toString() ?? '(none)',
    );
    return ResponseBody.fromString(
      jsonEncode({
        'responseCode': '200 OK',
        'errorCode': null,
        'responseMessage': 'Success',
        'responseData': {'userId': 'USR1'},
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Dio buildDio(AuthSession session, HttpClientAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'http://example.invalid'))
    ..httpClientAdapter = adapter;
  dio.interceptors.add(AuthInterceptor(session));
  dio.interceptors.add(
    TokenRefreshInterceptor(session: session, dio: dio),
  );
  return dio;
}

Future<AuthSession> signedInSession({
  required FakePersistentStore store,
  required FakeLoginRepository repository,
}) async {
  final session = AuthSession(
    store: store,
    repository: repository,
    deviceIdentity: FakeDeviceIdentity(),
  );
  await session.save(
    tokens: testTokens(accessToken: 'expired-access', refreshToken: 'r1'),
    user: testUser,
  );
  return session;
}

/// A signed-in session whose access token expired [ago] in the past, which is
/// what an app left open past the 15-minute lifetime looks like.
Future<AuthSession> staleSession({
  required FakePersistentStore store,
  required FakeLoginRepository repository,
  Duration ago = const Duration(minutes: 16),
}) async {
  final session = AuthSession(
    store: store,
    repository: repository,
    deviceIdentity: FakeDeviceIdentity(),
  );
  await session.save(
    tokens: testTokens(
      accessToken: 'stale-access',
      refreshToken: 'r1',
      issuedAt: DateTime.now().subtract(ago),
    ),
    user: testUser,
  );
  return session;
}

void main() {
  group('an access token that has already expired', () {
    test('is renewed before the request goes out, with no wasted 401', () async {
      final store = FakePersistentStore();
      final repository = FakeLoginRepository(
        responses: [testTokens(accessToken: 'fresh-access', refreshToken: 'r2')],
      );
      final session = await staleSession(store: store, repository: repository);
      final adapter = RecordingAdapter();

      await buildDio(session, adapter).get('/api/v1/profile');

      expect(repository.refreshCalls, ['r1']);
      // One call, already carrying the new token: the old one was never sent.
      expect(adapter.calls, 1);
      expect(adapter.authorizationHeaders, ['Bearer fresh-access']);
    });

    test('does not make the refresh endpoint refresh itself', () async {
      final store = FakePersistentStore();
      final repository = FakeLoginRepository(
        responses: [testTokens(accessToken: 'fresh-access', refreshToken: 'r2')],
      );
      final session = await staleSession(store: store, repository: repository);
      final adapter = RecordingAdapter();

      await buildDio(session, adapter).post('/api/v1/auth/token/refresh');

      // Refreshing before a refresh would recurse through this interceptor.
      expect(repository.refreshCalls, isEmpty);
    });

    test('is renewed once even when several requests wake together', () async {
      final store = FakePersistentStore();
      final repository = FakeLoginRepository(
        responses: [testTokens(accessToken: 'fresh-access', refreshToken: 'r2')],
      );
      final session = await staleSession(store: store, repository: repository);
      final gate = Completer<void>();
      repository.gate = gate.future;
      final adapter = RecordingAdapter();
      final dio = buildDio(session, adapter);

      final inFlight = Future.wait([
        dio.get('/api/v1/profile'),
        dio.get('/api/v1/bookings'),
      ]);
      gate.complete();
      await inFlight;

      // The backend ends the session if a refresh token is presented twice.
      expect(repository.refreshCalls, ['r1']);
      expect(adapter.authorizationHeaders, [
        'Bearer fresh-access',
        'Bearer fresh-access',
      ]);
    });

    test('a request still succeeds when the pre-emptive renewal fails', () async {
      final store = FakePersistentStore();
      // No scripted response and no failure set: the refresh comes back Left,
      // modelling the network being down at exactly the wrong moment.
      final repository = FakeLoginRepository(
        failure: const Failure(
          errorMessage: 'no signal',
          errorCode: 'CONNECTION_ERROR',
        ),
      );
      final session = await staleSession(store: store, repository: repository);
      final adapter = RecordingAdapter();

      final response = await buildDio(session, adapter).get('/api/v1/profile');

      // A transport failure keeps the credential, so the stale token is still
      // sent rather than the request being abandoned.
      expect(response.statusCode, 200);
      expect(adapter.authorizationHeaders, ['Bearer stale-access']);
    });
  });

  test('a 401 renews the token and replays the request', () async {
    final repository = FakeLoginRepository(
      responses: [testTokens(accessToken: 'fresh-access', refreshToken: 'r2')],
    );
    final session = await signedInSession(
      store: FakePersistentStore(),
      repository: repository,
    );
    final adapter = ExpiringAdapter();
    final dio = buildDio(session, adapter);

    final response = await dio.get('/api/v1/users/me');

    expect(response.statusCode, 200);
    expect(adapter.calls, 2, reason: 'original + replay');
    // The replay must not reuse the token that just failed.
    expect(adapter.authorizationHeaders.first, 'Bearer expired-access');
    expect(adapter.authorizationHeaders.last, 'Bearer fresh-access');
    expect(repository.refreshCalls, ['r1']);
  });

  test('the rotated refresh token is persisted after the renewal', () async {
    final store = FakePersistentStore();
    final session = await signedInSession(
      store: store,
      repository: FakeLoginRepository(
        responses: [testTokens(refreshToken: 'r2')],
      ),
    );
    final dio = buildDio(session, ExpiringAdapter());

    await dio.get('/api/v1/users/me');

    expect((await store.read())?.refreshToken, 'r2');
  });

  test('a failed renewal surfaces the 401 and ends the session', () async {
    final store = FakePersistentStore();
    final session = await signedInSession(
      store: store,
      repository: FakeLoginRepository(
        failure: const Failure(errorCode: 'REFRESH_TOKEN_REUSED'),
      ),
    );
    final adapter = ExpiringAdapter();
    final dio = buildDio(session, adapter);

    await expectLater(
      dio.get('/api/v1/users/me'),
      throwsA(
        isA<DioException>().having(
          (e) => e.response?.statusCode,
          'statusCode',
          401,
        ),
      ),
    );
    expect(adapter.calls, 1, reason: 'no replay without a new token');
    expect(session.isAuthenticated, isFalse);
    expect(store.blob, isNull);
  });

  test('a request that 401s twice is not retried forever', () async {
    final session = await signedInSession(
      store: FakePersistentStore(),
      repository: FakeLoginRepository(
        responses: [testTokens(refreshToken: 'r2')],
      ),
    );
    // Every call 401s, so even the replay fails.
    final adapter = ExpiringAdapter(failuresBeforeSuccess: 99);
    final dio = buildDio(session, adapter);

    await expectLater(dio.get('/api/v1/users/me'), throwsA(isA<DioException>()));
    expect(adapter.calls, 2, reason: 'original + one replay, then give up');
  });

  test('the refresh endpoint itself is never retried', () async {
    final session = await signedInSession(
      store: FakePersistentStore(),
      repository: FakeLoginRepository(
        responses: [testTokens(refreshToken: 'r2')],
      ),
    );
    final adapter = ExpiringAdapter(failuresBeforeSuccess: 99);
    final dio = buildDio(session, adapter);

    await expectLater(
      dio.post('/api/v1/auth/token/refresh'),
      throwsA(isA<DioException>()),
    );
    expect(adapter.calls, 1, reason: 'refreshing a refresh would loop');
  });

  test('parallel 401s share a single refresh', () async {
    final repository = FakeLoginRepository(
      responses: [testTokens(accessToken: 'fresh-access', refreshToken: 'r2')],
    );
    final session = await signedInSession(
      store: FakePersistentStore(),
      repository: repository,
    );
    final adapter = ExpiringAdapter();
    final dio = buildDio(session, adapter);

    await Future.wait([
      dio.get('/api/v1/users/me'),
      dio.get('/api/v1/posts'),
    ]);

    // Two refreshes would present the same token twice and, on the real
    // backend, end the session for reuse.
    expect(repository.refreshCalls.length, 1);
  });
}
