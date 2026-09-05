import 'package:flutter/material.dart';

import 'package:local_markerplace/components/primary_button.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/model/locality.dart';
import 'package:local_markerplace/discovery/model/service_zone.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_assets.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/discovery/presentation/components/location_hero.dart';
import 'package:local_markerplace/discovery/presentation/components/zone_cards.dart';
import 'package:local_markerplace/discovery/repository/discovery_repository.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 01 · Location — the seeker picks the area they want work done in, either
/// by handing over their location or by choosing from the areas ServiQ
/// covers.
///
/// Pops with the chosen [Locality]. Popping with nothing means they backed
/// out without choosing.
class LocationPage extends StatelessWidget {
  const LocationPage({
    super.key,
    this.repository = const DiscoveryRepository(),
  });

  final DiscoveryRepository repository;

  void _choose(BuildContext context, Locality locality) {
    Navigator.of(context).pop(locality);
  }

  void _registerInterest(BuildContext context, ServiceZone zone) {
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

  @override
  Widget build(BuildContext context) {
    final zones = repository.zones();
    final liveZones = zones.where((zone) => zone.isLive).toList();
    final comingSoon = zones.where((zone) => !zone.isLive).toList();

    return Scaffold(
      backgroundColor: AppColor.white,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            const LocationHero(),
            Container(
              // Rides up over the hero, the overlap the design draws.
              margin: const EdgeInsets.only(top: LocationHero.sheetTop),
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.discoveryShadow.withValues(alpha: 0.08),
                    blurRadius: 14,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 48,
                          height: 5,
                          decoration: BoxDecoration(
                            color: AppColor.discoveryBorder,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      const SizedBox(height: 17),
                      PrimaryButton(
                        label: 'Use my current location',
                        enabled: true,
                        gradient: true,
                        height: 56,
                        gradientColors: const [
                          AppColor.discoveryGradientStart,
                          AppColor.discoveryGradientEnd,
                        ],
                        labelStyle: DiscoveryText.onAccent(
                          16,
                          letterSpacing: -0.16,
                        ),
                        leading: SvgPicture.asset(
                          DiscoveryAssets.pin,
                          width: 15,
                          height: 21,
                        ),
                        // Nothing reads the device's location yet, so this
                        // lands on the area with the most providers rather
                        // than pretending to have resolved one.
                        onPressed: () {
                          if (liveZones.isEmpty) return;
                          final societies = liveZones.first.societies;
                          if (societies.isEmpty) return;
                          _choose(context, societies.first);
                        },
                      ),
                      const SizedBox(height: 24),
                      const _OrChooseAnArea(),
                      const SizedBox(height: 24),
                      for (final zone in liveZones) ...[
                        ZonePickerCard(
                          zone: zone,
                          onLocalityTap: (locality) =>
                              _choose(context, locality),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (comingSoon.isNotEmpty)
                        ComingSoonPickerCard(
                          zones: comingSoon,
                          onZoneTap: (zone) => _registerInterest(context, zone),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "or choose an area", with a rule running out to each side.
class _OrChooseAnArea extends StatelessWidget {
  const _OrChooseAnArea();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            height: 1,
            thickness: 1,
            color: AppColor.discoveryBorder,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('or choose an area', style: DiscoveryText.footnote),
        ),
        const Expanded(
          child: Divider(
            height: 1,
            thickness: 1,
            color: AppColor.discoveryBorder,
          ),
        ),
      ],
    );
  }
}
