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
  });

  final String name;

  /// "Ghaziabad, UP" — shown under the zone's name on the explore list.
  final String city;

  final bool isLive;

  /// The societies and markets inside this zone. Empty for a zone that is
  /// not open yet.
  final List<Locality> localities;

  List<Locality> get societies =>
      localities.where((l) => l.kind == LocalityKind.society).toList();

  List<Locality> get markets =>
      localities.where((l) => l.kind == LocalityKind.market).toList();

  int get totalSocieties => societies.length;

  int get totalMarkets => markets.length;

  @override
  List<Object?> get props => [name, city, isLive, localities];
}
