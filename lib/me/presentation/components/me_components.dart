import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_assets.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/me/model/kyc_document.dart';

/// The capsule that carries a document's — or the account's — KYC state.
class KycStatusPill extends StatelessWidget {
  const KycStatusPill({super.key, required this.status});

  final KycStatus status;

  @override
  Widget build(BuildContext context) {
    final (fill, text) = switch (status) {
      KycStatus.approved => (
        AppColor.discoveryLiveTint,
        AppColor.discoveryLiveText,
      ),
      KycStatus.underReview ||
      KycStatus.pending => (AppColor.kycPendingTint, AppColor.kycPendingText),
      KycStatus.rejected => (AppColor.kycRejectTint, AppColor.kycRejectText),
    };

    return Container(
      padding: const EdgeInsets.only(left: 9, right: 10, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: DiscoveryText.pill.copyWith(color: text),
      ),
    );
  }
}

/// A 60pt settings row: a title, an optional trailing value or pill, and a
/// chevron.
class MeRow extends StatelessWidget {
  const MeRow({
    super.key,
    required this.title,
    this.value,
    this.trailing,
    this.onTap,
  });

  final String title;

  /// The muted count on the right, e.g. "2 upcoming".
  final String? value;

  /// Takes the value's place when the row carries a pill instead.
  final Widget? trailing;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: DiscoveryText.rowTitle,
              ),
            ),
            ?trailing,
            if (trailing == null && value != null)
              Text(value!, style: DiscoveryText.caption),
            const SizedBox(width: 12),
            SvgPicture.asset(
              DiscoveryAssets.chevronRight,
              width: 6.9,
              height: 12.9,
            ),
          ],
        ),
      ),
    );
  }
}

/// The dark card inviting a seeker to list their own business.
class BecomeProviderCard extends StatelessWidget {
  const BecomeProviderCard({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 68,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            // The design tilts this one further than the avatars.
            begin: Alignment(-0.4, -1),
            end: Alignment(0.4, 1),
            colors: [
              AppColor.discoveryAvatarTop,
              AppColor.discoveryAvatarBottom,
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -40,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColor.white.withValues(alpha: 0.12),
                      AppColor.white.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'List your business',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: DiscoveryText.onAccent(
                            13.5,
                            letterSpacing: -0.135,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Get leads from your society — free to list',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: DiscoveryText.pillMuted.copyWith(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SvgPicture.asset(DiscoveryAssets.go, width: 28, height: 28),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The pale strip explaining that documents are private.
class PrivacyNote extends StatelessWidget {
  const PrivacyNote({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColor.discoveryTint,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(DiscoveryAssets.lock, width: 14, height: 18),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: DiscoveryText.smallPrint)),
        ],
      ),
    );
  }
}

/// The list of things that keep a document from being rejected.
class TipsBox extends StatelessWidget {
  const TipsBox({super.key, required this.heading, required this.tips});

  final String heading;
  final List<String> tips;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColor.providerNoteFill,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(heading, style: DiscoveryText.tipsHeading),
          const SizedBox(height: 12),
          for (var i = 0; i < tips.length; i++) ...[
            if (i > 0) const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: AppColor.discoveryTextTertiary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(child: Text(tips[i], style: DiscoveryText.meta)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// A wide button that is only an outline — "Add a document", "Add an
/// address".
class OutlinedActionButton extends StatelessWidget {
  const OutlinedActionButton({
    super.key,
    required this.label,
    this.onTap,
    this.leading,
    this.height = 54,
  });

  final String label;
  final VoidCallback? onTap;
  final Widget? leading;
  final double height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColor.discoveryAccent.withValues(alpha: 0.35),
            width: 1.6,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 9)],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: DiscoveryText.outlinedAction,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
