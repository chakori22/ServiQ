part of 'basket_bloc.dart';

sealed class BasketEvent extends Equatable {
  const BasketEvent();
}

/// Read every cart — on opening, and again after anywhere that could have
/// changed one.
final class BasketRequested extends BasketEvent {
  const BasketRequested();

  @override
  List<Object> get props => [];
}

final class CartRemoved extends BasketEvent {
  final String providerName;

  const CartRemoved(this.providerName);

  @override
  List<Object> get props => [providerName];
}

final class BasketCleared extends BasketEvent {
  const BasketCleared();

  @override
  List<Object> get props => [];
}

/// Book every cart that has a time on it.
final class AllCartsConfirmed extends BasketEvent {
  const AllCartsConfirmed();

  @override
  List<Object> get props => [];
}
