import 'package:equatable/equatable.dart';

/// One service line in the cart.
class CartItem extends Equatable {
  final String id;
  final String title;

  /// Asset path for the service's icon (an SVG, as elsewhere in the app).
  final String imageUrl;

  /// What the customer pays for this service after the current offer.
  final double price;

  /// The list price. Equal to [price] when the service is not discounted, in
  /// which case no struck-through price shows.
  final double originalPrice;

  const CartItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.originalPrice,
  });

  /// What the offer takes off this line; zero when nothing is discounted.
  double get savings => originalPrice - price;

  bool get isDiscounted => originalPrice > price;

  CartItem copyWith({
    String? id,
    String? title,
    String? imageUrl,
    double? price,
    double? originalPrice,
  }) {
    return CartItem(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
    );
  }

  @override
  List<Object?> get props => [id, title, imageUrl, price, originalPrice];
}
