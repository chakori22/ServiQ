import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Prints every request and response in full.
///
/// Guarded by [kDebugMode] so it is compiled out of release builds — the
/// bodies here include access and refresh tokens verbatim, which must never
/// reach a shipped app's logs.
class LoggingInterceptor extends Interceptor {
  static const _tag = 'ServiQ-API';

  static final _encoder = JsonEncoder.withIndent('  ');

  String _pretty(Object? body) {
    if (body == null) return '(no body)';
    try {
      return _encoder.convert(body is String ? jsonDecode(body) : body);
    } catch (_) {
      return body.toString();
    }
  }

  /// debugPrint rather than dart:developer's log: only stdout reaches
  /// `adb logcat`, which is where these are actually read from.
  void _log(String message) {
    for (final line in message.split('\n')) {
      debugPrint('$_tag $line');
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      _log(
        '\n──────── REQUEST ────────\n'
        '${options.method} ${options.uri}\n'
        'headers: ${_pretty(options.headers)}\n'
        'body: ${_pretty(options.data)}\n'
        '─────────────────────────',
      );
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      _log(
        '\n──────── RESPONSE ────────\n'
        '${response.statusCode} ${response.requestOptions.method} '
        '${response.requestOptions.uri}\n'
        'body: ${_pretty(response.data)}\n'
        '──────────────────────────',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      // Non-2xx lands here, and the server still sends its envelope in the
      // body — so this is where error responses are actually readable.
      _log(
        '\n──────── ERROR ────────\n'
        '${err.response?.statusCode ?? err.type.name} '
        '${err.requestOptions.method} ${err.requestOptions.uri}\n'
        'body: ${_pretty(err.response?.data)}\n'
        '───────────────────────',
      );
    }
    handler.next(err);
  }
}
