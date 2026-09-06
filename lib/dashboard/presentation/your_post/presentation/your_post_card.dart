import 'dart:io';

import 'package:flutter/material.dart';

import 'package:local_markerplace/components/motion/entrance.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/dashboard/model/your_post.dart';
import 'package:local_markerplace/dashboard/presentation/posts/presentation/components/requirement_card.dart'
    show scheduledLabel;
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/discovery/presentation/components/status_pill.dart';

/// One of the user's own posts, on the full Your Posts list.
///
/// The same requirement card the public board draws, with two things the
/// board's has not: the photo the user attached, which is theirs to check,
/// and the edit and delete actions. Owned by this module rather than shared
/// with the board, so the two can drift apart as the owner's view grows.
class YourPostCard extends StatelessWidget {
  const YourPostCard({
    super.key,
    required this.post,
    required this.onToggleExpanded,
    this.index = 0,
    this.onEdit,
    this.onDelete,
  });

  final YourPostDetails post;

  /// Fired when the requirement text is tapped, to expand or collapse it.
  final VoidCallback onToggleExpanded;

  /// Position in the list, which staggers the card's entrance.
  final int index;

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      index: index,
      child: Container(
        padding: const EdgeInsets.all(14.6),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColor.discoveryBorder, width: 1.4),
          boxShadow: [
            BoxShadow(
              color: AppColor.discoveryShadow.withValues(alpha: 0.05),
              blurRadius: 7,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PostThumbnail(imageUrl: post.imageUrl),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: onToggleExpanded,
                              child: Text(
                                post.description,
                                // Expanded means no limit — a line cap
                                // cannot be lifted by the overflow mode
                                // alone, so it has to go to null here.
                                maxLines: post.isExpanded ? null : 2,
                                overflow: post.isExpanded
                                    ? TextOverflow.visible
                                    : TextOverflow.ellipsis,
                                style: DiscoveryText.postTitle,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const StatusPill.open(),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _meta(post),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: DiscoveryText.footnoteStrong,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColor.discoveryBorder,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    post.chatCount == 0
                        ? 'No offers yet'
                        : '${post.chatCount} '
                              '${post.chatCount == 1 ? 'person' : 'people'} '
                              'responded',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: post.chatCount == 0
                        ? DiscoveryText.link.copyWith(
                            color: AppColor.discoveryTextTertiary,
                          )
                        : DiscoveryText.link,
                  ),
                ),
                const SizedBox(width: 10),
                Text(post.timeAgoText, style: DiscoveryText.timestamp),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _PostAction(label: 'Edit', onTap: onEdit),
                const SizedBox(width: 10),
                _PostAction(label: 'Delete', isDanger: true, onTap: onDelete),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// "₹500 · Cash · needed now", the same line the public board carries.
String _meta(YourPostDetails post) => [
  '₹${post.budgetAmount.toStringAsFixed(0)}',
  post.paymentMode,
  post.isInstant ? 'needed now' : scheduledLabel(post.scheduledTime),
].join(' · ');

/// The photo the user attached, which is a bundled asset for posts from the
/// API but a file on disk for one this device created.
class _PostThumbnail extends StatelessWidget {
  const _PostThumbnail({required this.imageUrl});

  final String imageUrl;

  static const double _size = 56;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: _size,
        height: _size,
        child: imageUrl.isEmpty
            ? const _ThumbnailPlaceholder()
            : imageUrl.startsWith('assets/')
            ? Image.asset(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const _ThumbnailPlaceholder(),
              )
            : Image.file(
                File(imageUrl),
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
    return const ColoredBox(
      color: AppColor.providerMapFill,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 20,
          color: AppColor.discoveryTextDisabled,
        ),
      ),
    );
  }
}

/// Edit / Delete at the foot of a card, drawn as the flow's small chips.
class _PostAction extends StatelessWidget {
  const _PostAction({required this.label, this.onTap, this.isDanger = false});

  final String label;
  final VoidCallback? onTap;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      pressedScale: 0.92,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDanger ? AppColor.kycRejectTint : AppColor.providerChipFill,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: DiscoveryText.addChip.copyWith(
            color: isDanger
                ? AppColor.kycRejectText
                : AppColor.discoveryGradientEnd,
          ),
        ),
      ),
    );
  }
}
