import 'package:local_markerplace/dashboard/model/post_details.dart';
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

  Future<Either<Failure, List<PostDetails>>> getPostDetails() async {
    // TODO: replace with a real API call (e.g. GET /posts).
    await Future.delayed(const Duration(seconds: 1));

    final post = [
      PostDetails(
        username: 'chakorichaturvedi',
        userAvatarUrl: 'assets/images/avatar1.png',
        postedAt: DateTime(2026, 1, 1),
        imageUrl: 'assets/images/marketplace.png',
        description:
            'Kitchen sink is leaking from underneath, need someone today to come fix the pipe. Will pay in cash. Should take about an hour.',
        budgetAmount: 500,
        paymentMode: 'Cash',
        isInstant: true,
        scheduledTime: DateTime.now(),
        acceptCount: 3,
        chatCount: 2,
      ),
      PostDetails(
        username: 'rahul_verma',
        userAvatarUrl: 'assets/images/avatar2.png',
        postedAt: DateTime(2026, 4, 26),
        imageUrl: 'assets/images/marketplace.png',
        description:
            'Need help assembling a new wardrobe delivered yesterday. Should take about an hour.',
        budgetAmount: 350,
        paymentMode: 'UPI',
        isInstant: false,
        scheduledTime: DateTime.now().add(const Duration(hours: 4)),
        acceptCount: 1,
        chatCount: 0,
      ),
      PostDetails(
        username: 'chakorichaturvedi',
        userAvatarUrl: 'assets/images/avatar1.png',
        postedAt: DateTime(2026, 9, 20),
        imageUrl: 'assets/images/marketplace.png',
        description:
            'Kitchen sink is leaking from underneath, need someone today to come fix the pipe. Will pay in cash.',
        budgetAmount: 500,
        paymentMode: 'Cash',
        isInstant: true,
        scheduledTime: DateTime(2026, 9, 21),
        acceptCount: 3,
        chatCount: 2,
      ),
      PostDetails(
        username: 'chakorichaturvedi',
        userAvatarUrl: 'assets/images/avatar1.png',
        postedAt: DateTime(2026, 1, 3),
        imageUrl: 'assets/images/marketplace.png',
        description:
            'Kitchen sink is leaking from underneath, need someone today to come fix the pipe. Will pay in cash.',
        budgetAmount: 500,
        paymentMode: 'Cash',
        isInstant: true,
        scheduledTime: DateTime(2026, 1, 4),
        acceptCount: 3,
        chatCount: 2,
      ),
      PostDetails(
        username: 'chakorichaturvedi',
        userAvatarUrl: 'assets/images/avatar1.png',
        postedAt: DateTime(2026, 1, 4),
        imageUrl: 'assets/images/marketplace.png',
        description:
            'Kitchen sink is leaking from underneath, need someone today to come fix the pipe. Will pay in cash.',
        budgetAmount: 500,
        paymentMode: 'Cash',
        isInstant: false,
        scheduledTime: DateTime(2026, 1, 5),
        acceptCount: 3,
        chatCount: 2,
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
