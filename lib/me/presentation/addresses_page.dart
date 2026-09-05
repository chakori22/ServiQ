import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_assets.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_header.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_tab_bar.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/me/model/saved_address.dart';
import 'package:local_markerplace/me/presentation/components/me_components.dart';
import 'package:local_markerplace/me/repository/me_repository.dart';

/// 08 · Addresses.
///
/// The locality on an address is not just a delivery detail — it decides
/// which providers the seeker sees at all, which is why the screen says so
/// and marks an address outside a live area rather than letting it fail late.
class AddressesPage extends StatelessWidget {
  const AddressesPage({
    super.key,
    this.repository = const MeRepository(),
    this.onTabSelected,
    this.onPost,
  });

  final MeRepository repository;
  final ValueChanged<DiscoveryTab>? onTabSelected;
  final VoidCallback? onPost;

  void _notice(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: DiscoveryText.heroSubtitle.copyWith(color: AppColor.white),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final addresses = repository.addresses();

    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const DiscoveryHeader(title: 'Addresses'),
            const SizedBox(height: 14),
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColor.discoveryBorder,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                children: [
                  Text(
                    'Used for visits and deliveries. The locality decides '
                    'which providers you see.',
                    style: DiscoveryText.publicNote,
                  ),
                  const SizedBox(height: 20),
                  for (final address in addresses) ...[
                    _AddressCard(
                      address: address,
                      onEdit: () => _notice(context, 'Edit — coming soon.'),
                      onDelete: () => _notice(context, 'Delete — coming soon.'),
                      onSetDefault: () => _notice(
                        context,
                        '${address.label} is now your default address.',
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 8),
                  OutlinedActionButton(
                    label: 'Add an address',
                    leading: SvgPicture.asset(
                      DiscoveryAssets.plus,
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(
                        AppColor.discoveryGradientEnd,
                        BlendMode.srcIn,
                      ),
                    ),
                    onTap: () =>
                        _notice(context, 'Add an address — coming soon.'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedActionButton(
                    label: 'Detect my location',
                    height: 50,
                    leading: SvgPicture.asset(
                      DiscoveryAssets.addressPin,
                      width: 13,
                      height: 19,
                    ),
                    onTap: () => _notice(context, 'Location — coming soon.'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: DiscoveryTabBar(
        current: DiscoveryTab.me,
        onSelect: (tab) => onTabSelected?.call(tab),
        onPost: onPost,
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    this.onEdit,
    this.onDelete,
    this.onSetDefault,
  });

  final SavedAddress address;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSetDefault;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: SvgPicture.asset(
                  DiscoveryAssets.addressPin,
                  width: 14,
                  height: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            address.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: DiscoveryText.sectionTitleSmall,
                          ),
                        ),
                        if (address.isDefault) ...[
                          const SizedBox(width: 10),
                          const _DefaultPill(),
                        ],
                        if (!address.isServiceable) ...[
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              'Outside a live locality',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: DiscoveryText.statusDate.copyWith(
                                color: AppColor.kycPendingText,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(address.lines, style: DiscoveryText.addressLine),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColor.discoveryBorder,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              GestureDetector(
                onTap: onEdit,
                behavior: HitTestBehavior.opaque,
                child: Text('Edit', style: DiscoveryText.inlineLink),
              ),
              const SizedBox(width: 22),
              GestureDetector(
                onTap: onDelete,
                behavior: HitTestBehavior.opaque,
                child: Text('Delete', style: DiscoveryText.inlineLinkMuted),
              ),
              const Spacer(),
              if (!address.isDefault)
                GestureDetector(
                  onTap: onSetDefault,
                  behavior: HitTestBehavior.opaque,
                  child: Text(
                    'Set as default',
                    style: DiscoveryText.inlineLinkMuted,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DefaultPill extends StatelessWidget {
  const _DefaultPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 9, right: 10, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: AppColor.addressDefaultTint,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'DEFAULT',
        style: DiscoveryText.pill.copyWith(
          color: AppColor.discoveryGradientEnd,
        ),
      ),
    );
  }
}
