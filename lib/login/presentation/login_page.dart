import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/components/primary_button.dart';
import 'package:local_markerplace/core/device_identity.dart';
import 'package:local_markerplace/network/auth_session.dart';

import '../bloc/login_bloc.dart';
import '../repository/login_repository.dart';
import 'components/auth_chrome.dart';
import 'components/phone_number_field.dart';
import 'otp_verification.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(
        loginRepository: context.read<LoginRepository>(),
        authSession: context.read<AuthSession>(),
        deviceIdentity: context.read<DeviceIdentity>(),
      ),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    // Read here, above the Scaffold, so this is the true inset whatever the
    // Scaffold does with it.
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColor.authBackgroundTop,
      // The body keeps the full screen height and the sheet is placed over it,
      // so the keyboard never resizes or reflows the brand behind — it is
      // simply covered, the way a bottom sheet covers what it sits on.
      resizeToAvoidBottomInset: false,
      body: MultiBlocListener(
        listeners: [
          BlocListener<LoginBloc, LoginState>(
            listenWhen: (previous, current) =>
                current.errorMessage != null &&
                previous.errorMessage != current.errorMessage,
            listener: (context, state) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            },
          ),
          BlocListener<LoginBloc, LoginState>(
            listenWhen: (previous, current) =>
                !previous.isOtpSent && current.isOtpSent,
            listener: (context, state) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<LoginBloc>(),
                    child: const OtpVerificationPage(),
                  ),
                ),
              );
            },
          ),
        ],
        child: AuthBackground(
          child: Stack(
            children: [
              const Positioned.fill(child: _BrandHeader()),
              // Rides on top of the keyboard, overlapping the brand rather
              // than squeezing it.
              Positioned(
                left: 0,
                right: 0,
                bottom: bottomInset,
                child: const _MobileLoginSheet(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The brand behind the form.
///
/// Laid out against the full screen height and never resized: when the
/// keyboard raises the sheet, the sheet simply covers more of this. Nothing
/// here scales or reflows, so the mark and wordmark are always at the size
/// they were drawn at.
class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      bottom: false,
      // Sits in the upper third rather than the middle, which is where the
      // gap above the resting sheet actually is.
      child: Align(
        alignment: Alignment(0, -0.38),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ServiqLogoMark(),
            SizedBox(height: 20),
            ServiqWordmark(),
            SizedBox(height: 10),
            ServiqTagline(),
          ],
        ),
      ),
    );
  }
}

class _MobileLoginSheet extends StatefulWidget {
  const _MobileLoginSheet();

  @override
  State<_MobileLoginSheet> createState() => _MobileLoginSheetState();
}

class _MobileLoginSheetState extends State<_MobileLoginSheet> {
  final _mobileController = TextEditingController();

  void _showPlaceholder(String label) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(label)));
  }

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        final hasNumber = state.mobileNumber.isNotEmpty;
        return AuthSheet(
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Log in with your number',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: AppColor.authTextPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Enter your mobile number to get started',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColor.authTextSecondary,
                  ),
                ),
                const SizedBox(height: 18),
                PhoneNumberField(
                  controller: _mobileController,
                  countryCode: state.countryCode,
                  onCountryChanged: (code) {
                    context.read<LoginBloc>().add(CountryCodeChanged(code));
                  },
                  onChanged: (value) {
                    context.read<LoginBloc>().add(MobileNumberChanged(value));
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 15,
                      color: AppColor.authTextSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      hasNumber
                          ? "We'll send a 6-digit code to this number"
                          : "We'll send a 6-digit verification code",
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColor.authTextSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                PrimaryButton(
                  label: 'Continue',
                  enabled: state.isMobileNumberValid,
                  isLoading: state.isLoading,
                  gradient: true,
                  trailingIcon: state.isMobileNumberValid
                      ? Icons.arrow_forward
                      : null,
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    context.read<LoginBloc>().add(const LoginSubmitted());
                  },
                ),
                const SizedBox(height: 16),
                AuthLegalFootnote(
                  onTerms: () => _showPlaceholder('Terms & Conditions'),
                  onPrivacy: () => _showPlaceholder('Privacy Policy'),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        );
      },
    );
  }
}
