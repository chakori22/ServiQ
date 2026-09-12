part of 'discovery_bloc.dart';

class DiscoveryState extends Equatable {
  final DiscoveryTab tab;

  /// The area being browsed. Null until one has been chosen.
  final String? localityName;

  /// Counts how many times an area has been picked, so home fetches on the
  /// choice itself and not only when the choice differs from what it is
  /// already showing.
  final int localityChoiceId;

  /// The profile behind the Me tab. Null until it has been read, or when
  /// there is none on file.
  final SeekerProfile? profile;

  /// True while the stored profile is being read.
  final bool isResolvingLocality;

  /// Nothing on file — a seeker who skipped onboarding, or a fresh install.
  /// The shell opens the picker on this.
  final bool mustChooseLocality;

  const DiscoveryState({
    required this.tab,
    required this.localityName,
    required this.localityChoiceId,
    required this.profile,
    required this.isResolvingLocality,
    required this.mustChooseLocality,
  });

  const DiscoveryState.initial({
    this.tab = DiscoveryTab.home,
    this.localityName,
    this.localityChoiceId = 0,
    this.profile,
    this.isResolvingLocality = false,
    this.mustChooseLocality = false,
  });

  DiscoveryState copyWith({
    DiscoveryTab? tab,
    String? localityName,
    int? localityChoiceId,
    SeekerProfile? profile,
    bool? isResolvingLocality,
    bool? mustChooseLocality,
  }) {
    return DiscoveryState(
      tab: tab ?? this.tab,
      localityName: localityName ?? this.localityName,
      localityChoiceId: localityChoiceId ?? this.localityChoiceId,
      profile: profile ?? this.profile,
      isResolvingLocality: isResolvingLocality ?? this.isResolvingLocality,
      mustChooseLocality: mustChooseLocality ?? this.mustChooseLocality,
    );
  }

  /// The area's slug, as the home endpoint wants it.
  String get localitySlug => HomeRepository.slugFor(localityName ?? '');

  @override
  List<Object?> get props => [
    tab,
    localityName,
    localityChoiceId,
    profile,
    isResolvingLocality,
    mustChooseLocality,
  ];
}
