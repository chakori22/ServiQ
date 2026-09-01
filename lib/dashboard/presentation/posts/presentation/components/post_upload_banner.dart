import 'dart:io';

import 'package:flutter/material.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/dashboard/model/post_draft.dart';

/// The strip that sits above the feed while a post is being uploaded.
///
/// It shows the photo the user picked, how far the upload has got, and a
/// gradient bar that fills as it goes — the point being to tell the user the
/// app has to stay open for the post to finish.
class PostUploadBanner extends StatelessWidget {
  const PostUploadBanner({
    super.key,
    required this.draft,
    required this.progress,
    required this.progressText,
  });

  final PostDraft draft;

  /// Upload progress from 0 to 1.
  final double progress;

  /// The same progress as the banner's label, e.g. "53.0%".
  final String progressText;

  /// Height of the thumbnail; the width keeps a portrait 3:4 crop.
  static const double _thumbnailHeight = 64;

  @override
  Widget build(BuildContext context) {
    return Container(
      // Extra room up top so the banner reads as its own strip rather than
      // running straight into the app bar, which shares its background.
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 16),
      decoration: const BoxDecoration(
        //color: AppColor.indicativeBlueColor50,
        border: Border(
          bottom: BorderSide(color: AppColor.neutralGreyColor100),
        ),
      ),
      child: Row(
        children: [
          _Thumbnail(imagePath: draft.imagePath, height: _thumbnailHeight),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Keep ServiQ open to finish posting  •  $progressText',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColor.neutralGreyColor600,
                  ),
                ),
                const SizedBox(height: 10),
                _ProgressBar(progress: progress),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Preview of the photo being uploaded. The path comes from the image picker,
/// so it is a file on disk rather than a bundled asset; a picture that can no
/// longer be read falls back to a plain placeholder instead of an error box.
class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.imagePath, required this.height});

  final String imagePath;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: height * 3 / 4,
        height: height,
        child: imagePath.isEmpty
            ? const _ThumbnailPlaceholder()
            : Image.file(
                File(imagePath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const _ThumbnailPlaceholder(),
              ),
      ),
    );
  }
}

class _ThumbnailPlaceholder extends StatelessWidget {
  const _ThumbnailPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.neutralGreyColor100,
      child: const Icon(
        Icons.image_outlined,
        size: 20,
        color: AppColor.neutralGreyColor400,
      ),
    );
  }
}

/// Thin gradient bar that fills left to right with the upload.
///
/// The percentage arrives in steps as the upload reports it, so the fill is
/// tweened between values — otherwise the bar visibly jumps.
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress});

  final double progress;

  static const double _height = 4;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_height),
      child: SizedBox(
        height: _height,
        width: double.infinity,
        child: Stack(
          children: [
            Container(color: AppColor.neutralGreyColor100),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress.clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: value,
                  child: child,
                );
              },
              // SizedBox.expand so the gradient takes the bar's full height;
              // a bare DecoratedBox with no child would collapse to nothing.
              child: const SizedBox.expand(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColor.indicativeBlueColor500,
                        AppColor.indicativePurpleColor500,
                        AppColor.accentColor,
                      ],
                    ),
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
