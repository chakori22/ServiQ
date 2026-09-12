part of 'visit_bloc.dart';

// Sentinel so copyWith can tell "not passed" apart from an explicit null.
const _unset = Object();

class VisitState extends Equatable {
  /// Whose cart this is. There is one per provider.
  final String providerName;

  /// Null once the cart is empty or has been booked.
  final Visit? cart;

  /// The days the picker offers.
  final List<VisitDay> days;

  /// Whether anybody can take an instant booking right now.
  final bool instantAvailable;

  /// The tab showing, which is also the cart's mode.
  final VisitMode tab;

  final bool isLoading;

  /// Set by confirming, so the screen can show the receipt.
  final Visit? booked;

  const VisitState({
    required this.providerName,
    required this.cart,
    required this.days,
    required this.instantAvailable,
    required this.tab,
    required this.isLoading,
    required this.booked,
  });

  const VisitState.initial({
    this.providerName = '',
    this.cart,
    this.days = const [],
    this.instantAvailable = true,
    this.tab = VisitMode.instant,
    this.isLoading = true,
    this.booked,
  });

  VisitState copyWith({
    String? providerName,
    Visit? cart,

    /// Lets a cart that has just been emptied come back as null rather than
    /// keeping the last one that was there.
    bool clearCartWhenEmpty = false,
    List<VisitDay>? days,
    bool? instantAvailable,
    VisitMode? tab,
    bool? isLoading,
    Object? booked = _unset,
  }) {
    return VisitState(
      providerName: providerName ?? this.providerName,
      cart: cart ?? (clearCartWhenEmpty ? null : this.cart),
      days: days ?? this.days,
      instantAvailable: instantAvailable ?? this.instantAvailable,
      tab: tab ?? this.tab,
      isLoading: isLoading ?? this.isLoading,
      booked: booked == _unset ? this.booked : booked as Visit?,
    );
  }

  /// An instant booking with nobody to take it. The tab can be lit, but it
  /// cannot be confirmed.
  bool get isInstantBlocked => tab == VisitMode.instant && !instantAvailable;

  /// A scheduled cart with no slot on it yet.
  bool get needsSlot => tab.needsSlot && cart?.slot == null;

  @override
  List<Object?> get props => [
    providerName,
    cart,
    days,
    instantAvailable,
    tab,
    isLoading,
    booked,
  ];
}
