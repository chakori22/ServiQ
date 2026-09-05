import 'package:equatable/equatable.dart';

import 'package:local_markerplace/provider/model/provider_review.dart';
import 'package:local_markerplace/provider/model/provider_service.dart';
import 'package:local_markerplace/provider/model/store_product.dart';

/// What the trust row above a provider's actions says about them.
///
/// A business that has passed KYC and holds a GSTIN carries [verified]; one
/// who verified their ID but is an individual carries [provider] and an
/// explainer, because the absence of a badge is otherwise read as a warning.
enum ProviderBadge { verified, provider }

/// The public page for one provider — everything the four tabs read from.
class ProviderProfile extends Equatable {
  const ProviderProfile({
    required this.name,
    required this.badge,
    required this.since,
    required this.locationLine,
    required this.rating,
    required this.reviewCount,
    required this.ratingBreakdown,
    required this.about,
    required this.address,
    required this.hours,
    required this.serves,
    this.services = const [],
    this.products = const [],
    this.reviews = const [],
    this.badgeNote,
  });

  final String name;

  final ProviderBadge badge;

  /// "since May 2026", already phrased.
  final String since;

  /// The line under the trust row: a shop address, or the areas they cover.
  final String locationLine;

  final double rating;
  final int reviewCount;

  /// Share of reviews at each star, 5 down to 1. Drives the Reviews tab's
  /// bars, so it is a share of the whole and should sum to about 1.
  final List<double> ratingBreakdown;

  final String about;
  final String address;
  final String hours;
  final String serves;

  final List<ProviderService> services;
  final List<StoreProduct> products;
  final List<ProviderReview> reviews;

  /// Shown under the hero when [badge] is [ProviderBadge.provider], to say
  /// why there is no verified check.
  final String? badgeNote;

  bool get isVerified => badge == ProviderBadge.verified;

  String get initials {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty || words.first.isEmpty) return '?';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return (words[0][0] + words[1][0]).toUpperCase();
  }

  @override
  List<Object?> get props => [
    name,
    badge,
    since,
    locationLine,
    rating,
    reviewCount,
    ratingBreakdown,
    about,
    address,
    hours,
    serves,
    services,
    products,
    reviews,
    badgeNote,
  ];
}
