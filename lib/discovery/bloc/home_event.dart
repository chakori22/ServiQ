part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();
}

/// Draw home for this area — on opening the screen, on changing area, and on
/// pressing Try again after it failed.
final class HomeRequested extends HomeEvent {
  final String localitySlug;

  const HomeRequested(this.localitySlug);

  @override
  List<Object> get props => [localitySlug];
}

/// The seeker pulled the feed down. Fetches the area already in state.
final class HomeRefreshed extends HomeEvent {
  const HomeRefreshed();

  @override
  List<Object> get props => [];
}

/// The chat or notification counts the header badges have changed.
final class HomeBadgesChanged extends HomeEvent {
  const HomeBadgesChanged();

  @override
  List<Object> get props => [];
}
