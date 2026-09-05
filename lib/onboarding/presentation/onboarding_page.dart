import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_color.dart';
import '../../core/app_routes.dart';
import '../bloc/onboarding_bloc.dart';
import '../repository/onboarding_repository.dart';
import 'components/onboarding_chrome.dart';
import 'steps/about_you_step.dart';
import 'steps/needs_step.dart';
import 'steps/ready_step.dart';

/// The seeker's three-step setup, shown once between verification and the
/// dashboard.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingBloc(
        onboardingRepository: context.read<OnboardingRepository>(),
      ),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatelessWidget {
  const _OnboardingView();

  void _leaveForDiscovery(BuildContext context) {
    // Replaces the stack: neither onboarding nor the auth screens behind it
    // are anywhere the user should be able to go back to.
    //
    // Discovery reads the area out of the profile this flow just saved, so a
    // seeker who finished onboarding never sees the area picker. One who
    // skipped out early has saved nothing, and is asked there instead.
    GoRouter.of(context).goAppRoute(AppRoutes.discovery);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      resizeToAvoidBottomInset: true,
      body: BlocListener<OnboardingBloc, OnboardingState>(
        listenWhen: (previous, current) =>
            current.errorMessage != null &&
            previous.errorMessage != current.errorMessage,
        listener: (context, state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        },
        child: BlocBuilder<OnboardingBloc, OnboardingState>(
          builder: (context, state) {
            final bloc = context.read<OnboardingBloc>();
            final isReady = state.step == OnboardingStep.ready;

            return OnboardingBackground(
              success: isReady,
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OnboardingHeader(
                        counter: state.step.counter,
                        stepIndex: state.step.index,
                        stepCount: OnboardingStep.values.length,
                        // The closing screen has nothing to go back to and
                        // nothing left to skip, so it shows neither control.
                        // On the first step there is no earlier step, so back
                        // leaves the flow — but only when something is behind
                        // it, which is not the case on a relaunch that lands
                        // here directly.
                        onBack: switch (state.step) {
                          OnboardingStep.ready => null,
                          OnboardingStep.needs =>
                            GoRouter.of(context).canPop()
                                ? () => GoRouter.of(context).pop()
                                : null,
                          _ => () => bloc.add(const StepReversed()),
                        },
                        onSkip: isReady
                            ? null
                            : () => _leaveForDiscovery(context),
                      ),
                      const SizedBox(height: 26),
                      // Keyed by step so the switcher treats each one as a new
                      // child and cross-fades rather than mutating the
                      // previous step's fields in place.
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 260),
                        child: KeyedSubtree(
                          key: ValueKey(state.step),
                          child: switch (state.step) {
                            OnboardingStep.needs => NeedsStep(
                              onSkip: () => _leaveForDiscovery(context),
                            ),
                            OnboardingStep.about => AboutYouStep(
                              onSkip: () => _leaveForDiscovery(context),
                            ),
                            OnboardingStep.ready => ReadyStep(
                              onStartBrowsing: () =>
                                  _leaveForDiscovery(context),
                            ),
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
