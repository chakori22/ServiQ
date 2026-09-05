import 'package:equatable/equatable.dart';

/// A provider as they appear in a list — the card on home, the row in a
/// locality, and the row in search results all read from this.
class ProviderSummary extends Equatable {
  const ProviderSummary({
    required this.name,
    required this.trade,
    required this.rating,
    required this.reviewCount,
    required this.localityName,
    required this.isOpen,
    this.isVerified = true,
  });

  final String name;

  /// "RO Repair · Chimney" — what they do, already joined for display.
  final String trade;

  final double rating;

  final int reviewCount;

  /// The locality they work in. Search rows pair it with the open state.
  final String localityName;

  final bool isOpen;

  final bool isVerified;

  /// Up to two letters drawn on the avatar, taken from the business name.
  String get initials {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty || words.first.isEmpty) return '?';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return (words[0][0] + words[1][0]).toUpperCase();
  }

  @override
  List<Object?> get props => [
    name,
    trade,
    rating,
    reviewCount,
    localityName,
    isOpen,
    isVerified,
  ];
}
