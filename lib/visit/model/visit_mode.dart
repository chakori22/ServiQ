/// How a booking is timed. The cart asks for one before it will let the
/// seeker continue, because the three are mutually exclusive: a job happens
/// now, at a time you pick, or on a repeat.
enum VisitMode {
  instant('Instant', 99),
  scheduled('Scheduled', 0),
  recurring('Recurring', 0);

  const VisitMode(this.label, this.fee);

  final String label;

  /// What choosing this adds to the estimate, in rupees.
  final int fee;

  /// "+ ₹99" / "no extra".
  String get feeLabel => fee == 0 ? 'no extra' : '+ ₹$fee';

  String get description => switch (this) {
    VisitMode.instant => 'Nearest available provider comes now',
    VisitMode.scheduled => 'Pick a day and a start time',
    VisitMode.recurring => 'Same slot, every week or month',
  };

  /// Whether a slot has to be chosen before the booking can go ahead.
  bool get needsSlot => this != VisitMode.instant;
}

/// How often a recurring booking comes back.
enum VisitRecurrence {
  weekly('Every week'),
  fortnightly('Every 2 weeks'),
  monthly('Every month');

  const VisitRecurrence(this.label);

  final String label;
}
