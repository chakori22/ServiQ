import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../components/primary_button.dart';
import '../../../core/app_color.dart';
import '../../bloc/onboarding_bloc.dart';
import '../components/all_set_badge.dart';

/// Step 3 — the closing confirmation, which reads the answers back so the
/// user can see what the dashboard is about to be filtered by.
class ReadyStep extends StatelessWidget {
  const ReadyStep({super.key, required this.onStartBrowsing});

  final VoidCallback onStartBrowsing;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<OnboardingBloc>().state;
    final locality = state.profile.locality.trim();

    return Column(
      children: [
        const SizedBox(height: 26),
        const AllSetBadge(),
        const SizedBox(height: 28),
        const Text(
          "You're all set",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
            color: AppColor.authTextPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Showing ${state.chosenInterestsSentence} providers'
          '${locality.isEmpty ? '' : ' in $locality'} first.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
            color: AppColor.authTextSecondary,
          ),
        ),
        const SizedBox(height: 40),
        PrimaryButton(
          label: state.primaryActionLabel,
          enabled: true,
          gradient: true,
          trailingIcon: Icons.arrow_forward,
          onPressed: onStartBrowsing,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
