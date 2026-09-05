import 'package:flutter/material.dart';

import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/model/provider_summary.dart';
import 'package:local_markerplace/discovery/model/service_category.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_header.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_note.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_search_field.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/discovery/presentation/components/category_tile.dart';
import 'package:local_markerplace/discovery/presentation/components/pending_booking_bar.dart';
import 'package:local_markerplace/discovery/presentation/components/provider_card.dart';
import 'package:local_markerplace/discovery/presentation/components/section_header.dart';
import 'package:local_markerplace/discovery/repository/discovery_repository.dart';

/// 02 · Home — the seeker's starting point: where they are, what they can
/// search for, the trades on offer and who is working nearby.
class DiscoveryHomeView extends StatelessWidget {
  const DiscoveryHomeView({
    super.key,
    required this.localityName,
    required this.onChangeLocality,
    required this.onSearch,
    required this.onSeeAllCategories,
    required this.onSeeAllProviders,
    this.onCategoryTap,
    this.onProviderTap,
    this.onViewBooking,
    this.repository = const DiscoveryRepository(),
  });

  final String localityName;
  final VoidCallback onChangeLocality;
  final VoidCallback onSearch;
  final VoidCallback onSeeAllCategories;
  final VoidCallback onSeeAllProviders;
  final ValueChanged<ServiceCategory>? onCategoryTap;
  final ValueChanged<ProviderSummary>? onProviderTap;
  final VoidCallback? onViewBooking;
  final DiscoveryRepository repository;

  @override
  Widget build(BuildContext context) {
    final categories = repository.categories();
    final nearby = repository.nearby(localityName);
    final booking = repository.pendingBooking();

    return Column(
      children: [
        HomeHeader(
          localityName: localityName,
          onChangeLocality: onChangeLocality,
          unreadChats: 2,
          unreadNotifications: 3,
        ),
        const Divider(height: 1, thickness: 1, color: AppColor.discoveryBorder),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'What do you need done?',
                    style: DiscoveryText.headline,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: DiscoverySearchButton(onTap: onSearch),
                ),
                const SizedBox(height: 22),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SectionHeader(
                    title: 'Categories',
                    onSeeAll: onSeeAllCategories,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: categories.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          mainAxisExtent: 92,
                        ),
                    itemBuilder: (context, index) => CategoryTile(
                      category: categories[index],
                      onTap: () => onCategoryTap?.call(categories[index]),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SectionHeader(
                    title: 'Near you',
                    onSeeAll: onSeeAllProviders,
                  ),
                ),
                const SizedBox(height: 4),
                if (nearby.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: DiscoveryNote(
                      'No providers in $localityName yet — coming soon.',
                    ),
                  )
                else
                  SizedBox(
                    height: 152,
                    child: ListView.separated(
                      // Keyed on the area so switching areas starts the rail
                      // at the first card rather than keeping the offset the
                      // previous area's list was scrolled to.
                      key: ValueKey(localityName),
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: nearby.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, index) => ProviderCard(
                        provider: nearby[index],
                        onTap: () => onProviderTap?.call(nearby[index]),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (booking != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: PendingBookingBar(booking: booking, onView: onViewBooking),
          ),
      ],
    );
  }
}
