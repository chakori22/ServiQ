import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app_color.dart';
import '../../components/otp_input.dart';
import '../../components/primary_button.dart';
import '../bloc/login_bloc.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({super.key});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  static const _resendSeconds = 30;

  final _otpController = TextEditingController();
  Timer? _timer;
  int _secondsLeft = _resendSeconds;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  void _resend(String channel) {
    context.read<LoginBloc>().add(const OtpResendRequested());
    _otpController.clear();
    _startCountdown();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('OTP resent via $channel')));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: BlocListener<LoginBloc, LoginState>(
        listenWhen: (previous, current) =>
            !previous.isSuccess && current.isSuccess,
        listener: (context, state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('OTP verified successfully')),
            );
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _BackButton(onTap: () => Navigator.of(context).maybePop()),
                    const _TrustedBadge(),
                  ],
                ),
                const SizedBox(height: 32),
                BlocBuilder<LoginBloc, LoginState>(
                  builder: (context, state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'A verification code has been sent to',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '+91 - ${state.mobileNumber}',
                          style: const TextStyle(
                            color: AppColor.indicativeBlueColor600,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 24),
                        OtpInputField(
                          controller: _otpController,
                          length: 6,
                          errorText: state.otpError,
                          autofocus: true,
                          onChanged: (value) {
                            context.read<LoginBloc>().add(OtpChanged(value));
                          },
                        ),
                        const SizedBox(height: 20),
                        PrimaryButton(
                          label: 'Continue',
                          enabled: state.isOtpValid,
                          isLoading: state.isLoading,
                          onPressed: () {
                            context.read<LoginBloc>().add(const OtpSubmitted());
                          },
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: _secondsLeft > 0
                              ? Text.rich(
                                  TextSpan(
                                    style: const TextStyle(
                                      color: AppColor.neutralGreyColor400,
                                    ),
                                    children: [
                                      const TextSpan(text: 'Resend OTP in '),
                                      TextSpan(
                                        text:
                                            '0:${_secondsLeft.toString().padLeft(2, '0')}',
                                        style: const TextStyle(
                                          color:
                                              AppColor.indicativeBlueColor600,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Column(
                                  children: [
                                    const Text(
                                      'Resend OTP via',
                                      style: TextStyle(
                                        color: AppColor.neutralGreyColor400,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        _ResendChip(
                                          icon: Icons.sms_outlined,
                                          label: 'SMS',
                                          onTap: () => _resend('SMS'),
                                        ),
                                        const SizedBox(width: 12),
                                        _ResendChip(
                                          icon: Icons.chat_bubble_outline,
                                          label: 'Whatsapp',
                                          onTap: () => _resend('Whatsapp'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: AppColor.neutralGreyColor60,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.arrow_back_ios_new, size: 18),
      ),
    );
  }
}

class _TrustedBadge extends StatelessWidget {
  const _TrustedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F7EE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_alt, size: 16, color: Color(0xFF1DB954)),
          SizedBox(width: 6),
          Text(
            'TRUSTED BY 5L+ PEOPLE',
            style: TextStyle(
              color: Color(0xFF1DB954),
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResendChip extends StatelessWidget {
  const _ResendChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: AppColor.neutralGreyColor100),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColor.neutralGreyColor500),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(color: AppColor.neutralGreyColor500),
            ),
          ],
        ),
      ),
    );
  }
}
