import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:local_markerplace/components/states/state_actions.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';

/// 07 · 03 — a screen that loaded and has nothing on it.
///
/// The design's rule for an empty is that it must not be a dead end: it says
/// what is missing in the seeker's own words, then offers the two things
/// worth doing about it. That is why the actions are required reading here
/// and the artwork is not — the picture is there so the screen does not look
/// broken, and the buttons are there so it is not a wall.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.body,
    this.illustrationAsset,
    this.icon = Icons.storefront_outlined,
    this.primaryLabel,
    this.onPrimary,
    this.primaryIcon,
    this.secondaryLabel,
    this.onSecondary,
    this.footnote,
  });

  final String title;
  final String body;

  /// An illustration to head the state with. Falls back to [icon] in the
  /// design's tinted disc when there is none.
  final String? illustrationAsset;
  final IconData icon;

  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final IconData? primaryIcon;

  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  /// A quiet line under the buttons, as the search empty explains that both
  /// of its actions keep what was typed.
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    final primary = primaryLabel;
    final secondary = secondaryLabel;
    final note = footnote;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: _Mark(asset: illustrationAsset, icon: icon),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: DiscoveryText.emptyTitle,
          ),
          const SizedBox(height: 10),
          Text(
            body,
            textAlign: TextAlign.center,
            style: DiscoveryText.caption.copyWith(height: 19 / 13),
          ),
          if (primary != null) ...[
            const SizedBox(height: 30),
            StatePrimaryButton(
              label: primary,
              icon: primaryIcon,
              onTap: onPrimary ?? () {},
            ),
          ],
          if (secondary != null) ...[
            const SizedBox(height: 14),
            StateSecondaryButton(label: secondary, onTap: onSecondary),
          ],
          if (note != null) ...[
            const SizedBox(height: 18),
            Text(
              note,
              textAlign: TextAlign.center,
              style: DiscoveryText.fine.copyWith(
                color: AppColor.discoveryTextDisabled,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The illustration, or the design's 100pt disc with a glyph in it when the
/// state has no artwork of its own.
class _Mark extends StatelessWidget {
  const _Mark({required this.asset, required this.icon});

  final String? asset;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final illustration = asset;
    if (illustration != null) {
      return SvgPicture.asset(illustration, width: 170, height: 170);
    }

    return Container(
      width: 100,
      height: 100,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColor.discoveryTint,
      ),
      child: Icon(icon, size: 40, color: AppColor.discoveryAccent),
    );
  }
}
