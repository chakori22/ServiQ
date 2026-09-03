import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../model/seeker_profile.dart';
import '../repository/onboarding_repository.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

/// Drives the three-step seeker onboarding.
///
/// The whole flow lives in one bloc rather than one per screen because every
/// step writes into the same [SeekerProfile] and the progress segments have to
/// know where the user is; splitting it would mean threading a half-built
/// profile through three providers.
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final OnboardingRepository onboardingRepository;

  OnboardingBloc({required this.onboardingRepository})
    : super(const OnboardingState.initial()) {
    on<InterestToggled>(_onInterestToggled);
    on<FullNameChanged>(_onFullNameChanged);
    on<LocalityChanged>(_onLocalityChanged);
    on<StepAdvanced>(_onStepAdvanced);
    on<StepReversed>(_onStepReversed);
    on<OnboardingSubmitted>(_onSubmitted);
  }

  void _onInterestToggled(
    InterestToggled event,
    Emitter<OnboardingState> emit,
  ) {
    // Copied before mutating: the state's set is shared with the previous
    // state object, and editing it in place would make Equatable see no
    // change and skip the rebuild.
    final next = Set<String>.from(state.profile.interestIds);
    if (!next.remove(event.interestId)) next.add(event.interestId);
    emit(state.copyWith(profile: state.profile.copyWith(interestIds: next)));
  }

  void _onFullNameChanged(
    FullNameChanged event,
    Emitter<OnboardingState> emit,
  ) {
    emit(
      state.copyWith(profile: state.profile.copyWith(fullName: event.fullName)),
    );
  }

  void _onLocalityChanged(
    LocalityChanged event,
    Emitter<OnboardingState> emit,
  ) {
    emit(
      state.copyWith(profile: state.profile.copyWith(locality: event.locality)),
    );
  }

  void _onStepAdvanced(StepAdvanced event, Emitter<OnboardingState> emit) {
    if (!state.canAdvance || state.step == OnboardingStep.ready) return;
    emit(state.copyWith(step: OnboardingStep.values[state.step.index + 1]));
  }

  void _onStepReversed(StepReversed event, Emitter<OnboardingState> emit) {
    if (state.step.index == 0) return;
    // Clearing the error on the way back stops a failed save's message from
    // trailing the user onto an earlier screen.
    emit(
      state.copyWith(
        step: OnboardingStep.values[state.step.index - 1],
        errorMessage: null,
      ),
    );
  }

  /// Saves what has been collected and, only if that worked, shows the
  /// closing screen. Failing here keeps the user on the form with their
  /// answers intact rather than sending them on to a screen that claims
  /// everything is set up.
  Future<void> _onSubmitted(
    OnboardingSubmitted event,
    Emitter<OnboardingState> emit,
  ) async {
    if (state.isSubmitting || !state.canAdvance) return;
    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    final result = await onboardingRepository.saveProfile(state.profile);

    result.fold(
      (failure) => emit(
        state.copyWith(isSubmitting: false, errorMessage: failure.errorMessage),
      ),
      (_) => emit(
        state.copyWith(
          isSubmitting: false,
          isSaved: true,
          step: OnboardingStep.ready,
        ),
      ),
    );
  }
}
