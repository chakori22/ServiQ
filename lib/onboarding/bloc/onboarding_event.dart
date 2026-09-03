part of 'onboarding_bloc.dart';

sealed class OnboardingEvent extends Equatable {
  const OnboardingEvent();
}

/// Adds the category when it is not picked, removes it when it is — the grid
/// tiles are toggles, not a radio group.
final class InterestToggled extends OnboardingEvent {
  final String interestId;

  const InterestToggled(this.interestId);

  @override
  List<Object> get props => [interestId];
}

final class FullNameChanged extends OnboardingEvent {
  final String fullName;

  const FullNameChanged(this.fullName);

  @override
  List<Object> get props => [fullName];
}

final class LocalityChanged extends OnboardingEvent {
  final String locality;

  const LocalityChanged(this.locality);

  @override
  List<Object> get props => [locality];
}

final class StepAdvanced extends OnboardingEvent {
  const StepAdvanced();

  @override
  List<Object> get props => [];
}

final class StepReversed extends OnboardingEvent {
  const StepReversed();

  @override
  List<Object> get props => [];
}

/// Saves the profile and, on success, moves to the closing screen.
final class OnboardingSubmitted extends OnboardingEvent {
  const OnboardingSubmitted();

  @override
  List<Object> get props => [];
}
