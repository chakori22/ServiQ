import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/app_color.dart';
import '../../bloc/onboarding_bloc.dart';
import '../../model/seeker_profile.dart';
import '../components/interest_tile.dart';
import '../components/onboarding_chrome.dart';

/// Step 4 — the categories to put at the top of the dashboard.
///
/// Multi-select, and at least one is required: an empty set would leave the
/// home screen with nothing to lead with.
class InterestsStep extends StatelessWidget {
  const InterestsStep({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<OnboardingBloc>();
    final selected = context.select(
      (OnboardingBloc b) => b.state.profile.interestIds,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const OnboardingStepTitle(
          title: 'What do you need help with?',
          subtitle:
              'Pick as many as you like — these go to the top of your home '
              'screen. Everything else stays one tap away.',
        ),
        const SizedBox(height: 22),
        LayoutBuilder(
          builder: (context, constraints) {
            // Two columns on a normal handset, one when the text scale or a
            // narrow screen would squeeze the labels.
            final columns = constraints.maxWidth < 340 ? 1 : 2;
            const gap = 12.0;
            final tileWidth =
                (constraints.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final interest in seekerServiceInterests)
                  SizedBox(
                    width: tileWidth,
                    child: InterestTile(
                      interest: interest,
                      selected: selected.contains(interest.id),
                      onTap: () => bloc.add(InterestToggled(interest.id)),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        _SelectionSummary(count: selected.length),
      ],
    );
  }
}

/// Turns the requirement into a running count instead of only surfacing it as
/// a disabled button with no explanation.
class _SelectionSummary extends StatelessWidget {
  const _SelectionSummary({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final isEmpty = count == 0;
    return Row(
      children: [
        Icon(
          isEmpty ? Icons.info_outline : Icons.check_circle_outline,
          size: 16,
          color: isEmpty ? AppColor.authTextSecondary : AppColor.authSuccess,
        ),
        const SizedBox(width: 8),
        Text(
          isEmpty
              ? 'Choose at least one to finish'
              : '$count selected',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: isEmpty ? AppColor.authTextSecondary : AppColor.authSuccess,
          ),
        ),
      ],
    );
  }
}
