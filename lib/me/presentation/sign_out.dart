// dartz exports a State class of its own, which would shadow Flutter's.
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/core/app_routes.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/network/auth_session.dart';
import 'package:local_markerplace/network/failure.dart';
import 'package:local_markerplace/onboarding/repository/onboarding_repository.dart';

/// Confirms, then ends the session and returns to sign-in.
///
/// Signing out posts the device's refresh token to `/api/v1/auth/logout`,
/// which revokes that one credential; the access token in the header is
/// incidental and may already have expired. The local session is cleared
/// either way, so a server that cannot be reached still leaves the seeker
/// signed out here.
///
/// [everywhere] sends the same credential to `/api/v1/auth/logout-all`
/// instead, which retires every session the account has and reports how many
/// there were — so the seeker is told what actually happened rather than a
/// flat "signed out".
Future<void> confirmSignOut(
  BuildContext context, {
  required bool everywhere,
}) async {
  // Captured before the dialog: the navigation this triggers can dispose the
  // caller, and reading providers off a dead context would throw.
  final session = context.read<AuthSession>();
  final onboarding = context.read<OnboardingRepository>();
  final router = GoRouter.of(context);
  final messenger = ScaffoldMessenger.of(context);

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColor.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        everywhere ? 'Sign out everywhere?' : 'Sign out?',
        style: DiscoveryText.sheetTitle,
      ),
      content: Text(
        everywhere
            ? 'You will be signed out on every device you have used ServiQ '
                  'on, including this one.'
            : 'You will need your number and a code to sign back in.',
        style: DiscoveryText.publicNote,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text('Cancel', style: DiscoveryText.link),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text('Sign out', style: DiscoveryText.danger),
        ),
      ],
    ),
  );

  if (confirmed != true) return;

  // Both calls answer with something different on success — a bare unit for
  // one device, a session count for all of them — so they are folded into the
  // one message the seeker sees here.
  final Either<Failure, String?> outcome = everywhere
      ? (await session.signOutEverywhere()).map(_revokedMessage)
      : (await session.signOut()).map((_) => null);

  // The stored profile is device-local and not keyed by user, so leaving it
  // behind would hand the next person to sign in someone else's area and
  // categories.
  await onboarding.clear();

  // The session is gone locally either way, so the seeker is signed out and
  // goes to sign-in; a failed call only changes what we tell them.
  outcome.fold(
    (failure) => messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Signed out on this device, but the server could not be reached '
            '(${failure.errorMessage}).',
          ),
        ),
      ),
    (message) {
      if (message == null) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    },
  );

  router.goAppRoute(AppRoutes.login);
}

/// Phrases the session count the all-devices endpoint returns.
///
/// The server counts the session being used to make the call, so one is the
/// ordinary case for someone signed in on a single phone — saying "1 session"
/// there would read as though something had been missed.
String _revokedMessage(int revokedSessions) {
  if (revokedSessions <= 1) return 'Signed out of all devices.';
  return 'Signed out of all devices — $revokedSessions sessions ended.';
}
