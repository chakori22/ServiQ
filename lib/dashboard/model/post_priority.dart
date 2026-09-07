/// How far a requirement is pushed once it is posted.
///
/// The amounts are the design's. Nothing here takes a payment or travels to
/// the backend yet — the choice is shown on the composer and goes no further.
enum PostPriority {
  standard('Standard', 0),
  priority('Priority', 49),
  urgent('Urgent', 149);

  const PostPriority(this.label, this.amount);

  final String label;

  /// Rupees. Zero means free.
  final int amount;

  /// "Free" / "₹49".
  String get priceLabel => amount == 0 ? 'Free' : '₹$amount';

  /// The same thing in one line, for the composer's row.
  String get summary => switch (this) {
    PostPriority.standard => 'Shown in the board as normal',
    PostPriority.priority => 'Top of the board · pushed to providers now',
    PostPriority.urgent => 'Priority, plus nearby areas and reminders',
  };

  /// What the option gets you. [area] names the board it would appear on;
  /// null where the area is not known, which reads as "your board" rather
  /// than the ungrammatical "the your board".
  String description(String? area) => switch (this) {
    PostPriority.standard =>
      'Shown in ${area == null ? 'your' : 'the $area'} board. Providers see '
          'it next time they open the app.',
    PostPriority.priority =>
      'Pinned to the top of the board and pushed to every matching provider '
          'straight away.',
    PostPriority.urgent =>
      'Priority, plus neighbouring localities and a reminder to providers '
          'who have not replied in 30 minutes.',
  };
}
