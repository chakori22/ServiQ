import 'package:equatable/equatable.dart';

/// A part a provider sells alongside their services.
class StoreProduct extends Equatable {
  const StoreProduct({
    required this.name,
    required this.price,
    required this.stockLabel,
    this.detail = '',
    this.fittingName,
    this.fittingFrom,
    this.isLow = false,
  });

  final String name;

  /// Already formatted, e.g. "₹1,200".
  final String price;

  /// "In stock" or "Only 2 left".
  final String stockLabel;

  /// What the part is, for the product screen. The store grid has no room
  /// for it, so it is empty on parts nobody has written one for yet.
  final String detail;

  /// The provider's own service that fits this part, if they offer one —
  /// the reason a store sits inside a person's profile rather than on its
  /// own. Null when there is no matching service.
  final String? fittingName;

  /// "₹349", quoted with [fittingName].
  final String? fittingFrom;

  /// Colours the stock line as a warning rather than in-stock green.
  final bool isLow;

  @override
  List<Object?> get props => [
    name,
    price,
    stockLabel,
    detail,
    fittingName,
    fittingFrom,
    isLow,
  ];
}
