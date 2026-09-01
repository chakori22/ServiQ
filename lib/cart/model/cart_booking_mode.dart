/// How the customer wants the booked services delivered.
///
/// The cart shows one tab per mode: come now, or come at a chosen time.
enum CartBookingMode {
  instant('Instant'),
  schedule('Schedule');

  final String label;
  const CartBookingMode(this.label);
}
