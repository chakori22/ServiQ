import 'package:flutter/material.dart';

import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/model/service_zone.dart';
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
          Text('Explore', style: DiscoveryText.appBarTitle),
          const SizedBox(height: 22),
          Text(
            'Pick an area to see who works there',
            style: DiscoveryText.subtitle,
          ),
          const SizedBox(height: 18),
          for (final zone in live) ...[
            ZoneSummaryCard(zone: zone, onTap: () => onZoneTap(zone)),
            const SizedBox(height: 16),
          ],
          if (comingSoon.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('COMING SOON', style: DiscoveryText.overline),
            const SizedBox(height: 14),
            for (final zone in comingSoon) ...[
              ComingSoonZoneCard(
                zone: zone,
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
