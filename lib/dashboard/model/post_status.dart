/// Where a requirement has got to, as "My posts" groups them.
enum PostStatus {
  /// Still taking offers.
  open('Open', 'Still taking offers'),

  /// Settled on one of them.
  accepted('Accepted', 'A provider is booked'),

  /// Taken down by the seeker, whether or not anybody was booked.
  closed('Closed', 'No longer on the board');

  const PostStatus(this.label, this.description);

  final String label;
  final String description;
}
