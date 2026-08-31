import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/dashboard/model/post_details.dart';
import 'package:local_markerplace/dashboard/repository/dashboard_repository.dart';
import 'package:shimmer/shimmer.dart';
import '../bloc/bloc/post_bloc.dart';

class PostPage extends StatelessWidget {
  const PostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PostBloc(dashboardRepository: const DashboardRepository()),
      child: const PostScreenContainer(),
    );
  }
}

class PostScreenContainer extends StatefulWidget {
  const PostScreenContainer({super.key});

  @override
  State<PostScreenContainer> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreenContainer> {
  @override
  void initState() {
    context.read<PostBloc>().add(const OnFetchPostDetails());
    super.initState();
  }

  void _toggleExpanded(int index) {
    setState(() {
      final postDetails = context.read<PostBloc>().state.postDetails;
      postDetails[index] = postDetails[index].copyWith(
        isExpanded: !postDetails[index].isExpanded,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            color: AppColor.indicativeBlueColor700,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        animateColor: true,
        backgroundColor: AppColor.indicativeBlueColor50,
        surfaceTintColor: AppColor.neutralGreyColor100,

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Post',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColor.indicativeBlueColor700,
              ),
            ),
          ],
        ),
      ),
      body: BlocBuilder<PostBloc, PostState>(
        builder: (context, state) {
          // if (state.postDetails.isEmpty) {
          //   return const SizedBox.shrink();
          // }

          return state.postsLoading
              ? Shimmer.fromColors(
                  baseColor: AppColor.indicativeBlueColor100,
                  highlightColor: AppColor.indicativeBlueColor50,
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.white,
                                ),
                                SizedBox(width: 4),

                                SizedBox(
                                  height: 12,
                                  width: screenWidth * 0.86,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              width: screenWidth * 0.95,
                              height: 240,
                              child: Container(color: Colors.white),
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              height: 12,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              : SizedBox(
                  //height: 304,
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    itemCount: state.postDetails.length,
                    itemBuilder: (context, index) {
                      final post = state.postDetails[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: SizedBox(
                          width: 380,
                          child: postCard(
                            post: post,
                            onToggleExpanded: () => _toggleExpanded(index),
                            context: context,
                          ),
                        ),
                      );
                    },
                  ),
                );
        },
      ),
    );
  }
}

Widget postCard({
  required PostDetails post,
  required VoidCallback onToggleExpanded,
  required BuildContext context,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                  maxLines: post.isExpanded ? null : 2,
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
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.add_task_rounded,
                  size: 24,
                  color: AppColor.neutralGreyColor700,
                ),
                SizedBox(width: 4),
                Text(
                  'Accept',
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
                  Icons.chat_bubble_outline,
                  size: 24,
                  color: AppColor.neutralGreyColor700,
                ),
                SizedBox(width: 8),
                Text(
                  'Chat',
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
