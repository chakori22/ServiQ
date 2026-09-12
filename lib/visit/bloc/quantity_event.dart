part of 'quantity_bloc.dart';

sealed class QuantityEvent extends Equatable {
  const QuantityEvent();
}

final class QuantityChanged extends QuantityEvent {
  final int quantity;

  const QuantityChanged(this.quantity);

  @override
  List<Object> get props => [quantity];
}
