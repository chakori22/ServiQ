import 'package:equatable/equatable.dart';

import 'package:local_markerplace/discovery/model/locality.dart';

/// A city area ServiQ either covers already or plans to.
///
/// A zone that is not [isLive] has no localities to drill into — it is listed
/// so a seeker can see it is coming and tapping it tells us where to open next.
class ServiceZone extends Equatable {
  const ServiceZone({
    required this.name,
    required this.city,
    required this.isLive,
    this.localities = const [],
    this.societyCount,
    this.marketCount,
  });

  final String name;

  /// "Ghaziabad, UP" — shown under the zone's name on the explore list.
  final String city;

  final bool isLive;

  /// The page of localities the app has loaded. A live zone lists more than
  /// this in total, which is what [totalSocieties] and [totalMarkets] report.
  final List<Locality> localities;

  /// Totals as the backend knows them. Null falls back to what is loaded.
  final int? societyCount;
  final int? marketCount;

  List<Locality> get societies =>
      localities.where((l) => l.kind == LocalityKind.society).toList();

  List<Locality> get markets =>
      localities.where((l) => l.kind == LocalityKind.market).toList();

  int get totalSocieties => societyCount ?? societies.length;

  int get totalMarkets => marketCount ?? markets.length;

  @override
  List<Object?> get props => [
    name,
    city,
    isLive,
    localities,
    societyCount,
    marketCount,
  ];
}
