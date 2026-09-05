import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_assets.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_filter_chip.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_header.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_tab_bar.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/me/model/saved_provider.dart';
import 'package:local_markerplace/me/repository/me_repository.dart';

/// How the saved list can be narrowed.
enum _SavedFilter { all, nearMe, openNow }

/// 07 · Saved providers.
class SavedProvidersPage extends StatefulWidget {
  const SavedProvidersPage({
    super.key,
    required this.localityName,
    this.repository = const MeRepository(),
    this.onProviderTap,
    this.onTabSelected,
    this.onPost,
  });

  /// The seeker's own area, which "Near me" is measured against.
  final String localityName;

  final MeRepository repository;
  final ValueChanged<SavedProvider>? onProviderTap;
  final ValueChanged<DiscoveryTab>? onTabSelected;
  final VoidCallback? onPost;

  @override
  State<SavedProvidersPage> createState() => _SavedProvidersPageState();
}

class _SavedProvidersPageState extends State<SavedProvidersPage> {
  _SavedFilter _filter = _SavedFilter.all;

  @override
  Widget build(BuildContext context) {
    final all = widget.repository.savedProviders();
    final nearMe = all
        .where((provider) => provider.localityName == widget.localityName)
        .toList();
    final openNow = all.where((provider) => provider.isOpen).toList();

    final shown = switch (_filter) {
      _SavedFilter.all => all,
      _SavedFilter.nearMe => nearMe,
      _SavedFilter.openNow => openNow,
    };

    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            DiscoveryHeader(
              title: 'Saved providers',
              subtitle:
                  '${all.length} saved · ${nearMe.length} in '
                  '${widget.localityName}',
            ),
            const SizedBox(height: 14),
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColor.discoveryBorder,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  DiscoveryFilterChip(
                    label: 'All ${all.length}',
                    isSelected: _filter == _SavedFilter.all,
                    onTap: () => setState(() => _filter = _SavedFilter.all),
                  ),
                  const SizedBox(width: 8),
                  DiscoveryFilterChip(
                    label: 'Near me ${nearMe.length}',
                    isSelected: _filter == _SavedFilter.nearMe,
                    onTap: () => setState(() => _filter = _SavedFilter.nearMe),
                  ),
                  const SizedBox(width: 8),
                  DiscoveryFilterChip(
                    label: 'Open now ${openNow.length}',
                    isSelected: _filter == _SavedFilter.openNow,
                    onTap: () => setState(() => _filter = _SavedFilter.openNow),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                itemCount: shown.length + 1,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index == shown.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        'Saved providers appear first in Home and Search when '
                        'they serve your locality.',
                        style: DiscoveryText.footnote.copyWith(height: 16 / 12),
                      ),
                    );
                  }
                  return _SavedCard(
                    provider: shown[index],
                    onTap: () => widget.onProviderTap?.call(shown[index]),
                    onUnsave: () => ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(
                            'Removed ${shown[index].name} from saved.',
                            style: DiscoveryText.heroSubtitle.copyWith(
                              color: AppColor.white,
                            ),
                          ),
                        ),
                      ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: DiscoveryTabBar(
        current: DiscoveryTab.me,
        onSelect: (tab) => widget.onTabSelected?.call(tab),
        onPost: widget.onPost,
      ),
    );
  }
}

/// A bookmarked provider. Its own card rather than the discovery row: it
/// carries a save toggle and how often they have been used, which that row
/// has no room for.
class _SavedCard extends StatelessWidget {
  const _SavedCard({required this.provider, this.onTap, this.onUnsave});

  final SavedProvider provider;
  final VoidCallback? onTap;
  final VoidCallback? onUnsave;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(13.2),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColor.discoveryBorder, width: 1.4),
          boxShadow: [
            BoxShadow(
              color: AppColor.discoveryShadow.withValues(alpha: 0.05),
              blurRadius: 7,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 52,
              height: 52,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.6),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColor.discoveryAvatarTop,
                          AppColor.discoveryAvatarBottom,
                        ],
                      ),
                    ),
                    child: Text(
                      provider.initials,
                      style: DiscoveryText.avatarInitials(17.68),
                    ),
                  ),
                  Positioned(
                    right: -4,
                    bottom: -4,
                    child: SvgPicture.asset(
                      DiscoveryAssets.verified,
                      width: 15.6,
                      height: 15.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          provider.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: DiscoveryText.reviewAuthor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _OpenPill(isOpen: provider.isOpen),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${provider.trade} · ${provider.localityName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: DiscoveryText.metaMuted,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      SvgPicture.asset(
                        DiscoveryAssets.star,
                        width: 12,
                        height: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        provider.rating.toStringAsFixed(1),
                        style: DiscoveryText.chip,
                      ),
                      const Spacer(),
                      if (provider.usageNote != null)
                        Text(
                          provider.usageNote!,
                          style: DiscoveryText.statusDate,
                        ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: onUnsave,
                        behavior: HitTestBehavior.opaque,
                        child: SvgPicture.asset(
                          DiscoveryAssets.heart,
                          width: 18,
                          height: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpenPill extends StatelessWidget {
  const _OpenPill({required this.isOpen});

  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 9, right: 10, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: isOpen
            ? AppColor.discoveryLiveTint
            : AppColor.discoveryPillMuted,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isOpen) ...[
            SvgPicture.asset(DiscoveryAssets.liveDot, width: 6, height: 6),
            const SizedBox(width: 6),
          ],
          Text(
            isOpen ? 'OPEN' : 'CLOSED',
            style: isOpen ? DiscoveryText.pill : DiscoveryText.pillMuted,
          ),
        ],
      ),
    );
  }
}
