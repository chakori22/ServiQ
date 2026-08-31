import 'package:flutter/material.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/dashboard/model/your_post.dart';

/// One of the user's own posts, as shown on the full Your Posts list.
///
/// Visually the same card as the dashboard rail's, but owned by this module so
/// the page can evolve — different actions, a different layout — without
/// touching the dashboard component.
class YourPostCard extends StatelessWidget {
  const YourPostCard({
    super.key,
    required this.post,
    required this.onToggleExpanded,
  });

  final YourPostDetails post;

  /// Fired when the description is tapped, to expand or collapse it.
  final VoidCallback onToggleExpanded;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(backgroundColor: Colors.grey[300], radius: 20),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColor.neutralGreyColor700,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        timeAgo(post.postedAt),
                        style: const TextStyle(
                          color: AppColor.neutralGreyColor600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => showYourPostDetailsSheet(
                  context,
                  isInstant: post.isInstant,
                  budgetAmount: post.budgetAmount,
                  timing: post.scheduledTime ?? DateTime.now(),
                ),
                child: const Icon(Icons.more_vert),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Image.asset(
            post.imageUrl,
            width: double.infinity,
            height: 160,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 8),
          Row(
            // Start-aligned so the row keeps its top edge when the description
            // wraps to several lines.
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: GestureDetector(
                  onTap: onToggleExpanded,
                  child: Text(
                    post.description,
                    // Expanded means no limit — a line cap can't be lifted by
                    // the overflow mode alone, so it has to go to null here.
                    maxLines: post.isExpanded ? null : 2,
                    overflow: post.isExpanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColor.neutralGreyColor700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(
                Icons.people_alt_outlined,
                size: 16,
                color: AppColor.neutralGreyColor700,
              ),
              Text(
                ' ${post.chatCount} people responded',
                style: const TextStyle(
                  color: AppColor.neutralGreyColor700,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _PostAction(icon: Icons.edit_note_outlined, label: 'Edit'),
              SizedBox(width: 8),
              _PostAction(icon: Icons.delete_outline, label: 'Delete'),
            ],
          ),
        ],
      ),
    );
  }
}

/// Edit / Delete action at the foot of a card.
class _PostAction extends StatelessWidget {
  const _PostAction({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 24, color: AppColor.neutralGreyColor700),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColor.neutralGreyColor700,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

/// "15 mins ago" style stamp for a post's header.
String timeAgo(DateTime postedAt) {
  final difference = DateTime.now().difference(postedAt);

  if (difference.inSeconds < 60) {
    return 'Just now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes} mins ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours} hours ago';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} days ago';
  } else if (difference.inDays < 30) {
    return '${difference.inDays ~/ 7} weeks ago';
  } else if (difference.inDays < 365) {
    return '${difference.inDays ~/ 30} months ago';
  } else {
    return '${difference.inDays ~/ 365} years ago';
  }
}

/// Budget and timing for a post, opened from the card's overflow icon.
void showYourPostDetailsSheet(
  BuildContext context, {
  required bool isInstant,
  required double budgetAmount,
  required DateTime timing,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Task Requirements',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _DetailRow(
              icon: Icons.payments_outlined,
              iconColor: Colors.green,
              label: 'Budget',
              value: '₹${budgetAmount.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _DetailRow(
              icon: isInstant ? Icons.flash_on : Icons.schedule,
              iconColor: Colors.blue,
              label: 'Timing',
              value: isInstant
                  ? 'Instant Service Needed'
                  : 'Scheduled: ${timing.day}/${timing.month}/${timing.year}, '
                        '${timing.hour}:${timing.minute.toString().padLeft(2, '0')}',
            ),
          ],
        ),
      );
    },
  );
}

/// One labelled row of the details sheet.
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
