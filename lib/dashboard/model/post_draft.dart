import 'package:equatable/equatable.dart';
import 'package:local_markerplace/dashboard/model/post_details.dart';

/// Username stamped on posts this device creates.
///
/// TODO: read the signed-in user from the session once auth is wired up.
const String kCurrentUsername = 'chakorichaturvedi';

/// A post the user has finished filling in on one of the create-post forms
/// but that has not reached the server yet.
///
/// The forms hand this to the posts page on "Share": the upload outlives the
/// form (which is popped immediately), so the draft has to travel with the
/// navigation rather than staying in the form's bloc.
class PostDraft extends Equatable {
  /// Category chosen in the dropdown, or the free-text value the user typed
  /// when they picked "Others".
  final String category;

  final String description;

  /// Raw budget text as typed, e.g. "500".
  final String budget;

  /// Local file path from the image picker — not a bundled asset.
  final String imagePath;

  /// True for "Get Instant Service", false for "Schedule for Later".
  final bool isInstant;

  /// Start of the booked window; null on instant posts.
  final DateTime? scheduledTime;

  const PostDraft({
    required this.category,
    required this.description,
    required this.budget,
    required this.imagePath,
    required this.isInstant,
    this.scheduledTime,
  });

  double get budgetAmount => double.tryParse(budget.trim()) ?? 0;

  /// The feed entry this draft becomes once the upload finishes.
  PostDetails toPostDetails() {
    return PostDetails(
      username: kCurrentUsername,
      userAvatarUrl: '',
      postedAt: DateTime.now(),
      imageUrl: imagePath,
      description: description,
      budgetAmount: budgetAmount,
      // TODO: collect the payment mode on the form; cash is the stand-in.
      paymentMode: 'Cash',
      isInstant: isInstant,
      scheduledTime: scheduledTime,
      acceptCount: 0,
      chatCount: 0,
    );
  }

  @override
  List<Object?> get props => [
    category,
    description,
    budget,
    imagePath,
    isInstant,
    scheduledTime,
  ];
}
