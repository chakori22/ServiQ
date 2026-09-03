import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../network/failure.dart';
import '../model/seeker_profile.dart';

/// Stores what onboarding collects.
///
/// There is no profile endpoint on the backend yet, so the completed profile
/// is kept on the device and read back on the next launch. That keeps the
/// flow from asking a returning user the same four questions again, and means
/// [SeekerProfile.encode] is the single serialisation both sides share — when
/// the endpoint lands, the same JSON becomes the request body and only
/// [saveProfile] changes.
class OnboardingRepository {
  static const _key = 'serviq.onboarding.seekerProfile';

  final FlutterSecureStorage storage;

  OnboardingRepository({FlutterSecureStorage? storage})
    : storage =
          storage ??
          // Must match SecureTokenStore's options exactly. The Android plugin
          // keys both modes off the same FlutterSecureStorage preferences
          // file, so a store opened with the default options cannot read back
          // what this app's encrypted-mode store wrote — the profile silently
          // read as null on the next launch and onboarding ran a second time.
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock_this_device,
            ),
          );

  /// Persists [profile] and reports whether onboarding may move on.
  ///
  /// TODO(api): POST to the profile endpoint once it exists and treat the
  /// server's copy as authoritative; the local write then becomes a cache.
  Future<Either<Failure, Unit>> saveProfile(SeekerProfile profile) async {
    try {
      await storage.write(key: _key, value: profile.encode());
      return const Right(unit);
    } catch (e) {
      return const Left(
        Failure(
          errorMessage: 'Could not save your details. Please try again.',
          errorCode: 'PROFILE_WRITE_FAILED',
        ),
      );
    }
  }

  /// The stored profile, or null when onboarding has never been completed.
  ///
  /// A corrupt blob reads as null rather than throwing, so a bad write sends
  /// the user through onboarding again instead of wedging the launch.
  Future<SeekerProfile?> readProfile() async {
    try {
      final raw = await storage.read(key: _key);
      if (raw == null || raw.isEmpty) return null;
      return SeekerProfile.decode(raw);
    } catch (_) {
      return null;
    }
  }

  /// Clears the profile. Called on sign-out, alongside the token store.
  Future<void> clear() => storage.delete(key: _key);
}
