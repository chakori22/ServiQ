import 'package:flutter/material.dart';

import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';

/// The blank shapes a screen wears while its content is on the way.
///
/// The design draws these flat, in two fills, and labels the frame "never a
/// spinner": a skeleton in the shape of what is coming tells the seeker what
/// they are waiting for, which a spinner cannot. They are deliberately still
/// — a pulse would fight the content that replaces it, and a looping
/// animation stops widget tests from ever settling.

/// One blank bar.
class SkeletonBlock extends StatelessWidget {
  const SkeletonBlock({
    super.key,
    required this.width,
    required this.height,
    this.soft = false,
    this.radius,
  });

  /// Null stretches to whatever the parent allows.
  final double? width;
  final double height;

  /// The lighter of the two fills, for the secondary bar under a heading.
  final bool soft;

  /// Defaults to a full stadium, which is how every bar in the design reads.
  final double? radius;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: soft ? AppColor.skeletonSoft : AppColor.skeletonStrong,
      borderRadius: BorderRadius.circular(radius ?? height / 2),
    ),
  );
}

/// A blank avatar.
class SkeletonCircle extends StatelessWidget {
  const SkeletonCircle({super.key, required this.size, this.soft = false});

  final double size;
  final bool soft;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: soft ? AppColor.skeletonSoft : AppColor.skeletonStrong,
      shape: BoxShape.circle,
    ),
  );
}

/// One row of a list skeleton: an avatar and three bars.
///
/// The bar widths differ from row to row so the list does not read as a
/// stack of identical stripes; [index] picks which set.
class SkeletonListRow extends StatelessWidget {
  const SkeletonListRow({super.key, this.index = 0});

  final int index;

  /// The widths the design gives its five rows, in order.
  static const _widths = [
    [190.0, 130.0],
    [210.0, 110.0],
    [170.0, 140.0],
    [200.0, 120.0],
    [180.0, 100.0],
  ];

  @override
  Widget build(BuildContext context) {
    final widths = _widths[index % _widths.length];

    return SizedBox(
      height: 78,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: SkeletonCircle(size: 44),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                SkeletonBlock(width: widths[0], height: 12),
                const SizedBox(height: 8),
                SkeletonBlock(width: widths[1], height: 10, soft: true),
                const SizedBox(height: 8),
                const SkeletonBlock(width: 70, height: 10, soft: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 07 · 01 — a list on its way.
///
/// Used wherever rows are being fetched: providers, posts, chats, orders.
/// The caption names what is loading, because "loading" on its own tells the
/// seeker nothing they did not already know.
class SkeletonList extends StatelessWidget {
  const SkeletonList({
    super.key,
    this.caption,
    this.rows = 5,
    this.hasHeader = false,
  });

  /// "Loading providers near you".
  final String? caption;

  final int rows;

  /// Draws the title and search blocks above the rows, for a screen whose
  /// header is part of what is loading.
  final bool hasHeader;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        if (hasHeader) ...[
          const SizedBox(height: 22),
          const SkeletonBlock(width: 220, height: 20),
          const SizedBox(height: 16),
          const SkeletonBlock(width: null, height: 50, soft: true, radius: 16),
          const SizedBox(height: 24),
          const SkeletonBlock(width: 120, height: 16),
        ],
        const SizedBox(height: 16),
        for (var index = 0; index < rows; index++) ...[
          if (index > 0)
            const Padding(
              // The divider starts past the avatar, as it does on a real row.
              padding: EdgeInsets.only(left: 58),
              child: Divider(
                height: 1,
                thickness: 1,
                color: AppColor.discoveryBorder,
              ),
            ),
          SkeletonListRow(index: index),
        ],
        if (caption != null) ...[
          const SizedBox(height: 24),
          Center(
            child: Text(
              caption!,
              style: DiscoveryText.footnote.copyWith(
                color: AppColor.discoveryTextDisabled,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// 07 · 02 — a provider's page on its way.
///
/// The tab strip is drawn for real rather than blanked: it is the app's own
/// furniture, not the provider's content, and blanking it would make the
/// page look broken rather than pending.
class SkeletonProfile extends StatelessWidget {
  const SkeletonProfile({super.key, this.tabs = const []});

  /// The real tab labels, drawn under the hero. Empty leaves them off.
  final List<String> tabs;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          padding: const EdgeInsets.only(top: 56, bottom: 28),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColor.skeletonHeroTop, AppColor.white],
            ),
          ),
          child: Column(
            children: [
              const SkeletonCircle(size: 88),
              const SizedBox(height: 22),
              const SkeletonBlock(width: 220, height: 20),
              const SizedBox(height: 10),
              const SkeletonBlock(width: 140, height: 14, soft: true),
              const SizedBox(height: 16),
              const SkeletonBlock(width: 180, height: 12, soft: true),
              const SizedBox(height: 26),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: const [
                    Expanded(
                      child: SkeletonBlock(width: null, height: 52, radius: 16),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: SkeletonBlock(
                        width: null,
                        height: 52,
                        soft: true,
                        radius: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (tabs.isNotEmpty) _SkeletonTabs(labels: tabs),
        const SizedBox(height: 20),
        for (var index = 0; index < 4; index++) ...[
          if (index > 0)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                height: 1,
                thickness: 1,
                color: AppColor.discoveryBorder,
              ),
            ),
          const _SkeletonProfileRow(),
        ],
      ],
    );
  }
}

/// The real tab strip over a blank body — the app's furniture stays.
class _SkeletonTabs extends StatelessWidget {
  const _SkeletonTabs({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                for (final (index, label) in labels.indexed) ...[
                  if (index > 0) const Spacer(),
                  Text(
                    label,
                    style: index == 0
                        ? DiscoveryText.tabActive
                        : DiscoveryText.tabInactive,
                  ),
                ],
              ],
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: Divider(
              height: 1,
              thickness: 1,
              color: AppColor.discoveryBorder,
            ),
          ),
        ],
      ),
    );
  }
}

/// One row under a profile's tabs: a name, a line under it, a price.
class _SkeletonProfileRow extends StatelessWidget {
  const _SkeletonProfileRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBlock(width: 170, height: 13),
                SizedBox(height: 9),
                SkeletonBlock(width: 220, height: 10, soft: true),
              ],
            ),
          ),
          SizedBox(width: 12),
          SkeletonBlock(width: 60, height: 13),
        ],
      ),
    );
  }
}
