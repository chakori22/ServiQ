import 'package:flutter/material.dart';

import 'package:local_markerplace/components/motion/entrance.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/dashboard/model/post_details.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/discovery/presentation/components/provider_avatar.dart';
import 'package:local_markerplace/discovery/presentation/components/status_pill.dart';

/// One requirement on the posts board.
///
/// The design turns what used to be a photo-led feed post into a summary a
/// neighbour can scan: the requirement itself as the headline, its state as a
/// pill, one line of terms, and a footer weighing offers against how long it
/// has been waiting. The photo and the full terms move into the sheet the
/// card opens, so the board stays a list of asks rather than a gallery.
class RequirementCard extends StatelessWidget {
  const RequirementCard({
    super.key,
    required this.post,
    this.onTap,
    this.index = 0,
  });

  final PostDetails post;
  final VoidCallback? onTap;

  /// Position in the board, which staggers the card's entrance.
  final int index;

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      index: index,
      child: PressableScale(
        onTap: onTap,
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
                  Expanded(
                    child: Text(
                      requirementHeadline(post.description),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: DiscoveryText.postTitle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (post.isAccepted)
                    const StatusPill.accepted()
                  else
                    const StatusPill.open(),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                requirementMeta(post),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: DiscoveryText.footnoteStrong,
              ),
              const SizedBox(height: 12),
              _Author(username: post.username),
              const SizedBox(height: 12),
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColor.discoveryBorder,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _OffersLabel(post: post)),
                  const SizedBox(width: 10),
                  Text(post.timeAgoText, style: DiscoveryText.timestamp),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Kitchen sink is leaking from underneath, need someone today."
///
/// A post carries one block of text, while the design shows a headline over a
/// paragraph. The first sentence is the headline; anything after it becomes
/// the paragraph, so both read naturally without inventing a second field.
String requirementHeadline(String description) {
  final trimmed = description.trim();
  final end = trimmed.indexOf('. ');
  if (end == -1) return trimmed;
  return trimmed.substring(0, end + 1);
}

/// Whatever follows the headline, or null when there is only one sentence.
String? requirementDetail(String description) {
  final trimmed = description.trim();
  final end = trimmed.indexOf('. ');
  if (end == -1) return null;
  final rest = trimmed.substring(end + 2).trim();
  return rest.isEmpty ? null : rest;
}

/// Up to two letters from a handle, which has no spaces to split on the way
/// a person's name does.
String authorInitials(String username) {
  final trimmed = username.trim();
  if (trimmed.isEmpty) return '?';
  final words = trimmed.split(RegExp(r'[\s_.]+'));
  if (words.length > 1 && words[1].isNotEmpty) {
    return (words[0][0] + words[1][0]).toUpperCase();
  }
  return trimmed.substring(0, trimmed.length == 1 ? 1 : 2).toUpperCase();
}

/// Who is asking. A requirement is somebody's, not the board's, so the card
/// carries their mark and handle alongside the terms.
class _Author extends StatelessWidget {
  const _Author({required this.username});

  final String username;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ProviderAvatar(
          initials: authorInitials(username),
          seed: username,
          size: 22,
          isVerified: false,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            username,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: DiscoveryText.metaMuted,
          ),
        ),
      ],
    );
  }
}

/// "₹500 · Cash · needed now" — the design's one line of terms, built from
/// what a post actually carries.
String requirementMeta(PostDetails post) => [
  '₹${post.budgetAmount.toStringAsFixed(0)}',
  post.paymentMode,
  post.isInstant ? 'needed now' : scheduledLabel(post.scheduledTime),
].join(' · ');

/// "today, 4:30 PM" / "tomorrow, 9:00 AM" / "12 Sep, 9:00 AM".
String scheduledLabel(DateTime? at) {
  if (at == null) return 'scheduled';

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(at.year, at.month, at.day);
  final hour = at.hour % 12 == 0 ? 12 : at.hour % 12;
  final minute = at.minute.toString().padLeft(2, '0');
  final clock = '$hour:$minute ${at.hour >= 12 ? 'PM' : 'AM'}';

  final difference = day.difference(today).inDays;
  if (difference == 0) return 'today, $clock';
  if (difference == 1) return 'tomorrow, $clock';

  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${at.day} ${months[at.month - 1]}, $clock';
}

/// The footer's left half. An offer to read is the one thing on the card
/// worth acting on, so it is the only part drawn in the accent; a post still
/// waiting, or already settled, states that quietly instead.
class _OffersLabel extends StatelessWidget {
  const _OffersLabel({required this.post});

  final PostDetails post;

  @override
  Widget build(BuildContext context) {
    if (post.isAccepted) {
      final by = post.acceptedBy;
      return Text(
        by == null ? 'Accepted' : 'Accepted $by',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: DiscoveryText.link.copyWith(
          color: AppColor.discoveryTextTertiary,
        ),
      );
    }

    if (post.acceptCount == 0) {
      return Text(
        'No offers yet',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: DiscoveryText.link.copyWith(
          color: AppColor.discoveryTextTertiary,
        ),
      );
    }

    return Text(
      '${post.acceptCount} ${post.acceptCount == 1 ? 'offer' : 'offers'}',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: DiscoveryText.link,
    );
  }
}
