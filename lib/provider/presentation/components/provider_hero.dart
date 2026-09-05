import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:local_markerplace/components/app_back_button.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_assets.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/provider/model/provider_profile.dart';

/// The head of a provider's page: their avatar, name, what vouches for them,
/// and the two actions.
///
/// The actions read differently for a signed-out visitor — the page is public
/// but connecting and messaging are not — which is the only difference
/// between the design's anonymous and signed-in frames.
class ProviderHero extends StatelessWidget {
  const ProviderHero({
    super.key,
    required this.profile,
    required this.isSignedIn,
    this.onConnect,
    this.onChat,
    this.onBack,
    this.onMore,
  });

  final ProviderProfile profile;
  final bool isSignedIn;
  final VoidCallback? onConnect;
  final VoidCallback? onChat;
  final VoidCallback? onBack;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColor.discoveryHeroTop,
            AppColor.providerHeroMid,
            AppColor.white,
          ],
          stops: [0, 0.7, 1],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 60,
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
          Column(
            children: [
              _HeaderRow(onBack: onBack, onMore: onMore),
              const SizedBox(height: 8),
              _Avatar(profile: profile),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  profile.name,
                  textAlign: TextAlign.center,
                  style: DiscoveryText.providerName,
                ),
              ),
              const SizedBox(height: 14),
              _TrustRow(profile: profile),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  profile.locationLine,
                  textAlign: TextAlign.center,
                  style: DiscoveryText.caption,
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _Action(
                        label: isSignedIn ? 'Connect' : 'Sign in to connect',
                        isPrimary: true,
                        onTap: onConnect,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Action(
                        label: isSignedIn ? 'Chat' : 'Sign in to chat',
                        isPrimary: false,
                        onTap: onChat,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({this.onBack, this.onMore});

  final VoidCallback? onBack;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppBackButton(onTap: onBack),
            const Spacer(),
            GestureDetector(
              onTap: onMore,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
                child: SvgPicture.asset(
                  DiscoveryAssets.more,
                  width: 4,
                  height: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.profile});

  final ProviderProfile profile;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 88,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 88,
            height: 88,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26.4),
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
              profile.initials,
              style: DiscoveryText.avatarInitials(29.92),
            ),
          ),
          if (profile.isVerified)
            Positioned(
              right: -6.6,
              bottom: -6.6,
              child: SvgPicture.asset(
                DiscoveryAssets.verified,
                width: 26.4,
                height: 26.4,
              ),
            ),
        ],
      ),
    );
  }
}

class _TrustRow extends StatelessWidget {
  const _TrustRow({required this.profile});

  final ProviderProfile profile;

  @override
  Widget build(BuildContext context) {
    final isVerified = profile.isVerified;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.only(left: 9, right: 10, top: 4, bottom: 4),
          decoration: BoxDecoration(
            color: isVerified
                ? AppColor.discoveryLiveTint
                : AppColor.discoveryPillMuted,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            isVerified ? 'VERIFIED' : 'PROVIDER',
            style: isVerified ? DiscoveryText.pill : DiscoveryText.pillMuted,
          ),
        ),
        const SizedBox(width: 8),
        Text(profile.since, style: DiscoveryText.footnoteStrong),
      ],
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.label, required this.isPrimary, this.onTap});

  final String label;
  final bool isPrimary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isPrimary ? null : AppColor.white,
          gradient: isPrimary
              ? const LinearGradient(
                  colors: [
                    AppColor.discoveryGradientStart,
                    AppColor.discoveryGradientEnd,
                  ],
                )
              : null,
          border: isPrimary
              ? null
              : Border.all(
                  color: AppColor.discoveryAccent.withValues(alpha: 0.35),
                  width: 1.6,
                ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: AppColor.discoveryGradientEnd.withValues(
                      alpha: 0.30,
                    ),
                    blurRadius: 10,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: isPrimary
                ? DiscoveryText.actionOnAccent
                : DiscoveryText.actionOutlined,
          ),
        ),
      ),
    );
  }
}
