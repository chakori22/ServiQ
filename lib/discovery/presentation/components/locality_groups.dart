import 'package:flutter/material.dart';

import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/model/locality.dart';
import 'package:local_markerplace/discovery/model/service_zone.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_note.dart';
import 'package:local_markerplace/discovery/presentation/components/locality_row.dart';
import 'package:local_markerplace/discovery/presentation/components/section_header.dart';

/// A zone's societies and then its markets, as the design groups them.
///
/// Shared because the same two lists are what the seeker sees whether they
/// drilled into a zone from the list or landed on their own area in Explore —
/// one of them having its own copy would be one of them drifting.
List<Widget> localityGroups({
  required ServiceZone zone,
  required ValueChanged<Locality> onLocalityTap,
}) => [
  // Both headings are shown even when a zone has nothing under one of them —
  // the seeker is told the section is empty rather than left to wonder if it
  // failed to load.
  ..._group(
    title: 'Societies',
    localities: zone.societies,
    emptyMessage: 'No societies listed here yet — coming soon.',
    onLocalityTap: onLocalityTap,
  ),
  const SizedBox(height: 28),
  ..._group(
    title: 'Markets',
    localities: zone.markets,
    emptyMessage: 'No markets listed here yet — coming soon.',
    onLocalityTap: onLocalityTap,
  ),
];

List<Widget> _group({
  required String title,
  required List<Locality> localities,
  required String emptyMessage,
  required ValueChanged<Locality> onLocalityTap,
}) {
  if (localities.isEmpty) {
    return [GroupHeader(title: title, count: 0), DiscoveryNote(emptyMessage)];
  }

  return [
    GroupHeader(title: title, count: localities.length),
    const SizedBox(height: 4),
    for (final (index, locality) in localities.indexed) ...[
      // An area with nobody on file yet reads as coming soon rather than
      // offering a tap that lands on an empty list.
      LocalityRow(
        title: locality.name,
        providerCount: locality.providerCount,
        isComingSoon: locality.providerCount == 0,
        index: index,
        onTap: locality.providerCount == 0
            ? null
            : () => onLocalityTap(locality),
      ),
      const Divider(height: 1, thickness: 1, color: AppColor.discoveryBorder),
    ],
  ];
}
