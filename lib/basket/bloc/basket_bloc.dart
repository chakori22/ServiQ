import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:local_markerplace/core/money.dart';
import 'package:local_markerplace/discovery/model/pending_booking.dart';
import 'package:local_markerplace/visit/model/visit.dart';
import 'package:local_markerplace/visit/repository/visit_repository.dart';

part 'basket_event.dart';
part 'basket_state.dart';

/// Every cart at once: the bar above the tabs, the list behind it, and the
/// checkout that books them all.
///
/// A cart belongs to one provider, so this is the only place that knows
/// about all of them together — how many there are, what they come to, and
/// which was added to last.
class BasketBloc extends Bloc<BasketEvent, BasketState> {
  final VisitRepository visitRepository;

  /// Kept so the bar answers a cart changed anywhere — added to from a
  /// provider's page, emptied from its own screen — and not only the ones
  /// changed through this bloc.
  late final StreamSubscription<void> _changes;

  BasketBloc({required this.visitRepository})
    : super(const BasketState.initial()) {
    on<BasketRequested>(_onRequested);
    on<CartRemoved>(_onCartRemoved);
    on<BasketCleared>(_onCleared);
    on<AllCartsConfirmed>(_onAllConfirmed);

    _changes = visitRepository.changes.listen((_) {
      if (!isClosed) add(const BasketRequested());
    });
  }

  @override
  Future<void> close() {
    _changes.cancel();
    return super.close();
  }

  void _onRequested(BasketRequested event, Emitter<BasketState> emit) {
    emit(_read(state));
  }

  void _onCartRemoved(CartRemoved event, Emitter<BasketState> emit) {
    visitRepository.removeCart(event.providerName);
    emit(_read(state));
  }

  void _onCleared(BasketCleared event, Emitter<BasketState> emit) {
    visitRepository.clear();
    emit(_read(state));
  }

  /// Books every cart that is ready. The ones still missing a time stay
  /// behind rather than going out untimed.
  void _onAllConfirmed(AllCartsConfirmed event, Emitter<BasketState> emit) {
    final booked = visitRepository.confirmAll();
    emit(_read(state).copyWith(booked: booked));
  }

  BasketState _read(BasketState from) {
    final carts = visitRepository.carts;
    final newest = visitRepository.current;

    return from.copyWith(
      carts: carts,
      // Null when every cart is empty, which is the bar's cue to be absent
      // rather than empty.
      bar: newest == null
          ? null
          : PendingBooking(
              providerName: newest.providerName,
              summary: newest.contentLine,
              amount: rupees(visitRepository.grandTotal),
              otherCarts: visitRepository.cartCount - 1,
            ),
      clearBarWhenEmpty: true,
      grandTotal: visitRepository.grandTotal,
      itemCount: visitRepository.itemCount,
      isLoading: false,
    );
  }
}
