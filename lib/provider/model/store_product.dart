import 'package:equatable/equatable.dart';

/// A part a provider sells alongside their services.
class StoreProduct extends Equatable {
  const StoreProduct({
    required this.name,
    required this.price,
    required this.stockLabel,
    this.isLow = false,
  });

  final String name;

  /// Already formatted, e.g. "₹1,200".
  final String price;

  /// "In stock" or "Only 2 left".
  final String stockLabel;

  /// Colours the stock line as a warning rather than in-stock green.
  final bool isLow;

  @override
  List<Object?> get props => [name, price, stockLabel, isLow];
}
