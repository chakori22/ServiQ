import 'package:dartz/dartz.dart';

import 'package:local_markerplace/discovery/model/home_feed.dart';
import 'package:local_markerplace/discovery/repository/home_repository.dart';
import 'package:local_markerplace/network/failure.dart';

/// A home feed without a server behind it.
///
/// Answers with whatever the test asked for, after an optional delay so a
/// test can look at the screen while it is still loading.
class FakeHomeSource implements HomeSource {
  FakeHomeSource({this.feed, this.failure, this.delay = Duration.zero});

  final HomeFeed? feed;
  final Failure? failure;
  final Duration delay;

  /// The slugs it was asked for, in order.
  final List<String> requested = <String>[];

  @override
  Future<Either<Failure, HomeFeed>> home({required String localitySlug}) async {
    requested.add(localitySlug);
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    if (failure != null) return Left(failure!);
    return Right(feed ?? sampleFeed());
  }
}

/// The payload the endpoint returns for galleria-market-1, trimmed to the
/// parts home draws.
/// [categories] is how many trades the server sends — the real endpoint
/// sends twenty-three, which is more than home shows.
HomeFeed sampleFeed({
  String slug = 'galleria-market-1',
  String name = 'Galleria Market 1',
  int providers = 1,
  int categories = 3,
}) => HomeFeed.fromJson({
  'locality': {
    'slug': slug,
    'name': name,
    'localityType': 'MARKET',
    'zoneSlug': 'crossing-republik',
    'zoneName': 'Crossing Republik',
    'lat': 28.643,
    'lng': 77.442,
    'radiusKm': 0.30,
    'providerCount': providers,
  },
  'categories': [
    for (var i = 0; i < categories; i++)
      {
        'id': i + 1,
        'slug': 'trade-${i + 1}',
        'tradeName': i < _tradeNames.length ? _tradeNames[i] : 'Trade ${i + 1}',
        'needName': 'Need ${i + 1}',
        'icon': i < _tradeIcons.length ? _tradeIcons[i] : 'wrench',
      },
  ],
  'providersNearYou': [
    for (var i = 0; i < providers; i++)
      {
        'providerId': 'PRVDEV00000$i',
        'slug': 'dev-electricals',
        'name': 'Dev Electricals',
        'logoFileId': null,
        'verified': true,
        'openNow': true,
        'homeService': false,
        'responseTimeMinutes': null,
        'localityName': name,
        'ratingAverage': 0,
        'reviewCount': 0,
      },
  ],
  'providerCount': providers,
});

/// The first few trades the endpoint actually names, so a test that reads a
/// tile is reading something the server would really have sent.
const _tradeNames = [
  'Handyman',
  'Electrician',
  'Plumber',
  'Appliance Repair',
  'AC Repair',
  'RO Repair',
  'Carpenter',
  'Painter',
  'Cleaning',
  'Pest Control',
];

const _tradeIcons = [
  'wrench',
  'bolt',
  'droplet',
  'plug',
  'snow',
  'water',
  'saw',
  'brush',
  'broom',
  'bug',
];
