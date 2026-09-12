part of 'saved_providers_bloc.dart';

/// How the saved list can be narrowed.
enum SavedFilter { all, nearMe, openNow }

class SavedProvidersState extends Equatable {
  final List<SavedProvider> providers;
  final String localityName;
  final SavedFilter filter;
  final bool isLoading;

  const SavedProvidersState({
    required this.providers,
    required this.localityName,
    required this.filter,
    required this.isLoading,
  });

  const SavedProvidersState.initial({
    this.providers = const [],
    this.localityName = '',
    this.filter = SavedFilter.all,
    this.isLoading = true,
  });

  SavedProvidersState copyWith({
    List<SavedProvider>? providers,
    String? localityName,
    SavedFilter? filter,
    bool? isLoading,
  }) {
    return SavedProvidersState(
      providers: providers ?? this.providers,
      localityName: localityName ?? this.localityName,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  List<SavedProvider> get nearMe => providers
      .where((provider) => provider.localityName == localityName)
      .toList();

  List<SavedProvider> get openNow =>
      providers.where((provider) => provider.isOpen).toList();

  /// What the list actually draws. Every chip shows its own count, so all
  /// three sets are worked out whichever one is lit.
  List<SavedProvider> get shown => switch (filter) {
    SavedFilter.all => providers,
    SavedFilter.nearMe => nearMe,
    SavedFilter.openNow => openNow,
  };

  @override
  List<Object?> get props => [providers, localityName, filter, isLoading];
}
