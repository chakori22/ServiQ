part of 'orders_bloc.dart';

sealed class OrdersEvent extends Equatable {
  const OrdersEvent();
}

final class OrdersRequested extends OrdersEvent {
  const OrdersRequested();

  @override
  List<Object> get props => [];
}
