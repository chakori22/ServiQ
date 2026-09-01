part of 'cart_bloc.dart';

class CartState extends Equatable {
  final String errorMessage;

  /// True while the cart's lines, availability and address are being loaded.
  final bool cartLoading;

  final List<CartItem> items;

  final CartBookingMode mode;

  /// Whether a professional can be dispatched right away. When false the
  /// Instant tab explains itself instead of offering a booking.
  final bool instantAvailable;

  final BookingDetails? bookingDetails;

  /// Days offered by the slot picker; empty until the picker is opened.
  final List<CartSlotDay> slotDays;
  final bool slotsLoading;

  /// The start time the customer confirmed in the picker, if any.
  final CartSlot? selectedSlot;

  /// Whether the bill card shows its breakdown or just the total.
  final bool billExpanded;

  const CartState({
    required this.errorMessage,
    required this.cartLoading,
    required this.items,
    required this.mode,
    required this.instantAvailable,
    required this.bookingDetails,
    required this.slotDays,
    required this.slotsLoading,
    required this.selectedSlot,
    required this.billExpanded,
  });

  const CartState.initial({
    this.errorMessage = '',
    this.cartLoading = false,
    this.items = const [],
    // Booking now is the common case, so the cart opens on Instant and falls
    // back to Schedule only when nobody is free.
    this.mode = CartBookingMode.instant,
    this.instantAvailable = false,
    this.bookingDetails,
    this.slotDays = const [],
    this.slotsLoading = false,
    this.selectedSlot,
    this.billExpanded = true,
  });

  CartState copyWith({
    String? errorMessage,
    bool? cartLoading,
    List<CartItem>? items,
    CartBookingMode? mode,
    bool? instantAvailable,
    BookingDetails? bookingDetails,
    List<CartSlotDay>? slotDays,
    bool? slotsLoading,
    CartSlot? selectedSlot,
    bool? billExpanded,
  }) {
    return CartState(
      errorMessage: errorMessage ?? this.errorMessage,
      cartLoading: cartLoading ?? this.cartLoading,
      items: items ?? this.items,
      mode: mode ?? this.mode,
      instantAvailable: instantAvailable ?? this.instantAvailable,
      bookingDetails: bookingDetails ?? this.bookingDetails,
      slotDays: slotDays ?? this.slotDays,
      slotsLoading: slotsLoading ?? this.slotsLoading,
      selectedSlot: selectedSlot ?? this.selectedSlot,
      billExpanded: billExpanded ?? this.billExpanded,
    );
  }

  /// The money side of the cart, recomputed from the current lines.
  CartBill get bill => CartBill.fromItems(items);

  int get serviceCount => items.length;

  /// "2 services" / "1 service", as the review header shows it.
  String get serviceCountLabel =>
      '$serviceCount ${serviceCount == 1 ? 'service' : 'services'}';

  bool get hasSlot => selectedSlot != null;

  /// True when the customer is on the Instant tab but nobody can come now —
  /// the case the cart has to explain rather than let them book.
  bool get isInstantBlocked =>
      mode == CartBookingMode.instant && !instantAvailable;

  /// Whether the bottom bar can take the customer to payment.
  bool get canPay {
    if (items.isEmpty) return false;
    return switch (mode) {
      CartBookingMode.instant => instantAvailable,
      CartBookingMode.schedule => hasSlot,
    };
  }

  /// Summary of the confirmed slot, e.g. "Wed, Sep 2 - 08:30AM".
  String? get scheduledForLabel {
    final slot = selectedSlot;
    if (slot == null) return null;
    return '${CartSlotDay.formatDate(slot.startTime)} - '
        '${CartSlot.formatCompactTime(slot.startTime)}';
  }

  @override
  List<Object?> get props => [
    errorMessage,
    cartLoading,
    items,
    mode,
    instantAvailable,
    bookingDetails,
    slotDays,
    slotsLoading,
    selectedSlot,
    billExpanded,
  ];
}
