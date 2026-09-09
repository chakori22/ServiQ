import 'package:flutter/material.dart';

import 'package:local_markerplace/basket/app_bottom_bar.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/model/locality.dart';
import 'package:local_markerplace/discovery/model/service_zone.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_header.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_tab_bar.dart';
import 'package:local_markerplace/discovery/presentation/components/locality_groups.dart';
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
                children: localityGroups(
                  zone: zone,
                  onLocalityTap: onLocalityTap,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomBar(
        current: DiscoveryTab.explore,
        onSelect: (tab) => onTabSelected?.call(tab),
        onPost: onPost,
      ),
    );
  }
}
