import 'package:equatable/equatable.dart';

/// A provider the seeker has bookmarked.
///
/// Its own type rather than a discovery summary: the saved list carries how
/// often they have been used, which nothing else does.
class SavedProvider extends Equatable {
  const SavedProvider({
    required this.name,
    required this.trade,
    required this.localityName,
    required this.rating,
    required this.isOpen,
    this.usageNote,
  });

  final String name;
  final String trade;
  final String localityName;
  final double rating;
  final bool isOpen;

  /// "Used twice" — omitted for one they have saved but never booked.
  final String? usageNote;

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
    localityName,
    rating,
    isOpen,
    usageNote,
  ];
}
