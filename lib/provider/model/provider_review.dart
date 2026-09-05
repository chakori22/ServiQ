import 'package:equatable/equatable.dart';

/// A review left on a provider.
class ProviderReview extends Equatable {
  const ProviderReview({
    required this.author,
    required this.rating,
    required this.age,
    required this.body,
  });

  final String author;
  final int rating;

  /// Relative, as the design writes it: "2 weeks ago", "last month".
  final String age;

  final String body;

  String get initials {
    final words = author.trim().split(RegExp(r'\s+'));
    if (words.isEmpty || words.first.isEmpty) return '?';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return (words[0][0] + words[1][0]).toUpperCase();
  }

  @override
  List<Object?> get props => [author, rating, age, body];
}
