import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_assets.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';

/// What the seeker chose to do with their picture.
enum PictureAction { camera, gallery, remove }

/// 03 · Profile picture — picker.
///
/// The footnote is the point of the sheet: a profile photo is public, while
/// identity documents are not, and the two are easy to confuse.
class PicturePickerSheet extends StatelessWidget {
  const PicturePickerSheet({super.key, this.canRemove = true});

  final bool canRemove;

  static Future<PictureAction?> show(
    BuildContext context, {
    bool canRemove = true,
  }) {
    return showModalBottomSheet<PictureAction>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => PicturePickerSheet(canRemove: canRemove),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColor.discoveryBorder,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text('Profile picture', style: DiscoveryText.sheetTitle),
              const SizedBox(height: 20),
              _Option(
                label: 'Take a photo',
                glyph: const _CameraGlyph(),
                onTap: () => Navigator.of(context).pop(PictureAction.camera),
              ),
              const SizedBox(height: 12),
              _Option(
                label: 'Choose from gallery',
                glyph: const _GalleryGlyph(),
                onTap: () => Navigator.of(context).pop(PictureAction.gallery),
              ),
              if (canRemove) ...[
                const SizedBox(height: 12),
                _Option(
                  label: 'Remove current photo',
                  glyph: const _RemoveGlyph(),
                  isDanger: true,
                  onTap: () => Navigator.of(context).pop(PictureAction.remove),
                ),
              ],
              const SizedBox(height: 18),
              Center(
                child: Text(
                  'Photos are public. Identity documents are uploaded '
                  'privately under Identity verification.',
                  textAlign: TextAlign.center,
                  style: DiscoveryText.smallPrint.copyWith(
                    color: AppColor.discoveryTextTertiary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.label,
    required this.glyph,
    this.isDanger = false,
    this.onTap,
  });

  final String label;
  final Widget glyph;
  final bool isDanger;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColor.providerNoteFill,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isDanger
                    ? AppColor.kycRejectTint
                    : AppColor.providerChipFill,
                shape: BoxShape.circle,
              ),
              child: glyph,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: isDanger
                    ? DiscoveryText.sheetOptionDanger
                    : DiscoveryText.sheetOption,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Figma draws these three out of rectangles and ellipses rather than
/// vectors, so there is nothing to export — they are rebuilt the same way.
class _CameraGlyph extends StatelessWidget {
  const _CameraGlyph();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 22,
      child: Stack(
        children: [
          Positioned(
            left: 8,
            top: 0,
            child: Container(
              width: 8,
              height: 4,
              decoration: BoxDecoration(
                color: AppColor.discoveryAccent,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ),
          Positioned(
            top: 3,
            child: Container(
              width: 24,
              height: 18,
              decoration: BoxDecoration(
                border: Border.all(color: AppColor.discoveryAccent, width: 1.8),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Positioned(
            left: 8,
            top: 8,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColor.discoveryAccent,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryGlyph extends StatelessWidget {
  const _GalleryGlyph();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
      height: 14,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColor.discoveryAccent, width: 1.8),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Positioned(
            left: 3,
            top: 3,
            child: Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: AppColor.discoveryAccent,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RemoveGlyph extends StatelessWidget {
  const _RemoveGlyph();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(DiscoveryAssets.remove, width: 11, height: 11);
  }
}
