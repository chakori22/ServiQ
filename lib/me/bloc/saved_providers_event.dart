part of 'saved_providers_bloc.dart';

sealed class SavedProvidersEvent extends Equatable {
  const SavedProvidersEvent();
}

final class SavedProvidersRequested extends SavedProvidersEvent {
  /// The seeker's own area, which "Near me" is measured against.
  final String localityName;

  const SavedProvidersRequested(this.localityName);

  @override
  List<Object> get props => [localityName];
}

final class SavedFilterSelected extends SavedProvidersEvent {
  final SavedFilter filter;

  const SavedFilterSelected(this.filter);

  @override
  List<Object> get props => [filter];
}
