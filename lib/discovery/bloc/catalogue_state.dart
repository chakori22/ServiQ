part of 'catalogue_bloc.dart';

class CatalogueState extends Equatable {
  final String localityName;

  /// The trades the filter offers.
  final List<ServiceCategory> categories;

  /// The trade the list is narrowed to, or null for all of them.
  final String? category;

  final List<CatalogueService> services;

  /// How many of each job are already on a cart, keyed by provider and name.
  final Map<String, int> onCart;

  final bool isLoading;

  const CatalogueState({
    required this.localityName,
    required this.categories,
    required this.category,
    required this.services,
    required this.onCart,
    required this.isLoading,
  });

  const CatalogueState.initial({
    this.localityName = '',
    this.categories = const [],
    this.category,
    this.services = const [],
    this.onCart = const {},
    this.isLoading = true,
  });

  CatalogueState copyWith({
    String? localityName,
    List<ServiceCategory>? categories,
    String? category,

    /// Lets "All categories" clear the filter rather than keeping the last
    /// trade chosen.
    bool clearCategoryWhenAll = false,
    List<CatalogueService>? services,
    Map<String, int>? onCart,
    bool? isLoading,
  }) {
    return CatalogueState(
      localityName: localityName ?? this.localityName,
      categories: categories ?? this.categories,
      category: category ?? (clearCategoryWhenAll ? null : this.category),
      services: services ?? this.services,
      onCart: onCart ?? this.onCart,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// How many of this job are already on a cart.
  int quantityOf(CatalogueService service) =>
      onCart['${service.providerName}|${service.name}'] ?? 0;

  @override
  List<Object?> get props => [
    localityName,
    categories,
    category,
    services,
    onCart,
    isLoading,
  ];
}
