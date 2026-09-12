import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:local_markerplace/visit/model/visit.dart';
import 'package:local_markerplace/visit/repository/visit_repository.dart';

part 'orders_event.dart';
part 'orders_state.dart';

/// Everything the seeker has booked, newest first.
class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final VisitRepository visitRepository;

  OrdersBloc({required this.visitRepository})
    : super(const OrdersState.initial()) {
    on<OrdersRequested>(_onRequested);
  }

  void _onRequested(OrdersRequested event, Emitter<OrdersState> emit) {
    emit(state.copyWith(orders: visitRepository.booked, isLoading: false));
  }
}
