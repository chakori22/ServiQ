part of 'provider_bloc.dart';

sealed class ProviderEvent extends Equatable {
  const ProviderEvent();
}

/// Open the page for this provider.
final class ProviderRequested extends ProviderEvent {
  final String providerName;
  final String localityName;
  final ProviderTab initialTab;

  const ProviderRequested({
    required this.providerName,
    required this.localityName,
    required this.initialTab,
  });

  @override
  List<Object> get props => [providerName, localityName, initialTab];
}

/// Read the cart again, after somewhere that could have changed it.
final class ProviderCartRefreshed extends ProviderEvent {
  const ProviderCartRefreshed();

  @override
  List<Object> get props => [];
}

final class ProviderTabSelected extends ProviderEvent {
  final ProviderTab tab;

  const ProviderTabSelected(this.tab);

  @override
  List<Object> get props => [tab];
}

/// A service the seeker took from the add sheet.
final class ProviderServiceAdded extends ProviderEvent {
  final VisitService service;

  const ProviderServiceAdded(this.service);

  @override
  List<Object> get props => [service];
}

final class ProviderServiceRemoved extends ProviderEvent {
  final String name;

  const ProviderServiceRemoved(this.name);

  @override
  List<Object> get props => [name];
}

/// A part the seeker took from its own page.
final class ProviderPartAdded extends ProviderEvent {
  final CartProduct product;

  const ProviderPartAdded(this.product);

  @override
  List<Object> get props => [product];
}

/// One more or one fewer of a part, straight from the grid.
final class ProviderPartStepped extends ProviderEvent {
  final String name;
  final int delta;

  const ProviderPartStepped({required this.name, required this.delta});

  @override
  List<Object> get props => [name, delta];
}
