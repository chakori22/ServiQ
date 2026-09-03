import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../components/primary_button.dart';
import '../../bloc/onboarding_bloc.dart';
import '../../model/seeker_profile.dart';
import '../components/interest_tile.dart';
import '../components/onboarding_chrome.dart';

/// Step 1 — the 3x3 grid of categories.
///
/// Multi-select, and at least one is required: an empty set would leave the
/// dashboard with nothing to lead with, which is why the button itself says so
/// while it is disabled.
class NeedsStep extends StatelessWidget {
  const NeedsStep({super.key, required this.onSkip});

  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<OnboardingBloc>();
    final state = context.watch<OnboardingBloc>().state;
    final selected = state.profile.interestIds;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const OnboardingStepTitle(
          title: 'What do you usually need help with?',
          subtitle:
              'We use this to show the right providers first. You can change '
              'it any time.',
        ),
        const SizedBox(height: 22),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: seekerServiceInterests.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.12,
          ),
          itemBuilder: (context, index) {
            final interest = seekerServiceInterests[index];
            return InterestTile(
              interest: interest,
              selected: selected.contains(interest.id),
              onTap: () => bloc.add(InterestToggled(interest.id)),
            );
          },
        ),
        const SizedBox(height: 34),
        PrimaryButton(
          label: state.primaryActionLabel,
          enabled: state.canAdvance,
          gradient: true,
          onPressed: () => bloc.add(const StepAdvanced()),
        ),
        const SizedBox(height: 6),
        OnboardingFootnoteLink(label: 'I will do this later', onTap: onSkip),
      ],
    );
  }
}
