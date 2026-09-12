part of 'catalogue_bloc.dart';

sealed class CatalogueEvent extends Equatable {
  const CatalogueEvent();
}

/// Open the catalogue for an area, optionally narrowed to one trade.
final class CatalogueOpened extends CatalogueEvent {
  final String localityName;
  final String? category;

  /// The trades the filter offers — home's, which came from the endpoint.
  final List<ServiceCategory> categories;

  const CatalogueOpened({
    required this.localityName,
    required this.categories,
    this.category,
  });

  @override
  List<Object?> get props => [localityName, category, categories];
}

/// A trade from the filter sheet, or null for all of them.
final class CatalogueFiltered extends CatalogueEvent {
  final String? category;

  const CatalogueFiltered(this.category);

  @override
  List<Object?> get props => [category];
}

/// A job the seeker took from the add sheet.
final class CatalogueServiceAdded extends CatalogueEvent {
  final String providerName;
  final String providerLine;
  final bool isVerifiedProvider;
  final VisitService service;

  const CatalogueServiceAdded({
    required this.providerName,
    required this.providerLine,
    required this.isVerifiedProvider,
    required this.service,
  });

  @override
  List<Object> get props => [
    providerName,
    providerLine,
    isVerifiedProvider,
    service,
  ];
}

final class CatalogueServiceRemoved extends CatalogueEvent {
  final String providerName;
  final String name;

  const CatalogueServiceRemoved({
    required this.providerName,
    required this.name,
  });

  @override
  List<Object> get props => [providerName, name];
}

/// Read the catalogue and the carts again.
final class CatalogueRefreshed extends CatalogueEvent {
  const CatalogueRefreshed();

  @override
  List<Object> get props => [];
}
