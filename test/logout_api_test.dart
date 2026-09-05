import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:local_markerplace/login/repository/login_repository.dart';
import 'package:local_markerplace/network/api_client.dart';

/// Answers with whatever body the test hands it, recording what was asked.
class _LogoutAdapter implements HttpClientAdapter {
  _LogoutAdapter({required this.body, this.statusCode = 200});

  final Map<String, dynamic> body;
  final int statusCode;

  String? path;
  Map<String, dynamic>? requestBody;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    path = options.path;
    requestBody = options.data as Map<String, dynamic>?;

    if (statusCode >= 400) {
      throw DioException.badResponse(
        statusCode: statusCode,
        requestOptions: options,
        response: Response(
          requestOptions: options,
          statusCode: statusCode,
          data: body,
        ),
      );
    }

    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

LoginRepository _repositoryWith(_LogoutAdapter adapter) {
  final client = APIClient(baseUrl: 'http://example.invalid');
  // APIClient caches one Dio; swapping the adapter is the seam a test has.
  client.dio = Dio(BaseOptions(baseUrl: 'http://example.invalid'))
    ..httpClientAdapter = adapter;
  return LoginRepository(apiClient: client);
}

void main() {
  const refreshToken = 'JbFzzXQSBBd6x8fxF8Qq_Yi0FJYkM9YcK-ajwk1mqhA';

  test(
    'logout posts the refresh token and reads the success envelope',
    () async {
      // The exact body the endpoint returns.
      final adapter = _LogoutAdapter(
        body: {
          'responseCode': '200 OK',
          'errorCode': null,
          'responseMessage': 'Logged out successfully',
          'responseTime': '2026-09-03T14:29:51.191976095Z',
          'responseData': null,
        },
      );

      final result = await _repositoryWith(
        adapter,
      ).logout(refreshToken: refreshToken);

      expect(result.isRight(), isTrue);
      expect(adapter.path, '/api/v1/auth/logout');
      // The refresh token is the credential being revoked, and it is the whole
      // body — the access token rides in the header and may already have
      // expired.
      expect(adapter.requestBody, {'refreshToken': refreshToken});
    },
  );

  test('a null responseData is a success, not a parse failure', () async {
    // Logout returns no payload at all, so success has to be read from the
    // absence of an error code rather than from any data.
    final adapter = _LogoutAdapter(
      body: {
        'responseCode': '200 OK',
        'errorCode': null,
        'responseMessage': 'Logged out successfully',
        'responseTime': '2026-09-03T14:29:51.191976095Z',
        'responseData': null,
      },
    );

    final result = await _repositoryWith(
      adapter,
    ).logout(refreshToken: refreshToken);

    result.fold(
      (failure) => fail('expected success, got ${failure.errorMessage}'),
      (_) {},
    );
  });

  test('an error code in a 200 envelope is still a failure', () async {
    final adapter = _LogoutAdapter(
      body: {
        'responseCode': '200 OK',
        'errorCode': 'INVALID_REFRESH_TOKEN',
        'responseMessage': 'Refresh token is not valid',
        'responseTime': '2026-09-03T14:29:51.191976095Z',
        'responseData': null,
      },
    );

    final result = await _repositoryWith(
      adapter,
    ).logout(refreshToken: refreshToken);

    result.fold((failure) {
      expect(failure.errorCode, 'INVALID_REFRESH_TOKEN');
      expect(failure.errorMessage, 'Refresh token is not valid');
    }, (_) => fail('expected a failure'));
  });

  test('logout-all posts the same credential to its own endpoint', () async {
    // The exact body the endpoint returns.
    final adapter = _LogoutAdapter(
      body: {
        'responseCode': '200 OK',
        'errorCode': null,
        'responseMessage': 'Signed out of all devices',
        'responseTime': '2026-09-05T17:53:10.632856675Z',
        'responseData': {'revokedSessions': 1},
      },
    );

    final result = await _repositoryWith(
      adapter,
    ).logoutAll(refreshToken: refreshToken);

    expect(adapter.path, '/api/v1/auth/logout-all');
    expect(adapter.requestBody, {'refreshToken': refreshToken});
    expect(result.getOrElse(() => -1), 1);
  });

  test('logout-all reports how many sessions were retired', () async {
    final adapter = _LogoutAdapter(
      body: {
        'responseCode': '200 OK',
        'errorCode': null,
        'responseMessage': 'Signed out of all devices',
        'responseData': {'revokedSessions': 4},
      },
    );

    final result = await _repositoryWith(
      adapter,
    ).logoutAll(refreshToken: refreshToken);

    expect(result.getOrElse(() => -1), 4);
  });

  test('a missing session count is zero, not a failure', () async {
    // The sessions are gone either way; the number only exists to be shown.
    final adapter = _LogoutAdapter(
      body: {
        'responseCode': '200 OK',
        'errorCode': null,
        'responseMessage': 'Signed out of all devices',
        'responseData': null,
      },
    );

    final result = await _repositoryWith(
      adapter,
    ).logoutAll(refreshToken: refreshToken);

    expect(result.isRight(), isTrue);
    expect(result.getOrElse(() => -1), 0);
  });

  test('a rejected logout-all is a failure, not an empty count', () async {
    final adapter = _LogoutAdapter(
      statusCode: 401,
      body: {
        'responseCode': '401 UNAUTHORIZED',
        'errorCode': 'TOKEN_EXPIRED',
        'responseMessage': 'Refresh token has expired',
        'responseData': null,
      },
    );

    final result = await _repositoryWith(
      adapter,
    ).logoutAll(refreshToken: refreshToken);

    result.fold(
      (failure) => expect(failure.errorCode, 'TOKEN_EXPIRED'),
      (_) => fail('expected a failure'),
    );
  });

  test('a rejected logout reports the server’s own message', () async {
    final adapter = _LogoutAdapter(
      statusCode: 401,
      body: {
        'responseCode': '401 UNAUTHORIZED',
        'errorCode': 'TOKEN_EXPIRED',
        'responseMessage': 'Refresh token has expired',
        'responseData': null,
      },
    );

    final result = await _repositoryWith(
      adapter,
    ).logout(refreshToken: refreshToken);

    result.fold((failure) {
      expect(failure.errorCode, 'TOKEN_EXPIRED');
      expect(failure.errorMessage, 'Refresh token has expired');
    }, (_) => fail('expected a failure'));
  });
}
