import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_assets.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/me/model/seeker_account.dart';
import 'package:local_markerplace/me/presentation/components/me_components.dart';

/// 01 · Me — everything the seeker owns, and the way out of the app.
///
/// Rendered as the shell's fourth tab rather than a pushed route, so it keeps
/// the tab bar the design draws under it.
class MeView extends StatelessWidget {
  const MeView({
    super.key,
    required this.account,
    this.onEditProfile,
    this.onVisits,
    this.onPosts,
    this.onChats,
    this.onIdentity,
    this.onSavedProviders,
    this.onAddresses,
    this.onNotifications,
    this.onBecomeProvider,
    this.onSignOut,
    this.onSignOutEverywhere,
  });

  final SeekerAccount account;
  final VoidCallback? onEditProfile;
  final VoidCallback? onVisits;
  final VoidCallback? onPosts;
  final VoidCallback? onChats;
  final VoidCallback? onIdentity;
  final VoidCallback? onSavedProviders;
  final VoidCallback? onAddresses;
  final VoidCallback? onNotifications;
  final VoidCallback? onBecomeProvider;
  final VoidCallback? onSignOut;
  final VoidCallback? onSignOutEverywhere;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Hero(account: account, onEdit: onEditProfile),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                MeRow(
                  title: 'My visits',
                  value: '${account.upcomingVisits} upcoming',
                  onTap: onVisits,
                ),
                const _Rule(),
                MeRow(
                  title: 'My posts',
                  value: '${account.openPosts} open',
                  onTap: onPosts,
                ),
                const _Rule(),
                MeRow(
                  title: 'Chats',
                  value: '${account.unreadChats} unread',
                  onTap: onChats,
                ),
                const _Rule(),
                MeRow(
                  title: 'Identity verification',
                  trailing: KycStatusPill(status: account.kycStatus),
                  onTap: onIdentity,
                ),
                const _Rule(),
                MeRow(
                  title: 'Saved providers',
                  value: '${account.savedProviderCount}',
                  onTap: onSavedProviders,
                ),
                const _Rule(),
                const SizedBox(height: 20),
                BecomeProviderCard(onTap: onBecomeProvider),
                const SizedBox(height: 20),
                MeRow(
                  title: 'Addresses',
                  value: '${account.savedAddressCount} saved',
                  onTap: onAddresses,
                ),
                const _Rule(),
                MeRow(title: 'Notification settings', onTap: onNotifications),
                const SizedBox(height: 20),
                Row(
                  children: [
                    GestureDetector(
                      onTap: onSignOut,
                      behavior: HitTestBehavior.opaque,
                      child: Text('Sign out', style: DiscoveryText.danger),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: onSignOutEverywhere,
                      behavior: HitTestBehavior.opaque,
                      child: Text(
                        'Sign out everywhere',
                        style: DiscoveryText.link.copyWith(
                          color: AppColor.discoveryTextTertiary,
                          fontSize: 13,
                          letterSpacing: -0.13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule();

  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, thickness: 1, color: AppColor.discoveryBorder);
}

class _Hero extends StatelessWidget {
  const _Hero({required this.account, this.onEdit});

  final SeekerAccount account;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColor.discoveryHeroTop, AppColor.white],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 40,
            top: -40,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColor.discoveryAccent.withValues(alpha: 0.10),
                    AppColor.discoveryAccent.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 26),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: onEdit,
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: 88,
                    height: 78,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(21.6),
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
                            account.initials,
                            style: DiscoveryText.avatarInitials(24.48),
                          ),
                        ),
                        // The pencil badge straddles the avatar's corner, the
                        // way the verified check does on a provider.
                        Positioned(
                          left: 52,
                          top: 52,
                          child: SizedBox(
                            width: 26,
                            height: 26,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SvgPicture.asset(
                                  DiscoveryAssets.editBadgeDisc,
                                  width: 26,
                                  height: 26,
                                ),
                                SvgPicture.asset(
                                  DiscoveryAssets.editBadgePencil,
                                  width: 10.6,
                                  height: 9.6,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 22),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        account.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: DiscoveryText.meName,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        account.phone,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: DiscoveryText.subtitle,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        account.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: DiscoveryText.metaMuted,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
