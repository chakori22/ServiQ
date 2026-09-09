import 'package:flutter/material.dart';

import 'package:local_markerplace/components/motion/entrance.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/model/locality.dart';
import 'package:local_markerplace/discovery/model/service_zone.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_header.dart';
import 'package:local_markerplace/discovery/presentation/components/locality_groups.dart';
import 'package:local_markerplace/discovery/presentation/components/status_pill.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/discovery/presentation/components/zone_cards.dart';
import 'package:local_markerplace/discovery/repository/discovery_repository.dart';

/// 03 · Explore — the areas ServiQ covers, and the ones it is heading for.
class ExploreZonesView extends StatelessWidget {
  const ExploreZonesView({
    super.key,
    required this.onZoneTap,
    this.onComingSoonTap,
    this.repository = const DiscoveryRepository(),
  });

  final ValueChanged<ServiceZone> onZoneTap;
  final ValueChanged<ServiceZone>? onComingSoonTap;
  final DiscoveryRepository repository;

  @override
  Widget build(BuildContext context) {
    final zones = repository.zones();
    final live = zones.where((zone) => zone.isLive).toList();
    final comingSoon = zones.where((zone) => !zone.isLive).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 17, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FadeSlideIn(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Explore', style: DiscoveryText.appBarTitle),
                const SizedBox(height: 22),
                Text(
                  'Pick an area to see who works there',
                  style: DiscoveryText.subtitle,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          // The two lists share one run of stagger indices, so the whole page
          // arrives as a single sweep rather than as two separate ones.
          for (final (index, zone) in live.indexed) ...[
            ZoneSummaryCard(
              zone: zone,
              index: index + 1,
              onTap: () => onZoneTap(zone),
            ),
            const SizedBox(height: 16),
          ],
          if (comingSoon.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('COMING SOON', style: DiscoveryText.overline),
            const SizedBox(height: 14),
            for (final (index, zone) in comingSoon.indexed) ...[
              ComingSoonZoneCard(
                zone: zone,
                index: live.length + index + 1,
                onTap: () => onComingSoonTap?.call(zone),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 12),
            Text(
              'Tapping a coming-soon area tells us where to open next.',
              style: DiscoveryText.footnote.copyWith(height: 18 / 12),
            ),
          ],
        ],
      ),
    );
  }
}

/// 03 · Explore, for a seeker who has already said where they are.
///
/// The zone list asks which area to look in; this answers it from what they
/// chose on home and goes straight to the societies and markets inside it.
/// Being asked to pick an area a second time, one tab after picking one, is
/// the thing this exists to stop.
///
/// The areas ServiQ has not opened yet still follow underneath, since that
/// list is also how a seeker says where to open next.
class ExploreAreaView extends StatelessWidget {
  const ExploreAreaView({
    super.key,
    required this.zone,
    required this.onLocalityTap,
    this.comingSoon = const [],
    this.onComingSoonTap,
  });

  /// The zone the chosen area sits in.
  final ServiceZone zone;

  final ValueChanged<Locality> onLocalityTap;

  /// Zones that are not open yet, listed under the area's own localities.
  final List<ServiceZone> comingSoon;
  final ValueChanged<ServiceZone>? onComingSoonTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DiscoveryHeader(
          // A tab is not something to go back from, so the header carries no
          // back button here the way the pushed zone detail does.
          showBack: false,
          title: zone.name,
          subtitle:
              '${zone.totalSocieties} societies · '
              '${zone.totalMarkets} markets',
          trailing: zone.isLive ? const StatusPill.live() : null,
        ),
        const SizedBox(height: 14),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              ...localityGroups(zone: zone, onLocalityTap: onLocalityTap),
              if (comingSoon.isNotEmpty) ...[
                const SizedBox(height: 30),
                Text('COMING SOON', style: DiscoveryText.overline),
                const SizedBox(height: 14),
                for (final (index, other) in comingSoon.indexed) ...[
                  ComingSoonZoneCard(
                    zone: other,
                    index: index + 1,
                    onTap: () => onComingSoonTap?.call(other),
                  ),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 6),
                Text(
                  'Tapping a coming-soon area tells us where to open next.',
                  style: DiscoveryText.footnote.copyWith(height: 18 / 12),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Shown when a coming-soon area is tapped, so the seeker knows the tap
/// registered rather than silently doing nothing.
void showComingSoonNotice(BuildContext context, ServiceZone zone) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          "Thanks — we'll let you know when ${zone.name} opens.",
          style: DiscoveryText.heroSubtitle.copyWith(color: AppColor.white),
        ),
      ),
    );
}
