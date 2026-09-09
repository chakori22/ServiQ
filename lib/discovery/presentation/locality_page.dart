import 'package:flutter/material.dart';

import 'package:local_markerplace/basket/app_bottom_bar.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/model/provider_summary.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_header.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_note.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_tab_bar.dart';
import 'package:local_markerplace/discovery/presentation/components/provider_row.dart';
import 'package:local_markerplace/discovery/repository/discovery_repository.dart';

/// 05 · Explore — locality. Everyone working in one society or market.
class LocalityPage extends StatelessWidget {
  const LocalityPage({
    super.key,
    required this.localityName,
    this.onProviderTap,
    this.onTabSelected,
    this.onPost,
    this.providers,
    this.repository = const DiscoveryRepository(),
  });

  final String localityName;

  /// Who to list. Null falls back to the seeded repository — the zone
  /// drill-down still comes that way, while home hands over what the home
  /// endpoint actually returned for this area.
  final List<ProviderSummary>? providers;
  final ValueChanged<ProviderSummary>? onProviderTap;
  final ValueChanged<DiscoveryTab>? onTabSelected;
  final VoidCallback? onPost;
  final DiscoveryRepository repository;

  @override
  Widget build(BuildContext context) {
    final providers = this.providers ?? repository.providersIn(localityName);
    final zone = repository.zoneOfLocality(localityName);
    final locality = zone?.localities
        .where((l) => l.name == localityName)
        .firstOrNull;

    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            DiscoveryHeader(
              title: localityName,
              subtitle: [
                // The count follows the list being shown; the seeded
                // locality's own number is only right when the list is
                // seeded too.
                '${this.providers != null ? providers.length : locality?.providerCount ?? providers.length} providers',
                if (zone != null) zone.name,
              ].join(' · '),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: providers.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: DiscoveryNote(
                        'No providers here yet — coming soon.',
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: providers.length,
                      separatorBuilder: (_, _) => const Padding(
                        // Indented so the divider starts past the avatar, the way
                        // the design runs it under the text only.
                        padding: EdgeInsets.only(left: 58),
                        child: Divider(
                          height: 1,
                          thickness: 1,
                          color: AppColor.discoveryBorder,
                        ),
                      ),
                      itemBuilder: (context, index) => ProviderRow(
                        provider: providers[index],
                        subtitle: providers[index].trade,
                        index: index,
                        onTap: () => onProviderTap?.call(providers[index]),
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
