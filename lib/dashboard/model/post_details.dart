class PostDetails {
  /// Unique identifier for the post (e.g. Firestore doc id / DB primary key)

  /// Username of the person who created the post
  final String username;

  /// URL / asset path for the user's profile avatar
  final String userAvatarUrl;

  /// When the post was created — used to derive "15 mins ago" style text
  final DateTime postedAt;

  /// URL / asset path for the post's image
  final String imageUrl;

  /// Description / task details written by the user
  final String description;

  /// Budget amount offered for the task
  final double budgetAmount;

  /// How the budget will be paid (e.g. "Cash", "UPI", "Card")
  final String paymentMode;

  /// Whether this is an instant request or a scheduled one
  final bool isInstant;

  /// The time the task is scheduled for.
  /// If [isInstant] is true, pass [postedAt] (or DateTime.now()) here as a
  /// placeholder, since the field is mandatory regardless of instant status.
  final DateTime? scheduledTime;

  /// Number of people who have accepted this task
  final int acceptCount;

  /// Number of chat messages / replies on this post
  final int chatCount;

  final bool isExpanded;

  const PostDetails({
    required this.username,
    required this.userAvatarUrl,
    required this.postedAt,
    required this.imageUrl,
    required this.description,
    required this.budgetAmount,
    required this.paymentMode,
    required this.isInstant,
    required this.scheduledTime,
    required this.acceptCount,
    required this.chatCount,
    this.isExpanded = false,
  });

  /// Human-readable "time ago" string for the post card header,
  /// e.g. "15 mins ago", "2 hours ago", "3 days ago".
  String get timeAgoText {
    final Duration diff = DateTime.now().difference(postedAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }

  /// Formatted budget string for display, e.g. "₹500 (Cash)"
  String get budgetText => '₹${budgetAmount.toStringAsFixed(0)} ($paymentMode)';

  /// Timing string for the bottom sheet, matching existing UI copy
  String get timingText => isInstant
      ? 'Instant Service Needed'
      : 'Scheduled: ${_formatScheduledTime(scheduledTime ?? DateTime.now())}';

  static String _formatScheduledTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return 'Today, $hour:$minute $period';
  }

  factory PostDetails.fromJson(Map<String, dynamic> json) {
    return PostDetails(
      username: json['username'] as String,
      userAvatarUrl: json['userAvatarUrl'] as String,
      postedAt: DateTime.parse(json['postedAt'] as String),
      imageUrl: json['imageUrl'] as String,
      description: json['description'] as String,
      budgetAmount: (json['budgetAmount'] as num).toDouble(),
      paymentMode: json['paymentMode'] as String,
      isInstant: json['isInstant'] as bool,
      scheduledTime: json['scheduledTime'] != null
          ? DateTime.parse(json['scheduledTime'] as String)
          : null,
      acceptCount: json['acceptCount'] as int,
      chatCount: json['chatCount'] as int,
      isExpanded: json['isExpanded'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'userAvatarUrl': userAvatarUrl,
      'postedAt': postedAt.toIso8601String(),
      'imageUrl': imageUrl,
      'description': description,
      'budgetAmount': budgetAmount,
      'paymentMode': paymentMode,
      'isInstant': isInstant,
      'scheduledTime': scheduledTime?.toIso8601String(),
      'acceptCount': acceptCount,
      'chatCount': chatCount,
      'isExpanded': isExpanded,
    };
  }

  PostDetails copyWith({
    String? username,
    String? userAvatarUrl,
    DateTime? postedAt,
    String? imageUrl,
    String? description,
    double? budgetAmount,
    String? paymentMode,
    bool? isInstant,
    DateTime? scheduledTime,
    int? acceptCount,
    int? chatCount,
    bool? isExpanded,
  }) {
    return PostDetails(
      username: username ?? this.username,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      postedAt: postedAt ?? this.postedAt,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      budgetAmount: budgetAmount ?? this.budgetAmount,
      paymentMode: paymentMode ?? this.paymentMode,
      isInstant: isInstant ?? this.isInstant,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      acceptCount: acceptCount ?? this.acceptCount,
      chatCount: chatCount ?? this.chatCount,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}
