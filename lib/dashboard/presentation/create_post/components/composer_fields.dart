import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import 'package:local_markerplace/components/motion/entrance.dart';
import 'package:local_markerplace/components/primary_button.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/dashboard/model/post_priority.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_assets.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';

/// One labelled row of the composer: the design's small caps heading over
/// whatever collects the answer.
class ComposerField extends StatelessWidget {
  const ComposerField({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label, style: DiscoveryText.fieldLabel),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

/// The 96pt square that takes the requirement's photo — a dashed target
/// while it is empty, the picture itself once one is chosen.
class PhotoUploadTile extends StatelessWidget {
  const PhotoUploadTile({
    super.key,
    required this.image,
    required this.onPick,
    required this.onRemove,
  });

  final File? image;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  static const double _size = 96;

  @override
  Widget build(BuildContext context) {
    final picked = image;

    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: _size,
        height: _size,
        child: picked == null
            ? PressableScale(
                onTap: onPick,
                pressedScale: 0.94,
                child: CustomPaint(
                  painter: const DashedBorderPainter(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColor.discoveryTint,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.photo_camera_outlined,
                          size: 24,
                          color: AppColor.discoveryTextTertiary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add',
                          style: DiscoveryText.smallPrint.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColor.discoveryTextTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      picked,
                      width: _size,
                      height: _size,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    right: -6,
                    top: -6,
                    child: PressableScale(
                      onTap: onRemove,
                      pressedScale: 0.85,
                      child: Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColor.discoveryInk,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColor.white, width: 1.6),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 13,
                          color: AppColor.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// How far the requirement will be pushed, and the way to change it.
class PriorityRow extends StatelessWidget {
  const PriorityRow({super.key, required this.priority, required this.onTap});

  final PostPriority priority;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      pressedScale: 0.98,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.6, vertical: 10),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColor.discoveryBorder, width: 1.4),
        ),
        child: Row(
          children: [
            Icon(
              Icons.bolt_rounded,
              size: 22,
              color: priority.amount == 0
                  ? AppColor.discoveryTextTertiary
                  : AppColor.discoveryAccent,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(priority.label, style: DiscoveryText.rowTitle),
                  const SizedBox(height: 3),
                  Text(
                    priority.summary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: DiscoveryText.smallPrint,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              priority.priceLabel,
              style: DiscoveryText.rowCount.copyWith(
                fontSize: 13.5,
                color: priority.amount == 0
                    ? AppColor.discoveryTextSecondary
                    : AppColor.discoveryGradientEnd,
              ),
            ),
            const SizedBox(width: 10),
            SvgPicture.asset(
              DiscoveryAssets.chevronRight,
              width: 5,
              height: 11,
            ),
          ],
        ),
      ),
    );
  }
}

/// The composer's pinned call to action.
class ComposerFooter extends StatelessWidget {
  const ComposerFooter({
    super.key,
    required this.enabled,
    required this.onPost,
    this.label = 'Post requirement',
  });

  final bool enabled;
  final VoidCallback onPost;

  /// The design labels this "Continue", which there leads on to the priority
  /// picker. Nothing follows it here, so it says what it actually does.
  final String label;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: const BoxDecoration(
          color: AppColor.white,
          border: Border(top: BorderSide(color: AppColor.discoveryBorder)),
        ),
        child: PrimaryButton(
          label: label,
          enabled: enabled,
          gradient: true,
          height: 56,
          gradientColors: const [
            AppColor.discoveryGradientStart,
            AppColor.discoveryGradientEnd,
          ],
          labelStyle: enabled
              ? DiscoveryText.onAccent(16.5, letterSpacing: -0.165)
              : DiscoveryText.buttonDisabled,
          onPressed: onPost,
        ),
      ),
    );
  }
}

/// Asks whether the photo comes from the camera or the gallery.
///
/// Returns null when the sheet is dismissed without choosing.
Future<ImageSource?> showPhotoSourceSheet(BuildContext context) {
  return showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: AppColor.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: AppColor.discoveryBorder,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 18),
          _PhotoSourceOption(
            icon: Icons.photo_camera_outlined,
            label: 'Take a photo',
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          _PhotoSourceOption(
            icon: Icons.photo_library_outlined,
            label: 'Choose from gallery',
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
          const SizedBox(height: 12),
        ],
      ),
    ),
  );
}

class _PhotoSourceOption extends StatelessWidget {
  const _PhotoSourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 58,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColor.discoveryAccent),
              const SizedBox(width: 14),
              Text(label, style: DiscoveryText.sheetOption),
            ],
          ),
        ),
      ),
    );
  }
}

/// The dashed outline around an empty upload target.
class DashedBorderPainter extends CustomPainter {
  const DashedBorderPainter({this.radius = 16});

  /// Corner radius the dashes follow — 16 on the upload tile, 18 on the
  /// requirement's empty panel.
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColor.uploadDashedBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(16)),
      );

    // Walks the rounded rectangle and draws a 6pt dash every 11pt.
    for (final metric in outline.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 6), paint);
        distance += 11;
      }
    }
  }

  @override
  bool shouldRepaint(DashedBorderPainter oldDelegate) =>
      oldDelegate.radius != radius;
}
