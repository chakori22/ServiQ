part of 'basket_bloc.dart';

// Sentinel so copyWith can tell "not passed" apart from an explicit null.
const _unset = Object();

class BasketState extends Equatable {
  final List<Visit> carts;

  /// What the bar above the tabs says, or null when there is nothing to say.
  final PendingBooking? bar;

  final double grandTotal;
  final int itemCount;
  final bool isLoading;

  /// The visits just booked by checking out everything, waiting for the
  /// screen to show their receipt.
  final List<Visit> booked;

  const BasketState({
    required this.carts,
    required this.bar,
    required this.grandTotal,
    required this.itemCount,
    required this.isLoading,
    required this.booked,
  });

  const BasketState.initial({
    this.carts = const [],
    this.bar,
    this.grandTotal = 0,
    this.itemCount = 0,
    this.isLoading = true,
    this.booked = const [],
  });

  BasketState copyWith({
    List<Visit>? carts,
    PendingBooking? bar,

    /// Lets the bar go away when the last cart does.
    bool clearBarWhenEmpty = false,
    double? grandTotal,
    int? itemCount,
    bool? isLoading,
    Object? booked = _unset,
  }) {
    return BasketState(
      carts: carts ?? this.carts,
      bar: bar ?? (clearBarWhenEmpty ? null : this.bar),
      grandTotal: grandTotal ?? this.grandTotal,
      itemCount: itemCount ?? this.itemCount,
      isLoading: isLoading ?? this.isLoading,
      booked: booked == _unset ? this.booked : booked as List<Visit>,
    );
  }

  bool get isEmpty => carts.isEmpty;

  int get cartCount => carts.length;

  @override
  List<Object?> get props => [
    carts,
    bar,
    grandTotal,
    itemCount,
    isLoading,
    booked,
  ];
}
