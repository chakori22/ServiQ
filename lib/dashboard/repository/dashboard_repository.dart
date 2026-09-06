import 'package:local_markerplace/dashboard/model/post_details.dart';
import 'package:local_markerplace/dashboard/model/post_draft.dart';
import 'package:local_markerplace/dashboard/model/services.dart';
import 'package:local_markerplace/dashboard/model/time_slot.dart';
import 'package:local_markerplace/dashboard/model/your_post.dart';
import 'package:local_markerplace/network/failure.dart';
import 'package:dartz/dartz.dart'; // add this import for Either

class DashboardRepository {
  const DashboardRepository();

  Future<bool> login(String mobileNumber) async {
    // TODO: replace with a real authentication API call.
    await Future.delayed(const Duration(seconds: 1));
    return mobileNumber.isNotEmpty;
  }

  Future<Either<Failure, List<PostDetails>>> getPostDetails({
    String? currentUsername,
  }) async {
    // TODO: replace with a real API call (e.g. GET /posts).
    await Future.delayed(const Duration(seconds: 1));

    // The board is the one screen where the states have to be visible side
    // by side — open with offers, open with none, and already settled — so
    // the seed carries one of each rather than five of the same. Three are
    // posted by the same handle, which is what the "Mine" filter matches
    // against once somebody is signed in as them.
    final now = DateTime.now();

    // Three of these are the seeker's own, so the board's "Mine" chip shows
    // the same spread of states the full board does — one taking offers,
    // one settled, one still waiting. A real endpoint would say who owns
    // what; until then they follow whoever is signed in.
    final me = currentUsername?.trim().isNotEmpty ?? false
        ? currentUsername!.trim()
        : 'chakorichaturvedi';

    final post = [
      PostDetails(
        username: me,
        userAvatarUrl: 'assets/images/avatar1.png',
        postedAt: now.subtract(const Duration(minutes: 20)),
        imageUrl: 'assets/images/marketplace.png',
        description:
            'AC not cooling, makes noise. Split AC in the bedroom is running '
            'but not cooling, and there is a rattling sound from the outdoor '
            'unit. Bought in 2023, last serviced a year ago.',
        budgetAmount: 1500,
        paymentMode: 'Cash',
        isInstant: true,
        scheduledTime: null,
        acceptCount: 3,
        chatCount: 2,
      ),
      PostDetails(
        username: 'rahul_verma',
        userAvatarUrl: 'assets/images/avatar2.png',
        postedAt: now.subtract(const Duration(hours: 2)),
        imageUrl: 'assets/images/marketplace2.png',
        description:
            'Chimney deep clean before Diwali. Kitchen chimney has not been '
            'serviced in two years and the suction has dropped.',
        budgetAmount: 800,
        paymentMode: 'UPI',
        isInstant: false,
        scheduledTime: now.add(const Duration(days: 3)),
        acceptCount: 0,
        chatCount: 0,
      ),
      PostDetails(
        username: me,
        userAvatarUrl: 'assets/images/avatar1.png',
        postedAt: now.subtract(const Duration(days: 1)),
        imageUrl: 'assets/images/marketplace.png',
        description:
            'Need a carpenter for wardrobe repair. One of the sliding doors '
            'has come off its runner and does not close.',
        budgetAmount: 1200,
        paymentMode: 'Cash',
        isInstant: false,
        scheduledTime: now.add(const Duration(days: 1)),
        acceptCount: 2,
        chatCount: 1,
        isAccepted: true,
        acceptedBy: 'Sharma Carpentry',
      ),
      PostDetails(
        username: 'neha_s',
        userAvatarUrl: 'assets/images/avatar2.png',
        postedAt: now.subtract(const Duration(days: 1, hours: 4)),
        imageUrl: 'assets/images/marketplace2.png',
        description:
            'RO service, water tastes off. Filters were last changed around '
            'eight months ago.',
        budgetAmount: 800,
        paymentMode: 'UPI',
        isInstant: true,
        scheduledTime: null,
        acceptCount: 1,
        chatCount: 0,
      ),
      PostDetails(
        username: me,
        userAvatarUrl: 'assets/images/avatar1.png',
        postedAt: now.subtract(const Duration(hours: 5)),
        imageUrl: 'assets/images/marketplace.png',
        description:
            'Washing machine not draining. It fills and spins but the water '
            'stays in the drum at the end of the cycle.',
        budgetAmount: 600,
        paymentMode: 'Cash',
        isInstant: true,
        scheduledTime: null,
        acceptCount: 0,
        chatCount: 0,
      ),
    ];
    return Right(post);
  }

