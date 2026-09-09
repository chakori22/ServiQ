import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:local_markerplace/components/art/art_palette.dart';
import 'package:local_markerplace/components/art/seeded_artwork.dart';
import 'package:local_markerplace/components/motion/entrance.dart';

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
/// row per area so the seeker can pick theirs without a second step.
///
/// Markets belong here as much as societies do — a seeker who wants work
/// done at their shop picks the market, and leaving them out made the areas
/// with the most providers unreachable from the picker entirely.
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
    final localities = zone.localities.take(maxLocalities).toList();

    return _ZoneCardShell(
      child: Padding(
        padding: const EdgeInsets.all(14.6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ZoneEmblem(zone: zone),
                const SizedBox(width: 12),
                Expanded(
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
                isComingSoon: localities[i].providerCount == 0,
                horizontalPadding: 14,
                index: i,
                onTap: localities[i].providerCount == 0
                    ? null
                    : () => onLocalityTap(localities[i]),
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
                index: i,
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
  const ZoneSummaryCard({
    super.key,
    required this.zone,
    this.onTap,
    this.index = 0,
  });

  final ServiceZone zone;
  final VoidCallback? onTap;

  /// Position in the explore list, which staggers the card's entrance.
  final int index;

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      index: index,
      child: PressableScale(
        onTap: onTap,
        child: _ZoneCardShell(
          child: Padding(
            padding: const EdgeInsets.all(14.6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ZoneEmblem(zone: zone, size: 52),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            zone.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: DiscoveryText.sectionTitle,
                          ),
                          const SizedBox(height: 4),
                          Text(zone.city, style: DiscoveryText.footnote),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    const StatusPill.live(),
                  ],
                ),
                const SizedBox(height: 12),
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
      ),
    );
  }
}

/// The explore list's card for a zone that is not open yet.
class ComingSoonZoneCard extends StatelessWidget {
  const ComingSoonZoneCard({
    super.key,
    required this.zone,
    this.onTap,
    this.index = 0,
  });

  final ServiceZone zone;
  final VoidCallback? onTap;

  /// Position in the coming-soon list, which staggers the entrance.
  final int index;

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      index: index,
      child: PressableScale(
        onTap: onTap,
        child: _ZoneCardShell(
          isMuted: true,
          child: SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.6),
              child: Row(
                children: [
                  ZoneEmblem(zone: zone, size: 38),
                  const SizedBox(width: 12),
                  Expanded(
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
      ),
    );
  }
}

/// The square of artwork that stands in for an area.
///
/// A zone has no photograph and no logo, so it gets a plate generated from
/// its name with a pin on it — enough for the eye to tell Crossing Republik
/// from Gaur City without reading either label. An area that is not open yet
/// is drawn in the flow's greys instead of its own colours, so the list reads
/// as live-then-waiting at a glance.
class ZoneEmblem extends StatelessWidget {
  const ZoneEmblem({super.key, required this.zone, this.size = 44});

  final ServiceZone zone;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: SeededArtwork(
        seed: zone.name,
        palette: zone.isLive ? null : ArtPalette.dormant,
        borderRadius: BorderRadius.circular(size * 0.32),
        intensity: 0.9,
        child: Center(
          child: SvgPicture.asset(
            DiscoveryAssets.pinHeader,
            width: size * 0.30,
            height: size * 0.42,
            colorFilter: ColorFilter.mode(
              // The plate is pale, so the pin is drawn in the family's
              // saturated member — white disappeared into it.
              zone.isLive
                  ? ArtPalette.forSeed(zone.name).deep
                  : AppColor.discoveryTextDisabled,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
