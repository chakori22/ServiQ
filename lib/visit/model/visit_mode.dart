/// How a booking is timed. The cart asks for one before it will let the
/// seeker continue, because the two are mutually exclusive: a job happens
/// now, or at a time you pick.
enum VisitMode {
  instant('Instant', 99),
  scheduled('Scheduled', 0);

  const VisitMode(this.label, this.fee);

  final String label;

  /// What choosing this adds to the estimate, in rupees.
  final int fee;

  /// "+ ₹99" / "no extra".
  String get feeLabel => fee == 0 ? 'no extra' : '+ ₹$fee';

  String get description => switch (this) {
    VisitMode.instant => 'Nearest available provider comes now',
    VisitMode.scheduled => 'Pick a day and a start time',
  };

  /// Whether a slot has to be chosen before the booking can go ahead.
  bool get needsSlot => this != VisitMode.instant;
}
