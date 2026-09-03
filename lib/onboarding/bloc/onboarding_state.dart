part of 'onboarding_bloc.dart';

// Sentinel so copyWith can tell "not passed" apart from an explicit null,
// matching LoginState — without it a stale error could never be cleared.
const _unset = Object();

/// The three screens of onboarding, in order. The enum's index is the
/// position, so the progress segments and the back/next handlers can do
/// arithmetic on it rather than keeping a separate counter in sync.
enum OnboardingStep {
  /// "What do you usually need help with?" — the category grid.
  needs,

  /// "A little about you" — name and locality together.
  about,

  /// "You're all set" — the closing confirmation.
  ready;

  /// Shown under the progress segments, e.g. "STEP 2 OF 3".
  String get counter => 'STEP ${index + 1} OF ${OnboardingStep.values.length}';
}

class OnboardingState extends Equatable {
  final SeekerProfile profile;
  final OnboardingStep step;
  final bool isSubmitting;
  final String? errorMessage;

  /// Set once the profile is saved, which is what lets the flow move on to
  /// the closing screen. Leaving for the dashboard is a separate, later tap.
  final bool isSaved;

  const OnboardingState({
    required this.profile,
    required this.step,
    required this.isSubmitting,
    required this.errorMessage,
    required this.isSaved,
  });

  const OnboardingState.initial({
    this.profile = const SeekerProfile(),
    this.step = OnboardingStep.needs,
    this.isSubmitting = false,
    this.errorMessage,
    this.isSaved = false,
  });

  OnboardingState copyWith({
    SeekerProfile? profile,
    OnboardingStep? step,
    bool? isSubmitting,
    Object? errorMessage = _unset,
    bool? isSaved,
  }) {
    return OnboardingState(
      profile: profile ?? this.profile,
      step: step ?? this.step,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  @override
  List<Object?> get props => [
    profile,
    step,
    isSubmitting,
    errorMessage,
    isSaved,
  ];

  /// Whether the current step has enough to move on.
  bool get canAdvance => switch (step) {
    // One category is enough; the dashboard can show the rest.
    OnboardingStep.needs => profile.interestIds.isNotEmpty,
    OnboardingStep.about =>
      profile.fullName.trim().length >= 2 && profile.locality.trim().isNotEmpty,
    OnboardingStep.ready => true,
  };

  /// Label for the step's button. On the first step the disabled button
  /// carries the requirement itself, which is where the design puts it
  /// rather than in a separate line of helper text.
  String get primaryActionLabel => switch (step) {
    OnboardingStep.needs => canAdvance ? 'Continue' : 'Pick at least one',
    OnboardingStep.about => 'Save and continue',
    OnboardingStep.ready => 'Start browsing',
  };

  /// Reads the choices back on the closing screen, e.g.
  /// "electrical, cleaning and AC & RO".
  String get chosenInterestsSentence {
    final labels = profile.chosenInterests
        .map((interest) => interest.sentenceLabel)
        .toList();
    if (labels.isEmpty) return 'local';
    if (labels.length == 1) return labels.single;
    return '${labels.sublist(0, labels.length - 1).join(', ')} '
        'and ${labels.last}';
  }
}
