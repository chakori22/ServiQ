import 'package:flutter/material.dart';
import 'package:local_markerplace/app_color.dart';

class PostCard extends StatefulWidget {
  const PostCard({super.key});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isExpanded = false;
  final int characterLimit = 60;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
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
                        'chakorichaturvedi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColor.neutralGreyColor700,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '15 mins ago',
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
                  showDetailsBottomSheet(context, isInstant: false);
                  // Handle more options tap
                },
                child: Icon(Icons.more_vert),
              ),
            ],
          ),
          SizedBox(height: 8),
          Image.asset(
            'assets/images/marketplace.png',
            width: double.infinity,
            height: 200,
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
                  onTap: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                  child: Text(
                    // The description text
                    'Kitchen sink is leaking from underneath, need someone today to come fix the pipe. Will pay in cash.',
                    // 4. Toggle max lines based on state
                    maxLines: isExpanded ? null : 2,
                    // 5. Show standard '...' ellipsis if not expanded
                    overflow: isExpanded
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
                  SizedBox(width: 8),
                  Text(
                    'Accept',
                    style: TextStyle(
                      color: AppColor.neutralGreyColor700,
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

  void showDetailsBottomSheet(BuildContext context, {required bool isInstant}) {
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
                      const Text(
                        '₹500 (Cash)',
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
                            : 'Scheduled: Today, 4:00 PM',
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
}
