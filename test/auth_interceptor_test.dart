import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_markerplace/login/model/auth_tokens.dart';
import 'package:local_markerplace/network/auth_session.dart';
import 'package:local_markerplace/network/token_store.dart';

import 'support/fakes.dart';

/// Captures the headers of whatever request is sent, and answers with an empty
/// success so nothing leaves the machine.
class CapturingAdapter implements HttpClientAdapter {
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return ResponseBody.fromString(jsonEncode({}), 200, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late Dio dio;
  late CapturingAdapter adapter;
  late AuthSession session;

  setUp(() {
    session = AuthSession(
      store: InMemoryTokenStore(),
      repository: FakeLoginRepository(),
      deviceIdentity: FakeDeviceIdentity(),
    );
    adapter = CapturingAdapter();
    dio = Dio(BaseOptions(baseUrl: 'http://example.invalid'))
      ..httpClientAdapter = adapter
      ..interceptors.add(AuthInterceptor(session));
  });

  test('requests go out unauthenticated before sign-in', () async {
    await dio.get('/api/v1/posts');

    expect(adapter.lastRequest!.headers.containsKey('Authorization'), isFalse);
  });

  test('every request carries the bearer token after sign-in', () async {
    await session.save(
      tokens: AuthTokens(
        accessToken: 'eyJhbGciOiJSUzI1NiJ9.payload.signature',
        tokenType: 'Bearer',
        expiresIn: 900,
        refreshToken: 'refresh-token',
        refreshExpiresIn: 7776000,
      ),
      user: testUser,
    );

    await dio.get('/api/v1/posts');

    expect(
      adapter.lastRequest!.headers['Authorization'],
      'Bearer eyJhbGciOiJSUzI1NiJ9.payload.signature',
    );
  });

  test('signing out stops the token being sent', () async {
    await session.save(
      tokens: AuthTokens(
        accessToken: 'access-token',
        tokenType: 'Bearer',
        expiresIn: 900,
        refreshToken: 'refresh-token',
        refreshExpiresIn: 7776000,
      ),
      user: testUser,
    );
    await session.clear();

    await dio.get('/api/v1/posts');

    expect(adapter.lastRequest!.headers.containsKey('Authorization'), isFalse);
  });
}
