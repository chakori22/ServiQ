import 'package:equatable/equatable.dart';

/// A bookable job as it appears in the services catalogue.
///
/// A provider's own profile lists what *they* do; this is the other way
/// round — the job first, with the provider who would come and do it. It
/// carries the provider because a visit belongs to one, so a service picked
/// off a flat list still knows who is being booked.
class CatalogueService extends Equatable {
  const CatalogueService({
    required this.name,
    required this.detail,
    required this.fromPrice,
    required this.categoryLabel,
    required this.providerName,
    required this.rating,
    this.isVerifiedProvider = true,
  });

  final String name;

  /// What the job covers, e.g. "Split & window, gas top-up extra".
  final String detail;

  /// Already formatted, e.g. "from ₹499".
  final String fromPrice;

  /// Which of home's category tiles this sits under.
  final String categoryLabel;

  final String providerName;

  final double rating;

  final bool isVerifiedProvider;

  /// "Ajnara Gen X · usually replies in 10 min" — the line every screen in
  /// the visit flow shows under the provider's name.
  String providerLine(String localityName) =>
      '$localityName · usually replies in 10 min';

  @override
  List<Object?> get props => [
    name,
    detail,
    fromPrice,
    categoryLabel,
    providerName,
    rating,
    isVerifiedProvider,
  ];
}
