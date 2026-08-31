import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/core/app_routes.dart';
import 'package:local_markerplace/dashboard/model/your_post.dart';

class DashboardYourPostCard extends StatefulWidget {
  final List<YourPostDetails> postDetailsList;

  const DashboardYourPostCard({super.key, required this.postDetailsList});

  @override
  State<DashboardYourPostCard> createState() => _YourPostCardState();
}

class _YourPostCardState extends State<DashboardYourPostCard> {
  late List<YourPostDetails> _posts;

  @override
  void initState() {
    super.initState();
    _posts = widget.postDetailsList;
  }

  @override
  void didUpdateWidget(DashboardYourPostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep local list in sync if the parent passes a new list (e.g. after
    // a bloc refetch), without wiping out any in-progress expand state
    // for posts that are still present.
    if (oldWidget.postDetailsList != widget.postDetailsList) {
      _posts = widget.postDetailsList;
    }
  }

  void _toggleExpanded(int index) {
    setState(() {
      _posts[index] = _posts[index].copyWith(
        isExpanded: !_posts[index].isExpanded,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.postDetailsList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Posts',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColor.neutralGreyColor700,
                  fontSize: 24,
                ),
              ),
              AnimatedScale(
                scale: 1.0,
                duration: const Duration(milliseconds: 300),
                child: TextButton(
                  onPressed: () =>
                      GoRouter.of(context).pushAppRoute(AppRoutes.yourPosts),
                  child: Row(
                    children: [
                      Text(
                        'View All',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColor.indicativeBlueColor400,
                          fontSize: 14,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: AppColor.indicativeBlueColor400,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 328,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: _posts.length,
            itemBuilder: (context, index) {
              final post = _posts[index];
              return SizedBox(
                width: 380,
                child: postCard(
                  post: post,
                  onToggleExpanded: () => _toggleExpanded(index),
                  context: context,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

Widget postCard({
  required YourPostDetails post,
  required VoidCallback onToggleExpanded,
  required BuildContext context,
}) {
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
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.username,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColor.neutralGreyColor700,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      getTimeAgo(post.postedAt),
                      style: TextStyle(
                        color: AppColor.neutralGreyColor600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                showDetailsBottomSheet(
                  context,
                  isInstant: post.isInstant,
                  budgetAmount: post.budgetAmount,
                  timing:
                      post.scheduledTime ??
                      DateTime.now(), // Provide a default value if null
                );
                // Handle more options tap
              },
              child: Icon(Icons.more_vert),
            ),
          ],
        ),
        SizedBox(height: 8),
        Image.asset(
          post.imageUrl,
          width: double.infinity,
          height: 160,
          fit: BoxFit.cover,
        ),
        SizedBox(height: 8),
        Row(
          // Changed to start so the username stays at the top if the description wraps to multiple lines
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 2. Wrap description in Expanded to prevent overflow errors
            Flexible(
              // 3. GestureDetector allows the user to tap the text to expand/collapse
              child: GestureDetector(
                onTap: onToggleExpanded,
                child: Text(
                  // The description text
                  post.description,
                  // 4. Toggle max lines based on state
                  maxLines: 2,
                  // 5. Show standard '...' ellipsis if not expanded
                  overflow: post.isExpanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColor.neutralGreyColor700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              Icons.people_alt_outlined,
              size: 16,
              color: AppColor.neutralGreyColor700,
            ),
            Text(
              ' ${post.chatCount} people responded',
              style: TextStyle(
                color: AppColor.neutralGreyColor700,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.edit_note_outlined,
                  size: 24,
                  color: AppColor.neutralGreyColor700,
                ),
                SizedBox(width: 4),
                Text(
                  'Edit',
                  style: TextStyle(
                    color: AppColor.neutralGreyColor700,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            SizedBox(width: 8),
            Row(
              children: [
                Icon(
                  Icons.delete_outline,
                  size: 24,
                  color: AppColor.neutralGreyColor700,
                ),
                SizedBox(width: 8),
                Text(
                  'Delete',
                  style: TextStyle(
                    color: AppColor.neutralGreyColor700,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}

String getTimeAgo(DateTime postedAt) {
  final now = DateTime.now();
  final difference = now.difference(postedAt);

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

void showDetailsBottomSheet(
  BuildContext context, {
  required bool isInstant,
  required double budgetAmount,
  required DateTime timing,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Allows the sheet to size itself properly
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Wraps content tightly
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar at the top for modern look
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

            // Budget Section
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.payments_outlined,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Budget',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    Text(
                      '₹${budgetAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Timing Section
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isInstant ? Icons.flash_on : Icons.schedule,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Timing',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    Text(
                      isInstant
                          ? 'Instant Service Needed'
                          : 'Scheduled: ${timing.day}/${timing.month}/${timing.year}, ${timing.hour}:${timing.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
