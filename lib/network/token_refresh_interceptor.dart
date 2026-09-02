import 'package:dio/dio.dart';

import 'auth_session.dart';

/// Renews an expired access token and replays the request that hit the 401.
///
/// The access token lives 15 minutes while the session lives 90 days, so a
/// long-running app will meet expiry mid-session. Without this, that request
/// simply fails and the user appears signed out despite holding a good
/// refresh token.
class TokenRefreshInterceptor extends Interceptor {
  final AuthSession session;

  /// Used to replay the original request. This is the same Dio the failed
  /// request came from, so it carries the auth interceptor that will attach
  /// the newly minted token.
  final Dio dio;

  TokenRefreshInterceptor({required this.session, required this.dio});

  /// Endpoints that must never trigger a refresh-and-retry: they are how a
  /// session is obtained in the first place, and retrying /token/refresh on
  /// its own 401 would loop.
  static const _authPaths = {
    '/api/v1/auth/otp/request',
    '/api/v1/auth/otp/verify',
    '/api/v1/auth/token/refresh',
  };

  /// Marks a request that has already been replayed, so a second 401 is
  /// reported instead of retried forever.
  static const _retriedFlag = 'tokenRefreshRetried';

  bool _shouldAttempt(DioException err) {
    if (err.response?.statusCode != 401) return false;
    final options = err.requestOptions;
    if (options.extra[_retriedFlag] == true) return false;
    if (_authPaths.contains(options.path)) return false;
    return session.isAuthenticated;
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_shouldAttempt(err)) return handler.next(err);

    // Single-flight inside AuthSession: several requests failing at once share
    // one refresh, which matters because presenting the refresh token twice
    // would end the session for reuse.
    final refreshed = await session.refreshIfNeeded();
    if (!refreshed) return handler.next(err);

    final options = err.requestOptions;
    options.extra = {...options.extra, _retriedFlag: true};
    // Drop the stale header so the auth interceptor writes the fresh one.
    options.headers.remove('Authorization');

    try {
      final response = await dio.fetch(options);
      return handler.resolve(response);
    } on DioException catch (retryError) {
      return handler.next(retryError);
    }
  }
}
