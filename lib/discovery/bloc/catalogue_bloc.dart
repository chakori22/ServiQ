import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:local_markerplace/discovery/model/catalogue_service.dart';
import 'package:local_markerplace/discovery/model/service_category.dart';
import 'package:local_markerplace/provider/repository/provider_repository.dart';
import 'package:local_markerplace/visit/model/visit_service.dart';
import 'package:local_markerplace/visit/repository/visit_repository.dart';

part 'catalogue_event.dart';
part 'catalogue_state.dart';

/// Everything bookable in one area, and the filter over it.
///
/// The rows say what is already on a cart, so this watches the carts as well
/// as the catalogue — a job added here has to stop offering to be added
/// again, and one taken off a cart elsewhere has to start offering it.
class CatalogueBloc extends Bloc<CatalogueEvent, CatalogueState> {
  final ProviderRepository providerRepository;
  final VisitRepository visitRepository;

  late final StreamSubscription<void> _changes;

  CatalogueBloc({
    required this.providerRepository,
    required this.visitRepository,
  }) : super(const CatalogueState.initial()) {
    on<CatalogueOpened>(_onOpened);
    on<CatalogueFiltered>(_onFiltered);
    on<CatalogueServiceAdded>(_onServiceAdded);
    on<CatalogueServiceRemoved>(_onServiceRemoved);
    on<CatalogueRefreshed>(_onRefreshed);

    _changes = visitRepository.changes.listen((_) {
      if (!isClosed) add(const CatalogueRefreshed());
    });
  }

  @override
  Future<void> close() {
    _changes.cancel();
    return super.close();
  }

  void _onOpened(CatalogueOpened event, Emitter<CatalogueState> emit) {
    emit(
      state.copyWith(
        localityName: event.localityName,
        categories: event.categories,
        category: event.category,
        clearCategoryWhenAll: true,
        isLoading: false,
      ),
    );
    _read(emit);
  }

  void _onFiltered(CatalogueFiltered event, Emitter<CatalogueState> emit) {
    emit(state.copyWith(category: event.category, clearCategoryWhenAll: true));
    _read(emit);
  }

  void _onServiceAdded(
    CatalogueServiceAdded event,
    Emitter<CatalogueState> emit,
  ) {
    visitRepository.addService(
      providerName: event.providerName,
      providerLine: event.providerLine,
      isVerifiedProvider: event.isVerifiedProvider,
      service: event.service,
    );
    _read(emit);
  }

  /// Takes the job back off the cart. The list is the only place it can be
  /// removed from without opening the cart itself, so the row keeps the
  /// action once something is on it.
  void _onServiceRemoved(
    CatalogueServiceRemoved event,
    Emitter<CatalogueState> emit,
  ) {
    final cart = visitRepository.cartFor(event.providerName);
    if (cart == null) return;
    final index = cart.services.indexWhere((s) => s.name == event.name);
    if (index == -1) return;
    visitRepository.removeServiceAt(event.providerName, index);
    _read(emit);
  }

  void _onRefreshed(CatalogueRefreshed event, Emitter<CatalogueState> emit) =>
      _read(emit);

  void _read(Emitter<CatalogueState> emit) {
    final services = providerRepository.servicesIn(
      state.localityName,
      categoryLabel: state.category,
    );

    // How many of each are already on a cart, worked out once here rather
    // than by every row as it builds.
    final onCart = <String, int>{};
    for (final service in services) {
      final cart = visitRepository.cartFor(service.providerName);
      if (cart == null) continue;
      for (final booked in cart.services) {
        if (booked.name == service.name) {
          onCart['${service.providerName}|${service.name}'] = booked.quantity;
        }
      }
    }

    emit(state.copyWith(services: services, onCart: onCart));
  }
}
