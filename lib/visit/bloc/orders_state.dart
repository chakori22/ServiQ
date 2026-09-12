part of 'orders_bloc.dart';

class OrdersState extends Equatable {
  final List<Visit> orders;
  final bool isLoading;

  const OrdersState({required this.orders, required this.isLoading});

  const OrdersState.initial({this.orders = const [], this.isLoading = true});

  OrdersState copyWith({List<Visit>? orders, bool? isLoading}) {
    return OrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool get isEmpty => orders.isEmpty;

  @override
  List<Object?> get props => [orders, isLoading];
}
