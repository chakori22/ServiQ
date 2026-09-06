import 'package:equatable/equatable.dart';

/// One part in the cart: what it is, how many, and what one costs.
///
/// The catalogue's [StoreProduct] is a listing — a formatted price and a
/// stock phrase. This is the same part once the seeker has committed to a
/// number of them, so the price is a figure that can be multiplied.
class CartProduct extends Equatable {
  const CartProduct({
    required this.name,
    required this.detail,
    required this.unitPrice,
    this.quantity = 1,
  });

  final String name;

  /// What the part is, shown on the product screen.
  final String detail;

  /// Rupees for one of it.
  final double unitPrice;

  final int quantity;

  double get lineTotal => unitPrice * quantity;

  /// "× 2" — parts are counted plainly; only services are "units".
  String get quantityLabel => '× $quantity';

  CartProduct copyWith({int? quantity}) => CartProduct(
    name: name,
    detail: detail,
    unitPrice: unitPrice,
    quantity: quantity ?? this.quantity,
  );

  @override
  List<Object?> get props => [name, detail, unitPrice, quantity];
}
