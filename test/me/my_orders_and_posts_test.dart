import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:local_markerplace/dashboard/model/post_details.dart';
import 'package:local_markerplace/dashboard/model/post_status.dart';
import 'package:local_markerplace/dashboard/presentation/posts/presentation/components/requirement_card.dart';
import 'package:local_markerplace/dashboard/presentation/posts/presentation/my_posts_page.dart';
import 'package:local_markerplace/dashboard/repository/dashboard_repository.dart';
import 'package:local_markerplace/dashboard/repository/post_board_repository.dart';
import 'package:local_markerplace/visit/model/visit_mode.dart';
import 'package:local_markerplace/visit/model/visit_service.dart';
import 'package:local_markerplace/visit/presentation/my_orders_page.dart';
import 'package:local_markerplace/visit/repository/visit_repository.dart';

const shahnaz = 'Shahnaz RO & Chimney';

/// A repository with one booking already made.
VisitRepository withOrder() {
  final visits = VisitRepository()
    ..addService(
      providerName: shahnaz,
      providerLine: 'Ajnara Gen X · usually replies in 10 min',
      service: const VisitService(
        name: 'RO Filter Change',
        detail: '',
        unitPrice: 349,
      ),
    )
    ..setMode(shahnaz, VisitMode.instant);
  visits.confirm(shahnaz);
  return visits;
}

Future<void> loadFonts() async {
  for (final path in const [
    'assets/fonts/Mulish-Medium.ttf',
    'assets/fonts/Mulish-Bold.ttf',
    'assets/fonts/Mulish-ExtraBold.ttf',
  ]) {
    final loader = FontLoader('Mulish')
      ..addFont(File(path).readAsBytes().then((b) => ByteData.view(b.buffer)));
    await loader.load();
  }
}

/// Waits for a screen's fetch to land.
///
/// `pumpAndSettle` is not enough on its own any more: a still skeleton
/// schedules no frames, so settling returns before the pending future has
/// been given any time. The clock has to be advanced explicitly.
Future<void> settleFetch(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
}

Future<void> pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(390 * 3, 1100 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(useMaterial3: true, fontFamily: 'Mulish'),
      home: child,
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadFonts);
  setUp(PostBoardRepository.shared.clear);
  tearDown(PostBoardRepository.shared.clear);

  group('my orders', () {
    testWidgets('lists what has been booked', (tester) async {
      final visits = withOrder();
      await pump(tester, MyOrdersPage(repository: visits));

      expect(find.text('My orders'), findsOneWidget);
      expect(find.text('1 booking'), findsOneWidget);
      expect(find.textContaining('ORDER SQ-'), findsOneWidget);
      expect(find.text('BOOKED'), findsOneWidget);
      expect(find.text(shahnaz), findsOneWidget);
      expect(find.text('RO Filter Change'), findsOneWidget);
      // ₹349 for the job plus ₹99 for coming now.
      expect(find.text('₹448'), findsOneWidget);
    });

    testWidgets('with nothing booked it says so rather than showing zero', (
      tester,
    ) async {
      await pump(tester, MyOrdersPage(repository: VisitRepository()));

      expect(find.text('No orders yet'), findsOneWidget);
      expect(find.textContaining('ORDER'), findsNothing);
    });

    testWidgets('a second booking joins the history', (tester) async {
      final visits = withOrder()
        ..addService(
          providerName: 'Sharma Carpentry',
          providerLine: 'Ajnara Gen X',
          service: const VisitService(
            name: 'Furniture Repair',
            detail: '',
            unitPrice: 399,
          ),
        )
        ..setMode('Sharma Carpentry', VisitMode.instant);
      visits.confirm('Sharma Carpentry');

      await pump(tester, MyOrdersPage(repository: visits));

      expect(find.text('2 bookings'), findsOneWidget);
      expect(find.text(shahnaz), findsOneWidget);
      expect(find.text('Sharma Carpentry'), findsOneWidget);
    });
  });

  group('my posts', () {
    testWidgets('groups the posts the seeker made, by status', (tester) async {
      await pump(tester, const MyPostsPage(localityName: 'Ajnara Gen X'));
      await settleFetch(tester);

      expect(find.text('My posts'), findsOneWidget);
      // Three chips, each with its own count.
      for (final status in PostStatus.values) {
        expect(find.textContaining(status.label), findsWidgets);
      }
      // Signed out, none of the board's posts are the seeker's.
      expect(find.text('No open posts'), findsOneWidget);
    });

    testWidgets('the chips narrow to one status at a time', (tester) async {
      await pump(tester, const MyPostsPage(localityName: 'Ajnara Gen X'));
      await settleFetch(tester);

      await tester.tap(find.textContaining('Accepted'));
      await tester.pumpAndSettle();
      expect(find.text('No accepted posts'), findsOneWidget);

      await tester.tap(find.textContaining('Closed'));
      await tester.pumpAndSettle();
      expect(find.text('No closed posts'), findsOneWidget);
    });
  });

  group('a closed post', () {
    testWidgets('is marked closed on the card, not left reading open', (
      tester,
    ) async {
      // Built here rather than fetched: awaiting the repository inside a
      // widget test blocks on the fake clock.
      final post = PostDetails(
        username: 'me',
        userAvatarUrl: '',
        postedAt: DateTime.now().subtract(const Duration(minutes: 20)),
        imageUrl: 'assets/images/marketplace.png',
        description: 'AC not cooling, makes noise.',
        budgetAmount: 1500,
        paymentMode: 'Cash',
        isInstant: true,
        scheduledTime: null,
        acceptCount: 3,
        chatCount: 0,
      );

      await pump(
        tester,
        Scaffold(
          body: RequirementCard(
            post: post.copyWith(isClosed: true),
            onTap: () {},
          ),
        ),
      );

      expect(find.text('CLOSED'), findsOneWidget);
      expect(find.text('OPEN'), findsNothing);
      expect(find.text('Closed'), findsOneWidget);
    });
  });

  group('post status', () {
    test('closed wins over accepted', () async {
      const repository = DashboardRepository();
      final result = await repository.getPostDetails(currentUsername: 'me');
      final posts = result.getOrElse(() => []);

      final open = posts.firstWhere((post) => !post.isAccepted);
      expect(open.status, PostStatus.open);

      final accepted = posts.firstWhere((post) => post.isAccepted);
      expect(accepted.status, PostStatus.accepted);
      // Taking it down overrides that: it is off the board either way.
      expect(accepted.copyWith(isClosed: true).status, PostStatus.closed);
    });

    test('closing is remembered when the board is reopened', () async {
      const repository = DashboardRepository();
      final store = PostBoardRepository();
      final result = await repository.getPostDetails(currentUsername: 'me');
      final posts = result.getOrElse(() => []);

      final target = posts.firstWhere((post) => !post.isClosed);
      store.close(target);

      final again = store.apply(posts);
      final reopened = again.firstWhere((post) => post.key == target.key);
      expect(reopened.isClosed, isTrue);
      expect(reopened.status, PostStatus.closed);
      // Only that one: the seed's other open posts are untouched.
      expect(
        again.where((post) => post.isClosed).length,
        posts.where((post) => post.isClosed).length + 1,
      );
    });
  });
}