  Future<Either<Failure, List<YourPostDetails>>> getYourPostDetails() async {
    // TODO: replace with a real API call (e.g. GET /posts).
    await Future.delayed(const Duration(seconds: 1));

    final post = [
      YourPostDetails(
        username: 'chakorichaturvedi',
        userAvatarUrl: 'assets/images/avatar1.png',
        postedAt: DateTime(2026, 1, 1),
        imageUrl: 'assets/images/marketplace2.png',
        description:
            'Kitchen sink is leaking from underneath, need someone today to come fix the pipe. Will pay in cash. Should take about an hour.',
        budgetAmount: 500,
        paymentMode: 'Cash',
        isInstant: true,
        scheduledTime: DateTime.now(),
        chatCount: 2,
      ),
      YourPostDetails(
        username: 'rahul_verma',
        userAvatarUrl: 'assets/images/avatar2.png',
        postedAt: DateTime(2026, 4, 26),
        imageUrl: 'assets/images/marketplace2.png',
        description:
            'Need help assembling a new wardrobe delivered yesterday. Should take about an hour.',
        budgetAmount: 350,
        paymentMode: 'UPI',
        isInstant: false,
        scheduledTime: DateTime.now().add(const Duration(hours: 4)),
        chatCount: 0,
      ),
      YourPostDetails(
        username: 'chakorichaturvedi',
        userAvatarUrl: 'assets/images/avatar1.png',
        postedAt: DateTime(2026, 9, 20),
        imageUrl: 'assets/images/marketplace2.png',
        description:
            'Kitchen sink is leaking from underneath, need someone today to come fix the pipe. Will pay in cash.',
        budgetAmount: 500,
        paymentMode: 'Cash',
        isInstant: true,
        scheduledTime: DateTime(2026, 9, 21),
        chatCount: 2,
      ),
    ];
    return Right(post);
  }

  Future<Either<Failure, List<ServiceDetails>>> getServiceDetails() async {
    // TODO: replace with a real API call (e.g. GET /posts).
    await Future.delayed(const Duration(seconds: 1));

    final services = [
      ServiceDetails(
        imageUrl: 'assets/images/carpenter.svg',
        price: '500',
        title: 'Carpenter',
        isSelected: true,
      ),
      ServiceDetails(
        imageUrl: 'assets/images/cleaner.svg',
        price: '350',
        title: 'Cleaner',
        isSelected: true,
      ),
      ServiceDetails(
        imageUrl: 'assets/images/electrician.svg',
        price: '500',
        title: 'Electrician',
      ),
      ServiceDetails(
        imageUrl: 'assets/images/plumber.svg',
        price: '500',
        title: 'Plumber',
      ),
      ServiceDetails(
        imageUrl: 'assets/images/mechanic.svg',
        price: '500',
        title: 'Mechanic',
      ),
      ServiceDetails(
        imageUrl: 'assets/images/serviq_trusted_providers.svg',
        price: '500',
        title: 'Kitchen sink repair',
      ),
      ServiceDetails(
        imageUrl: 'assets/images/plumber.svg',
        price: '500',
        title: 'Tutor',
      ),
      ServiceDetails(
        imageUrl: 'assets/images/mechanic.svg',
        price: '500',
        title: 'Delivery',
      ),
      ServiceDetails(
        imageUrl: 'assets/images/serviq_trusted_providers.svg',
        price: '500',
        title: 'Ac repair',
      ),
    ];
    return Right(services);
  }

  /// Bookable windows for [date], for the "Schedule for Later" form.
  ///
  /// Availability is per-date and server-owned, so this is refetched every
  /// time the user picks a different day.
  Future<Either<Failure, List<TimeSlot>>> getAvailableTimeSlots(
    DateTime date,
  ) async {
    // TODO: replace with a real API call (e.g. GET /slots?date=yyyy-MM-dd).
    await Future.delayed(const Duration(seconds: 1));

    final day = DateTime(date.year, date.month, date.day);
    final now = DateTime.now();
    final slots = <TimeSlot>[];
    for (int hour = 9; hour < 18; hour++) {
      final start = day.add(Duration(hours: hour));
      slots.add(
        TimeSlot(
          id: 'slot-${day.day}-$hour',
          startTime: start,
          endTime: start.add(const Duration(hours: 1)),
          // Windows already past, and a couple of stand-in bookings.
          isAvailable: start.isAfter(now) && hour != 13 && hour != 16,
        ),
      );
    }
    return Right(slots);
  }

  /// Uploads a post the user just created, reporting how far along it is.
  ///
  /// Progress is a stream rather than a single future because the posts page
  /// shows a live percentage while the upload runs; the stream closing is
  /// what tells the caller the post is live.
  Stream<double> uploadPost(PostDraft draft) async* {
    // TODO: replace with a real multipart upload (e.g. POST /posts) and yield
    // Dio's onSendProgress ratio instead of these simulated ticks.
    const int steps = 20;
    for (int step = 1; step <= steps; step++) {
      await Future.delayed(const Duration(milliseconds: 150));
      yield step / steps;
    }
  }

  Future<Either<Failure, List<String>>> getCategories() async {
    // TODO: replace with a real API call (e.g. GET /categories).
    await Future.delayed(const Duration(seconds: 1));

    final categories = [
      'Plumbing',
      'Electrical',
      'Carpentry',
      'Cleaning',
      'Mechanic',
      'Kitchen sink repair',
      'Others',
    ];
    return Right(categories);
  }
}
