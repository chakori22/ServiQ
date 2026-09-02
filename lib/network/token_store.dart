import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../login/model/auth_user.dart';

/// What survives an app restart.
///
/// Deliberately does **not** include the access token. That token lives for 15
/// minutes and is held in memory only; every launch re-obtains one by
/// refreshing. The refresh token is the sole persisted credential.
class StoredCredentials {
  final String refreshToken;

  /// Not a credential — kept alongside so a restored session knows who it
  /// belongs to, since the refresh endpoint returns tokens but no user.
  final AuthUser? user;

  const StoredCredentials({required this.refreshToken, this.user});

  String encode() =>
      jsonEncode({'refreshToken': refreshToken, 'user': user?.toJson()});

  static StoredCredentials? decode(String raw) {
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final refreshToken = json['refreshToken'] as String?;
      if (refreshToken == null || refreshToken.isEmpty) return null;
      final userJson = json['user'];
      return StoredCredentials(
        refreshToken: refreshToken,
        user: userJson is Map<String, dynamic>
            ? AuthUser.fromJson(userJson)
            : null,
      );
    } catch (_) {
      // A corrupt blob is treated as no session, so a bad write can never
      // wedge the user out of the app permanently.
      return null;
    }
  }
}

abstract class TokenStore {
  Future<StoredCredentials?> read();
  Future<void> write(StoredCredentials credentials);
  Future<void> clear();
}

/// Keychain on iOS, EncryptedSharedPreferences on Android.
///
/// The refresh token is good for 90 days, so it is exactly the kind of
/// long-lived credential that must not sit in plaintext on disk.
class SecureTokenStore implements TokenStore {
  static const _key = 'serviq.auth.credentials';

  final FlutterSecureStorage storage;

  SecureTokenStore({FlutterSecureStorage? storage})
    : storage =
          storage ??
          const FlutterSecureStorage(
            // Without this the Android plugin falls back to plain
            // SharedPreferences, which would leave a 90-day credential in the
            // clear. first_unlock_this_device keeps the iOS copy out of
            // backups while surviving a reboot.
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock_this_device,
            ),
          );

  @override
  Future<StoredCredentials?> read() async {
    try {
      final raw = await storage.read(key: _key);
      return raw == null ? null : StoredCredentials.decode(raw);
    } catch (_) {
      // Keystore can throw after an OS restore or a key rotation. Failing to
      // read is not worse than having no session, so fall back to login.
      return null;
    }
  }

  @override
  Future<void> write(StoredCredentials credentials) =>
      storage.write(key: _key, value: credentials.encode());

  @override
  Future<void> clear() => storage.delete(key: _key);
}

/// Non-persisting store for tests and for anywhere a session deliberately
/// should not outlive the process.
class InMemoryTokenStore implements TokenStore {
  StoredCredentials? _credentials;

  @override
  Future<StoredCredentials?> read() async => _credentials;

  @override
  Future<void> write(StoredCredentials credentials) async =>
      _credentials = credentials;

  @override
  Future<void> clear() async => _credentials = null;
}
