import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Supplies the stable `deviceId` the auth endpoints expect.
///
/// Generated once on first launch and kept from then on. It has to persist:
/// verification binds a session to the device that opened it, so an id that
/// changed each launch would register every run as a new device — and the
/// refresh endpoint takes the same id, so it must still match months later.
class DeviceIdentity {
  static const _key = 'serviq.device.id';

  final FlutterSecureStorage storage;

  DeviceIdentity({FlutterSecureStorage? storage})
    : storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock_this_device,
            ),
          );

  String? _deviceId;

  /// Available only after [load]. Reading it earlier is a wiring mistake
  /// rather than something to paper over with a throwaway id, which would
  /// silently unbind the session.
  String get deviceId {
    final id = _deviceId;
    if (id == null) {
      throw StateError('DeviceIdentity.load() must run before deviceId');
    }
    return id;
  }

  /// Reads the stored id, generating and saving one on first launch.
  Future<String> load() async {
    if (_deviceId != null) return _deviceId!;
    try {
      final existing = await storage.read(key: _key);
      if (existing != null && existing.isNotEmpty) {
        return _deviceId = existing;
      }
    } catch (_) {
      // Keystore can throw after an OS restore. Falling through mints a new
      // id, which is the same position a fresh install is in.
    }
    final generated = _generate();
    try {
      await storage.write(key: _key, value: generated);
    } catch (_) {
      // Unwritable storage means the id lasts only this run; the app still
      // works, it just looks like a new device next launch.
    }
    return _deviceId = generated;
  }

  static final _random = Random.secure();

  static String _generate() {
    const alphabet = '0123456789abcdef';
    return List.generate(
      32,
      (_) => alphabet[_random.nextInt(alphabet.length)],
    ).join();
  }
}
