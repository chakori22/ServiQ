import 'package:equatable/equatable.dart';

/// The booking the seeker has in flight, surfaced as a bar above the tab bar
/// on home so they can get back to it from anywhere in the flow.
class PendingBooking extends Equatable {
  const PendingBooking({
    required this.providerName,
    required this.summary,
    required this.amount,
  });

  final String providerName;

  /// "2 services · 3 parts".
  final String summary;

  /// Already formatted, e.g. "₹3,797".
  final String amount;

  /// Initials for the small avatar at the start of the bar.
  String get initials {
    final words = providerName.trim().split(RegExp(r'\s+'));
    if (words.isEmpty || words.first.isEmpty) return '?';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return (words[0][0] + words[1][0]).toUpperCase();
  }

  @override
  List<Object?> get props => [providerName, summary, amount];
}
