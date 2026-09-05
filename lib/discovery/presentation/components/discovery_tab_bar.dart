import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_assets.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';

/// The five destinations along the bottom of the discovery screens. The
/// middle one is the raised post button rather than a tab, so it is not part
/// of [DiscoveryTab].
enum DiscoveryTab { home, explore, posts, me }

/// The flow's bottom bar: four tabs around a gradient post button that
/// overhangs the bar's top edge.
class DiscoveryTabBar extends StatelessWidget {
  const DiscoveryTabBar({
    super.key,
    required this.current,
    required this.onSelect,
    this.onPost,
  });

  final DiscoveryTab current;
  final ValueChanged<DiscoveryTab> onSelect;
  final VoidCallback? onPost;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.white,
        border: const Border(top: BorderSide(color: AppColor.discoveryBorder)),
        boxShadow: [
          BoxShadow(
            color: AppColor.discoveryShadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          // The post button sits 22pt above the bar, so nothing here may
          // clip its own children.
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _Tab(
                      tab: DiscoveryTab.home,
                      label: 'Home',
                      current: current,
                      onSelect: onSelect,
                    ),
                  ),
                  Expanded(
                    child: _Tab(
                      tab: DiscoveryTab.explore,
                      label: 'Explore',
                      current: current,
                      onSelect: onSelect,
                    ),
                  ),
                  // Keeps the middle column clear for the post button.
                  const Spacer(),
                  Expanded(
                    child: _Tab(
                      tab: DiscoveryTab.posts,
                      label: 'Posts',
                      current: current,
                      onSelect: onSelect,
                    ),
                  ),
                  Expanded(
                    child: _Tab(
                      tab: DiscoveryTab.me,
                      label: 'Me',
                      current: current,
                      onSelect: onSelect,
                    ),
                  ),
                ],
              ),
              Positioned(top: -22, child: _PostButton(onTap: onPost)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.tab,
    required this.label,
    required this.current,
    required this.onSelect,
  });

  final DiscoveryTab tab;
  final String label;
  final DiscoveryTab current;
  final ValueChanged<DiscoveryTab> onSelect;

  @override
  Widget build(BuildContext context) {
    final isActive = tab == current;

    return GestureDetector(
      onTap: () => onSelect(tab),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 20, height: 20, child: _icon(isActive)),
          const SizedBox(height: 6),
          Text(
            label,
            style: isActive
                ? DiscoveryText.tabActive
                : DiscoveryText.tabInactive,
          ),
        ],
      ),
    );
  }

  Widget _icon(bool isActive) {
    switch (tab) {
      case DiscoveryTab.home:
        return SvgPicture.asset(
          isActive
              ? DiscoveryAssets.tabHomeActive
              : DiscoveryAssets.tabHomeInactive,
        );
      case DiscoveryTab.explore:
        return SvgPicture.asset(
          isActive
              ? DiscoveryAssets.tabExploreActive
              : DiscoveryAssets.tabExploreInactive,
        );
      case DiscoveryTab.me:
        return SvgPicture.asset(DiscoveryAssets.tabMe);
      case DiscoveryTab.posts:
        // Figma draws this one out of rectangles rather than a vector, so
        // there is no exported glyph to load — it is rebuilt here the same
        // way, a bordered card with two lines of "text" inside.
        return _PostsGlyph(
          color: isActive
              ? AppColor.discoveryAccent
              : AppColor.discoveryTextDisabled,
        );
    }
  }
}

class _PostsGlyph extends StatelessWidget {
  const _PostsGlyph({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 1,
          child: Container(
            width: 20,
            height: 18,
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 2),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
        Positioned(left: 4, top: 6, child: _Line(color: color, width: 12)),
        Positioned(left: 4, top: 11, child: _Line(color: color, width: 8)),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.color, required this.width});

  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 2.4,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(1.2),
      ),
    );
  }
}

class _PostButton extends StatelessWidget {
  const _PostButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColor.discoveryGradientStart,
              AppColor.discoveryGradientEnd,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColor.discoveryGradientEnd.withValues(alpha: 0.42),
              blurRadius: 20,
              spreadRadius: -2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SvgPicture.asset(DiscoveryAssets.plus, width: 18, height: 18),
      ),
    );
  }
}
