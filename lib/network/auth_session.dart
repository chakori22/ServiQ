import 'dart:async';

import 'package:dio/dio.dart';

import '../core/device_identity.dart';
import '../login/model/auth_tokens.dart';
import '../login/model/auth_user.dart';
import '../login/repository/login_repository.dart';
import 'token_store.dart';

/// Outcome of the launch-time bootstrap, which decides the first screen.
enum AuthBootstrapResult {
  /// No refresh token was stored — a first launch, or after signing out.
  noSession,

  /// A stored token was exchanged for a live one; go straight to the dashboard.
  signedIn,

  /// The stored token was rejected. It has been cleared; show the login screen.
  rejected,

  /// The server could not be reached. The token is untouched, so a later
  /// launch with a working connection signs the user back in.
  offline,
}

/// Error codes that mean the transport failed rather than the credential
/// being refused. Clearing a refresh token on one of these would sign a user
/// out for good because of a moment without signal.
const _transportErrorCodes = {'TIMEOUT', 'CONNECTION_ERROR', 'NETWORK_ERROR'};

/// The app's single source of truth for who is signed in.
///
/// Holds the access token in memory only and persists the refresh token, so a
/// returning user is signed back in by refreshing rather than by restoring a
/// stale access token.
class AuthSession {
  final TokenStore store;
  final LoginRepository repository;
  final DeviceIdentity deviceIdentity;

  AuthSession({
    required this.store,
    required this.repository,
    required this.deviceIdentity,
  });

  AuthTokens? _tokens;
  AuthUser? _user;

  /// Guards against two refreshes running at once. The backend ends the
  /// session if a refresh token is presented twice, so a concurrent pair would
  /// sign the user out rather than merely racing.
  Future<bool>? _inFlightRefresh;

  AuthTokens? get tokens => _tokens;
  AuthUser? get user => _user;

  bool get isAuthenticated => _tokens != null;

  bool get needsRefresh => _tokens?.isAccessTokenExpired ?? false;

  /// Runs the launch lifecycle: read the stored refresh token, and if there is
  /// one, exchange it for a live session before the first route is chosen.
  Future<AuthBootstrapResult> bootstrap() async {
    final stored = await store.read();
    if (stored == null) return AuthBootstrapResult.noSession;

    _user = stored.user;
    if (await _refresh(stored.refreshToken)) {
      return AuthBootstrapResult.signedIn;
    }
    // A token that survived the attempt was never rejected — the network was
    // simply unavailable.
    return _lastRefreshWasTransportFailure
        ? AuthBootstrapResult.offline
        : AuthBootstrapResult.rejected;
  }

  bool _lastRefreshWasTransportFailure = false;

  /// Renews the access token, reusing an in-flight attempt if one is already
  /// running. Returns false when the session is gone, in which case it has
  /// already been cleared.
  Future<bool> refreshIfNeeded() {
    final existing = _inFlightRefresh;
    if (existing != null) return existing;

    final refreshToken = _tokens?.refreshToken;
    if (refreshToken == null) return Future.value(false);
    return _refresh(refreshToken);
  }

  Future<bool> _refresh(String refreshToken) {
    final existing = _inFlightRefresh;
    if (existing != null) return existing;

    final attempt = _performRefresh(refreshToken);
    _inFlightRefresh = attempt;
    // Cleared however the attempt ends, so a failure cannot leave every later
    // refresh waiting on a dead future.
    return attempt.whenComplete(() => _inFlightRefresh = null);
  }

  Future<bool> _performRefresh(String refreshToken) async {
    final result = await repository.refreshTokens(
      refreshToken: refreshToken,
      deviceId: deviceIdentity.deviceId,
    );

    return result.fold(
      (failure) async {
        final isTransport = _transportErrorCodes.contains(failure.errorCode);
        _lastRefreshWasTransportFailure = isTransport;
        // Only a genuine rejection retires the credential. Wiping it because
        // the network was down would turn a moment without signal into a
        // permanent sign-out.
        if (!isTransport) await clear();
        return false;
      },
      (tokens) async {
        _lastRefreshWasTransportFailure = false;
        _tokens = tokens;
        // The server has already rotated the token, so the old one is spent.
        // Persist the replacement before anything can use it — a crash between
        // these two lines would otherwise leave a token on disk that the next
        // launch would be locked out by.
        await store.write(
          StoredCredentials(refreshToken: tokens.refreshToken, user: _user),
        );
        return true;
      },
    );
  }

  /// Called after OTP verification, the one point where a user arrives too.
  Future<void> save({
    required AuthTokens tokens,
    required AuthUser user,
  }) async {
    _tokens = tokens;
    _user = user;
    await store.write(
      StoredCredentials(refreshToken: tokens.refreshToken, user: user),
    );
  }

  Future<void> clear() async {
    _tokens = null;
    _user = null;
    await store.clear();
  }
}

/// Attaches the bearer token to every outgoing request once the user is signed
/// in. Requests made before verification simply go out unauthenticated, which
/// is what the OTP endpoints themselves need.
class AuthInterceptor extends Interceptor {
  final AuthSession session;

  AuthInterceptor(this.session);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final tokens = session.tokens;
    if (tokens != null && tokens.accessToken.isNotEmpty) {
      options.headers['Authorization'] = tokens.authorizationHeader;
    }
    handler.next(options);
  }
}
