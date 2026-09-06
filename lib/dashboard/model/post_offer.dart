import 'package:equatable/equatable.dart';

/// What vouches for whoever made an offer.
enum OfferBadge {
  /// ID and GST are both on file.
  verified,

  /// ID checked, but trading as an individual.
  provider,

  /// Somebody from the same society, offering informally.
  neighbour,
}

/// One provider's answer to a requirement.
class PostOffer extends Equatable {
  const PostOffer({
    required this.name,
    required this.badge,
    required this.price,
    required this.timing,
    required this.note,
  });

  final String name;
  final OfferBadge badge;

  /// Already formatted, e.g. "₹899".
  final String price;

  /// "today, 4–6 pm".
  final String timing;

  /// What they said about the job.
  final String note;

  /// Up to two letters for the avatar.
  String get initials {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty || words.first.isEmpty) return '?';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return (words[0][0] + words[1][0]).toUpperCase();
  }

  @override
  List<Object?> get props => [name, badge, price, timing, note];
}
