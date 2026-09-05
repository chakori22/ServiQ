import 'package:flutter/material.dart';

import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/model/locality.dart';
import 'package:local_markerplace/discovery/model/service_zone.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_header.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_note.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_tab_bar.dart';
import 'package:local_markerplace/discovery/presentation/components/locality_row.dart';
import 'package:local_markerplace/discovery/presentation/components/section_header.dart';
import 'package:local_markerplace/discovery/presentation/components/status_pill.dart';

/// 04 · Explore — zone detail. The societies and markets inside one zone,
/// each carrying the number of providers waiting behind it.
class ZoneDetailPage extends StatelessWidget {
  const ZoneDetailPage({
    super.key,
    required this.zone,
    required this.onLocalityTap,
    this.onTabSelected,
    this.onPost,
  });

  final ServiceZone zone;
  final ValueChanged<Locality> onLocalityTap;

  /// Leaving explore from here goes back to the shell on the chosen tab.
  final ValueChanged<DiscoveryTab>? onTabSelected;

  final VoidCallback? onPost;

  @override
  Widget build(BuildContext context) {
    final societies = zone.societies;
    final markets = zone.markets;

    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            DiscoveryHeader(
              title: zone.name,
              trailing: zone.isLive ? const StatusPill.live() : null,
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                children: [
                  // Both headings are shown even when a zone has nothing
                  // under one of them — the seeker is told the section is
                  // empty rather than left to wonder if it failed to load.
                  ..._group(
                    title: 'Societies',
                    localities: societies,
                    emptyMessage: 'No societies listed here yet — coming soon.',
                  ),
                  const SizedBox(height: 28),
                  ..._group(
                    title: 'Markets',
                    localities: markets,
                    emptyMessage: 'No markets listed here yet — coming soon.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: DiscoveryTabBar(
        current: DiscoveryTab.explore,
        onSelect: (tab) => onTabSelected?.call(tab),
        onPost: onPost,
      ),
    );
  }

  List<Widget> _group({
    required String title,
    required List<Locality> localities,
    required String emptyMessage,
  }) {
    if (localities.isEmpty) {
      return [GroupHeader(title: title, count: 0), DiscoveryNote(emptyMessage)];
    }

    return [
      GroupHeader(title: title, count: localities.length),
      const SizedBox(height: 4),
      for (final locality in localities) ...[
        // An area with nobody on file yet reads as coming soon rather than
        // offering a tap that lands on an empty list.
        LocalityRow(
          title: locality.name,
          providerCount: locality.providerCount,
          isComingSoon: locality.providerCount == 0,
          onTap: locality.providerCount == 0
              ? null
              : () => onLocalityTap(locality),
        ),
        const Divider(height: 1, thickness: 1, color: AppColor.discoveryBorder),
      ],
    ];
  }
}
