import 'package:equatable/equatable.dart';
import 'package:local_markerplace/cart/model/cart_item.dart';

/// The money side of the cart, derived from its lines.
///
/// Kept as its own model rather than a pile of getters on the state so the
/// bill card renders one consistent snapshot and the arithmetic sits in one
/// place.
class CartBill extends Equatable {
  /// Share of the item total added as tax and platform fees.
  ///
  /// TODO: the real rate belongs to the pricing API, per service category.
  static const double feeRate = 0.05;

  /// Sum of the lines after any offer.
  final double itemTotal;

  /// What the offers took off the undiscounted total.
  final double savings;

  final double taxesAndFees;

  const CartBill({
    required this.itemTotal,
    required this.savings,
    required this.taxesAndFees,
  });

  factory CartBill.fromItems(List<CartItem> items) {
    double itemTotal = 0;
    double savings = 0;
    for (final item in items) {
      itemTotal += item.price;
      savings += item.savings;
    }
    return CartBill(
      itemTotal: itemTotal,
      savings: savings,
      // Rounded to whole rupees so the bill lines add up on screen.
      taxesAndFees: (itemTotal * feeRate).roundToDouble(),
    );
  }

  double get toPay => itemTotal + taxesAndFees;

  bool get hasSavings => savings > 0;

  @override
  List<Object?> get props => [itemTotal, savings, taxesAndFees];
}

/// Money as the cart prints it: whole rupees, no trailing decimals, e.g.
/// "₹84". Prices in this app are always whole rupees once fees are rounded.
String formatRupees(double amount) => '₹${amount.toStringAsFixed(0)}';
