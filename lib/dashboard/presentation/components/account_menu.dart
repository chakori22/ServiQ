// dartz exports a State class of its own, which would shadow Flutter's.
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_color.dart';
import '../../../core/app_routes.dart';
import '../../../network/auth_session.dart';
import '../../../network/failure.dart';
import '../../../onboarding/repository/onboarding_repository.dart';

/// The person icon in the header, which opens the account menu.
///
/// Signing out is the only entry today, but it is a menu rather than a bare
/// button so profile and settings have somewhere to land without moving the
/// affordance users will have learned.
class AccountMenuButton extends StatefulWidget {
  const AccountMenuButton({super.key});

  @override
  State<AccountMenuButton> createState() => _AccountMenuButtonState();
}

class _AccountMenuButtonState extends State<AccountMenuButton> {
  Future<void> _signOut() async {
    // Captured before the dialog: the widget can be disposed by the navigation
    // this triggers, and reading providers off a dead context would throw.
    final session = context.read<AuthSession>();
    final onboarding = context.read<OnboardingRepository>();
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);

    // The dialog runs the sign-out itself and shows its own progress, so the
    // waiting is where the user is looking — on the button they just pressed —
    // rather than back on the header icon.
    final result = await showDialog<Either<Failure, Unit>>(
      context: context,
      // Dismissing by tapping outside mid-request would leave the request in
      // flight with nothing reporting it.
      barrierDismissible: false,
      builder: (_) => _LogoutConfirmationDialog(
        onConfirm: () async {
          final outcome = await session.signOut();
          // The stored profile is device-local and not keyed by user, so
          // leaving it behind would hand the next person to sign in on this
          // device someone else's categories and locality.
          await onboarding.clear();
          return outcome;
        },
      ),
    );

    // Null means the dialog was cancelled: nothing happened, nowhere to go.
    if (result == null || !mounted) return;

    // The session is gone locally either way, so the user is signed out and
    // goes to the login screen; a failed call only changes what we tell them.
    result.leftMap((failure) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Signed out on this device, but the server could not be '
              'reached (${failure.errorMessage}).',
            ),
          ),
        );
    });

    router.goAppRoute(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_AccountAction>(
      tooltip: 'Account',
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColor.white,
      icon: const Icon(
        Icons.person_outline_rounded,
        size: 24,
        color: AppColor.white,
      ),
      onSelected: (action) {
        switch (action) {
          case _AccountAction.logout:
            _signOut();
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: _AccountAction.logout,
          child: Row(
            children: [
              Icon(Icons.logout_rounded, size: 18, color: AppColor.authError),
              SizedBox(width: 10),
              Text(
                'Log out',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColor.authError,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Asks before signing out, and owns the wait.
///
/// It runs [onConfirm] itself and swaps its own action for a spinner while
/// that is in flight, then pops with the result. Keeping the progress here
/// means the feedback appears on the control the user just pressed.
class _LogoutConfirmationDialog extends StatefulWidget {
  const _LogoutConfirmationDialog({required this.onConfirm});

  final Future<Either<Failure, Unit>> Function() onConfirm;

  @override
  State<_LogoutConfirmationDialog> createState() =>
      _LogoutConfirmationDialogState();
}

class _LogoutConfirmationDialogState extends State<_LogoutConfirmationDialog> {
  bool _isSigningOut = false;

  Future<void> _confirm() async {
    if (_isSigningOut) return;
    setState(() => _isSigningOut = true);

    final result = await widget.onConfirm();

    if (!mounted) return;
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Back must not tear the dialog away while the request is running.
      canPop: !_isSigningOut,
      child: AlertDialog(
        title: const Text('Log out?'),
        content: const Text('Are you sure you want to logout? '),
        actions: [
          TextButton(
            onPressed: _isSigningOut ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: _isSigningOut ? null : _confirm,
            child: _isSigningOut
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColor.authError,
                    ),
                  )
                : const Text(
                    'Log out',
                    style: TextStyle(
                      color: AppColor.authError,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

enum _AccountAction { logout }
