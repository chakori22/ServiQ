import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:local_markerplace/components/art/art_palette.dart';
import 'package:local_markerplace/components/art/seeded_artwork.dart';
import 'package:local_markerplace/components/motion/entrance.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/model/service_category.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';

/// One trade in home's category grid: a glyph on a white disc over a plate of
/// artwork generated from the trade's own name, with the name underneath.
///
/// Each trade therefore keeps its own colour wherever the grid is drawn,
/// which is what lets the seeker find "Plumber" by its look rather than by
/// reading all six labels.
class CategoryTile extends StatelessWidget {
  const CategoryTile({
    super.key,
    required this.category,
    this.onTap,
    this.index = 0,
  });

  final ServiceCategory category;
  final VoidCallback? onTap;

  /// Position in the grid. It staggers the tile's entrance, and picks the
  /// tile's colour family — the six trades are a fixed set drawn side by
  /// side, so they are handed one family each rather than being hashed into
  /// whatever they land on.
  final int index;

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      index: index,
      child: PressableScale(
        onTap: onTap,
        pressedScale: 0.94,
        child: Container(
          height: 92,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColor.discoveryBorder, width: 1.4),
            boxShadow: [
              BoxShadow(
                color: AppColor.discoveryShadow.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SeededArtwork(
            seed: category.label,
            palette: ArtPalette.familyAt(index),
            // A tile is small and carries a label, so its curves run softer
            // than a full-width cover's.
            intensity: 0.8,
            borderRadius: BorderRadius.circular(16.6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.discoveryShadow.withValues(alpha: 0.10),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: SvgPicture.asset(
                    category.iconAsset,
                    width: 22,
                    height: 22,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  category.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DiscoveryText.tileLabel,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
