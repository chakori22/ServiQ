import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/model/locality.dart';
import 'package:local_markerplace/discovery/model/service_zone.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_assets.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/discovery/presentation/components/locality_row.dart';
import 'package:local_markerplace/discovery/presentation/components/status_pill.dart';

/// Shared shell for the flow's cards: white (or muted) fill, an 18pt radius
/// and the same hairline border.
class _ZoneCardShell extends StatelessWidget {
  const _ZoneCardShell({required this.child, this.isMuted = false});

  final Widget child;
  final bool isMuted;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isMuted ? AppColor.discoverySurfaceMuted : AppColor.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColor.discoveryBorder, width: 1.4),
        boxShadow: isMuted
            ? null
            : [
                BoxShadow(
                  color: AppColor.discoveryShadow.withValues(alpha: 0.05),
                  blurRadius: 7,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: child,
    );
  }
}

/// The area picker's card: a live zone's name with its LIVE pill, then one
/// row per society so the seeker can pick their area without a second step.
class ZonePickerCard extends StatelessWidget {
  const ZonePickerCard({
    super.key,
    required this.zone,
    required this.onLocalityTap,
    this.maxLocalities = 3,
  });

  final ServiceZone zone;
  final ValueChanged<Locality> onLocalityTap;

  /// The design shows the first three; the rest live behind zone detail.
  final int maxLocalities;

  @override
  Widget build(BuildContext context) {
    final localities = zone.societies.take(maxLocalities).toList();

    return _ZoneCardShell(
      child: Padding(
        padding: const EdgeInsets.all(14.6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    zone.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: DiscoveryText.groupTitle,
                  ),
                ),
                const SizedBox(width: 10),
                if (zone.isLive) const StatusPill.live(),
              ],
            ),
            const SizedBox(height: 14),
            for (var i = 0; i < localities.length; i++) ...[
              // The first divider runs the full width of the card's content;
              // the ones between rows are indented, which is what visually
              // ties the rows together as one list.
              Padding(
                padding: EdgeInsets.only(left: i == 0 ? 0 : 14),
                child: const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColor.discoveryBorder,
                ),
              ),
              LocalityRow(
                title: localities[i].name,
                providerCount: localities[i].providerCount,
                horizontalPadding: 14,
                onTap: () => onLocalityTap(localities[i]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The picker's second card — areas ServiQ has not opened yet, listed so the
/// seeker can see them coming and tell us they want one.
class ComingSoonPickerCard extends StatelessWidget {
  const ComingSoonPickerCard({
    super.key,
    required this.zones,
    required this.onZoneTap,
  });

  final List<ServiceZone> zones;
  final ValueChanged<ServiceZone> onZoneTap;

  @override
  Widget build(BuildContext context) {
    return _ZoneCardShell(
      isMuted: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.6, vertical: 4.6),
        child: Column(
          children: [
            for (var i = 0; i < zones.length; i++) ...[
              if (i > 0)
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColor.discoveryBorder,
                ),
              LocalityRow(
                title: zones[i].name,
                isComingSoon: true,
                onTap: () => onZoneTap(zones[i]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The explore list's card for a live zone: its name and city, then a footer
/// counting the societies and markets waiting inside.
class ZoneSummaryCard extends StatelessWidget {
  const ZoneSummaryCard({super.key, required this.zone, this.onTap});

  final ServiceZone zone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: _ZoneCardShell(
        child: Padding(
          padding: const EdgeInsets.all(14.6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      zone.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DiscoveryText.sectionTitle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const StatusPill.live(),
                ],
              ),
              const SizedBox(height: 4),
              Text(zone.city, style: DiscoveryText.footnote),
              const SizedBox(height: 8),
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColor.discoveryBorder,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '${zone.totalSocieties} societies',
                    style: DiscoveryText.link,
                  ),
                  const SizedBox(width: 14),
                  Text(
                    '${zone.totalMarkets} markets',
                    style: DiscoveryText.link,
                  ),
                  const Spacer(),
                  SvgPicture.asset(
                    DiscoveryAssets.chevronRight,
                    width: 6.9,
                    height: 12.9,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The explore list's card for a zone that is not open yet.
class ComingSoonZoneCard extends StatelessWidget {
  const ComingSoonZoneCard({super.key, required this.zone, this.onTap});

  final ServiceZone zone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: _ZoneCardShell(
        isMuted: true,
        child: SizedBox(
          height: 60,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    zone.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: DiscoveryText.rowTitleDisabled,
                  ),
                ),
                const SizedBox(width: 10),
                const StatusPill.comingSoon(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
