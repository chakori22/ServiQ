part of 'quantity_bloc.dart';

class QuantityState extends Equatable {
  final int quantity;
  final double unitPrice;

  const QuantityState({required this.quantity, required this.unitPrice});

  const QuantityState.initial({this.quantity = 1, this.unitPrice = 0});

  QuantityState copyWith({int? quantity, double? unitPrice}) {
    return QuantityState(
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }

  double get lineTotal => unitPrice * quantity;

  @override
  List<Object?> get props => [quantity, unitPrice];
}
