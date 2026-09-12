part of 'discovery_bloc.dart';

sealed class DiscoveryEvent extends Equatable {
  const DiscoveryEvent();
}

/// Work out which area to open on, when the shell was not given one.
final class DiscoveryStarted extends DiscoveryEvent {
  const DiscoveryStarted();

  @override
  List<Object?> get props => [];
}

final class DiscoveryTabSelected extends DiscoveryEvent {
  final DiscoveryTab tab;

  const DiscoveryTabSelected(this.tab);

  @override
  List<Object> get props => [tab];
}

/// The seeker picked an area — from the picker, or from the row in Edit
/// profile that opens it.
final class LocalityChosen extends DiscoveryEvent {
  final String localityName;

  const LocalityChosen(this.localityName);

  @override
  List<Object> get props => [localityName];
}

final class ProfileEdited extends DiscoveryEvent {
  final String name;
  final Set<String> interestLabels;

  const ProfileEdited({required this.name, required this.interestLabels});

  @override
  List<Object> get props => [name, interestLabels];
}
