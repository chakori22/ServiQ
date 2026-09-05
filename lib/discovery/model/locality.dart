import 'package:equatable/equatable.dart';

/// Where localities sit inside a zone. Societies and markets are listed under
/// separate headings on the zone detail screen, so a locality carries the one
/// it belongs to rather than the screen splitting the list by name.
enum LocalityKind { society, market }

/// A society or market inside a zone — the smallest area a seeker can browse.
class Locality extends Equatable {
  const Locality({
    required this.name,
    required this.providerCount,
    required this.kind,
  });

  final String name;

  /// How many providers work here. Shown next to the row's chevron.
  final int providerCount;

  final LocalityKind kind;

  @override
  List<Object?> get props => [name, providerCount, kind];
}
