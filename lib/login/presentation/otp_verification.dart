import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:local_markerplace/core/app_routes.dart';

import '../../core/app_color.dart';
import '../../core/app_config.dart';
import '../../components/otp_input.dart';
import '../../components/primary_button.dart';
import '../bloc/login_bloc.dart';
import 'components/auth_chrome.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({super.key});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _otpController = TextEditingController();
  final _otpFieldKey = GlobalKey<OtpInputFieldState>();
  Timer? _timer;
  int _secondsLeft = 0;

  /// How the current code got into the field. Only a code that arrived in one
  /// go can honestly be reported as detected or pasted.
  OtpFieldStatus _entryStatus = OtpFieldStatus.awaitingSms;
  String? _entryLabel;
  int _previousLength = 0;

  /// Drops the backend's `devOtp` straight into the field so the flow can be
  /// driven without a real SMS. Does nothing unless the build allows it.
  void _autoPopulate(String? devOtp) {
    if (!AppConfig.shouldAutoPopulateOtp) return;
    if (devOtp == null || devOtp.length != 6) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _otpController.text = devOtp;
      _previousLength = devOtp.length;
      setState(() {
        _entryStatus = OtpFieldStatus.filled;
        _entryLabel = 'Code auto-filled (dev build)';
      });
      context.read<LoginBloc>().add(OtpChanged(devOtp));
    });
  }

  void _onCodeChanged(String value) {
    final jumped = value.length - _previousLength > 1;
    _previousLength = value.length;
    setState(() {
      if (value.isEmpty) {
        _entryStatus = OtpFieldStatus.awaitingSms;
        _entryLabel = null;
      } else if (jumped && value.length == 6) {
        // Autofill delivers all six digits at once; typing never does.
        _entryStatus = OtpFieldStatus.filled;
        _entryLabel = 'Code detected from SMS';
      } else {
        _entryStatus = OtpFieldStatus.none;
        _entryLabel = null;
      }
    });
    context.read<LoginBloc>().add(OtpChanged(value));
  }

  @override
  void initState() {
    super.initState();
    final state = context.read<LoginBloc>().state;
    // The cooldown comes from the request that got us here; the server owns
    // this number, so the screen never invents one of its own.
    _startCountdown(state.resendAfterSeconds);
    _autoPopulate(state.devOtp);
  }

  void _startCountdown(int seconds) {
    _timer?.cancel();
    setState(() => _secondsLeft = seconds);
    if (seconds <= 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  /// Fires the resend and lets the bloc drive the outcome. The countdown is
  /// only restarted once the server confirms a new OTP went out, so a rejected
  /// resend (429) leaves the existing timer running.
  void _resend() {
    _otpController.clear();
    _previousLength = 0;
    setState(() {
      _entryStatus = OtpFieldStatus.awaitingSms;
      _entryLabel = null;
    });
    context.read<LoginBloc>().add(const OtpResendRequested());
  }

  Future<void> _pasteCode() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final digits = (data?.text ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return;
    final code = digits.substring(0, digits.length.clamp(0, 6));
    _otpController.text = code;
    if (!mounted) return;
    _previousLength = code.length;
    setState(() {
      _entryStatus = code.length == 6
          ? OtpFieldStatus.filled
          : OtpFieldStatus.none;
      _entryLabel = code.length == 6 ? 'Code pasted' : null;
    });
    context.read<LoginBloc>().add(OtpChanged(code));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  String get _timerLabel =>
      '0:${_secondsLeft.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    // Read above the Scaffold, so this is the true inset whatever the Scaffold
    // does with it.
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColor.authBackgroundTop,
      // The body keeps the full screen height and the sheet is placed over it,
      // so the keyboard never resizes the header behind — it is simply
      // covered, the way a bottom sheet covers what it sits on.
      resizeToAvoidBottomInset: false,
      body: MultiBlocListener(
        listeners: [
          BlocListener<LoginBloc, LoginState>(
            listenWhen: (previous, current) =>
                !previous.isSuccess && current.isSuccess,
            listener: (context, state) {
              GoRouter.of(context).goAppRoute(AppRoutes.verified);
            },
          ),
          // A fresh OTP was issued — restart the cooldown with the window the
          // server just handed back.
          BlocListener<LoginBloc, LoginState>(
            listenWhen: (previous, current) =>
                current.lastOtpSentAt != null &&
                previous.lastOtpSentAt != current.lastOtpSentAt,
            listener: (context, state) {
              _startCountdown(state.resendAfterSeconds);
              _otpFieldKey.currentState?.requestFocus();
              // A resend issues a new code, so the old auto-filled one is
              // stale — replace it rather than leaving a dead code on screen.
              _autoPopulate(state.devOtp);
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(const SnackBar(content: Text('OTP resent')));
            },
          ),
          // Surfaces request failures, notably OTP_RESEND_TOO_SOON.
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
        ],
        child: AuthBackground(
          child: Stack(
            children: [
              const Positioned.fill(child: _VerifyHeader()),
              // Rides on top of the keyboard, overlapping the header rather
              // than squeezing it.
              Positioned(
                left: 0,
                right: 0,
                bottom: bottomInset,
                child: _OtpSheet(
                  controller: _otpController,
                  fieldKey: _otpFieldKey,
                  secondsLeft: _secondsLeft,
                  timerLabel: _timerLabel,
                  entryStatus: _entryStatus,
                  entryLabel: _entryLabel,
                  onCodeChanged: _onCodeChanged,
                  onResend: _resend,
                  onPaste: _pasteCode,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Everything behind the code entry.
///
/// Laid out against the full screen height and never resized: when the
/// keyboard raises the sheet, the sheet covers more of this. The back button
/// is anchored to the top so it stays reachable however far the sheet rises.
class _VerifyHeader extends StatelessWidget {
  const _VerifyHeader();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          Positioned(
            top: 8,
            left: 20,
            child: AuthBackButton(
              onTap: () => Navigator.of(context).maybePop(),
            ),
          ),
          Align(
            // Sits in the upper third rather than the middle, which is where
            // the gap above the resting sheet actually is.
            alignment: const Alignment(0, -0.42),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _MessageBadge(),
                  const SizedBox(height: 20),
                  const Text(
                    'Verify your number',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: AppColor.authTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "We've sent a 6-digit code to",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColor.authTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  BlocBuilder<LoginBloc, LoginState>(
                    builder: (context, state) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${state.countryCode} ${state.mobileNumber}',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColor.authLink,
                            ),
                          ),
                          const SizedBox(width: 10),
                          _ChangeChip(
                            onTap: () => Navigator.of(context).maybePop(),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The chat bubble with its dotted orbit, matching the design's header art.
class _MessageBadge extends StatelessWidget {
  const _MessageBadge();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(150, 150),
            painter: _DottedRingPainter(),
          ),
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColor.authAccent, AppColor.authAccentDeep],
              ),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: AppColor.authAccent.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.chat_bubble_rounded,
              color: AppColor.white,
              size: 36,
            ),
          ),
          Positioned(top: 4, child: _Dot(color: AppColor.authSuccessLight)),
          Positioned(
            bottom: 24,
            right: 22,
            child: _Dot(color: AppColor.authAccent),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _DottedRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColor.authFieldBorder
      ..style = PaintingStyle.fill;
    final radius = size.width / 2 - 4;
    final center = Offset(size.width / 2, size.height / 2);
    const dots = 54;
    for (var i = 0; i < dots; i++) {
      final angle = (i / dots) * 2 * math.pi;
      canvas.drawCircle(
        center + Offset(radius * math.cos(angle), radius * math.sin(angle)),
        1.1,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ChangeChip extends StatelessWidget {
  const _ChangeChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColor.indicativeBlueColor50,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit_outlined, size: 13, color: AppColor.authLink),
            SizedBox(width: 4),
            Text(
              'Change',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColor.authLink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OtpSheet extends StatelessWidget {
  const _OtpSheet({
    required this.controller,
    required this.fieldKey,
    required this.secondsLeft,
    required this.timerLabel,
    required this.entryStatus,
    required this.entryLabel,
    required this.onCodeChanged,
    required this.onResend,
    required this.onPaste,
  });

  final TextEditingController controller;
  final GlobalKey<OtpInputFieldState> fieldKey;
  final int secondsLeft;
  final String timerLabel;
  final OtpFieldStatus entryStatus;
  final String? entryLabel;
  final ValueChanged<String> onCodeChanged;
  final VoidCallback onResend;
  final VoidCallback onPaste;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return AuthSheet(
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Enter the 6-digit code',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColor.authTextPrimary,
                      ),
                    ),
                    _PasteChip(onTap: onPaste),
                  ],
                ),
                const SizedBox(height: 14),
                OtpInputField(
                  key: fieldKey,
                  controller: controller,
                  length: 6,
                  errorText: state.otpError,
                  autofocus: true,
                  status: entryStatus,
                  statusLabel: entryLabel,
                  onChanged: onCodeChanged,
                ),
                const SizedBox(height: 18),
                PrimaryButton(
                  label: 'Verify & Continue',
                  enabled: state.isOtpValid,
                  isLoading: state.isLoading,
                  gradient: true,
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    context.read<LoginBloc>().add(const OtpSubmitted());
                  },
                ),
                const SizedBox(height: 16),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Didn't get the code?",
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColor.authTextSecondary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (secondsLeft > 0)
                        Text(
                          'Resend in $timerLabel',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColor.authTextSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      else
                        GestureDetector(
                          onTap: onResend,
                          child: const Text(
                            'Resend now',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColor.authLink,
                              fontWeight: FontWeight.w800,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _ResendChannelChip(
                        icon: Icons.chat_bubble_outline,
                        iconColor: AppColor.authWhatsApp,
                        label: 'WhatsApp',
                        enabled: secondsLeft == 0,
                        onTap: onResend,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ResendChannelChip(
                        icon: Icons.phone_outlined,
                        iconColor: AppColor.authAccent,
                        label: 'Get a call',
                        enabled: secondsLeft == 0,
                        onTap: onResend,
                      ),
                    ),
                  ],
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

class _PasteChip extends StatelessWidget {
  const _PasteChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColor.indicativeBlueColor50,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.content_paste, size: 13, color: AppColor.authLink),
            SizedBox(width: 5),
            Text(
              'Paste',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColor.authLink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResendChannelChip extends StatelessWidget {
  const _ResendChannelChip({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: enabled ? onTap : null,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColor.authSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColor.authFieldBorder, width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 17, color: iconColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColor.authTextPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
