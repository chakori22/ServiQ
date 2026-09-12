import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:local_markerplace/basket/app_bottom_bar.dart';
import 'package:local_markerplace/components/motion/entrance.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_assets.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_filter_chip.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_header.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_tab_bar.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/discovery/presentation/components/provider_avatar.dart';
import 'package:local_markerplace/me/bloc/saved_providers_bloc.dart';
import 'package:local_markerplace/me/model/saved_provider.dart';
import 'package:local_markerplace/me/repository/me_repository.dart';

/// 07 · Saved providers.
class SavedProvidersPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          SavedProvidersBloc(meRepository: repository)
            ..add(SavedProvidersRequested(localityName)),
      child: _SavedProvidersView(
        onProviderTap: onProviderTap,
        onTabSelected: onTabSelected,
        onPost: onPost,
      ),
    );
  }
}

class _SavedProvidersView extends StatelessWidget {
  const _SavedProvidersView({
    required this.onProviderTap,
    required this.onTabSelected,
    required this.onPost,
  });

  final ValueChanged<SavedProvider>? onProviderTap;
  final ValueChanged<DiscoveryTab>? onTabSelected;
  final VoidCallback? onPost;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SavedProvidersBloc>().state;
    final all = state.providers;
    final nearMe = state.nearMe;
    final openNow = state.openNow;
    final shown = state.shown;

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
                  '${state.localityName}',
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
                    isSelected: state.filter == SavedFilter.all,
                    onTap: () => context.read<SavedProvidersBloc>().add(
                      const SavedFilterSelected(SavedFilter.all),
                    ),
                  ),
                  const SizedBox(width: 8),
                  DiscoveryFilterChip(
                    label: 'Near me ${nearMe.length}',
                    isSelected: state.filter == SavedFilter.nearMe,
                    onTap: () => context.read<SavedProvidersBloc>().add(
                      const SavedFilterSelected(SavedFilter.nearMe),
                    ),
                  ),
                  const SizedBox(width: 8),
                  DiscoveryFilterChip(
                    label: 'Open now ${openNow.length}',
                    isSelected: state.filter == SavedFilter.openNow,
                    onTap: () => context.read<SavedProvidersBloc>().add(
                      const SavedFilterSelected(SavedFilter.openNow),
                    ),
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
                    index: index,
                    onTap: () => onProviderTap?.call(shown[index]),
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
      bottomNavigationBar: AppBottomBar(
        current: DiscoveryTab.me,
        onSelect: (tab) => onTabSelected?.call(tab),
        onPost: onPost,
      ),
    );
  }
}

/// A bookmarked provider. Its own card rather than the discovery row: it
/// carries a save toggle and how often they have been used, which that row
/// has no room for.
class _SavedCard extends StatelessWidget {
  const _SavedCard({
    required this.provider,
    this.onTap,
    this.onUnsave,
    this.index = 0,
  });

  final SavedProvider provider;
  final VoidCallback? onTap;
  final VoidCallback? onUnsave;

  /// Position in the list, which staggers the card's entrance.
  final int index;

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      index: index,
      child: PressableScale(
        onTap: onTap,
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
              // Tinted from the provider's name, so a saved provider looks the
              // same here as they do on their card in the "Near you" rail.
              ProviderAvatar(
                initials: provider.initials,
                seed: provider.name,
                size: 52,
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
                        PressableScale(
                          onTap: onUnsave,
                          pressedScale: 0.82,
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
