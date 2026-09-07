import 'dart:io';

import 'package:flutter/material.dart';
import 'package:local_markerplace/components/motion/entrance.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:local_markerplace/dashboard/model/post_details.dart';
import 'package:local_markerplace/dashboard/model/post_offer.dart';
import 'package:local_markerplace/dashboard/presentation/posts/bloc/bloc/post_bloc.dart';
import 'package:local_markerplace/dashboard/presentation/posts/presentation/requirement_page.dart';
import 'package:local_markerplace/dashboard/repository/dashboard_repository.dart';
import 'package:local_markerplace/dashboard/repository/post_board_repository.dart';
import 'package:local_markerplace/dashboard/repository/post_offer_repository.dart';
import 'package:local_markerplace/visit/repository/visit_repository.dart';

/// A requirement posted by [author], carrying [offers] offers.
PostDetails post({required String author, int offers = 3}) => PostDetails(
  username: author,
  userAvatarUrl: '',
  postedAt: DateTime.now().subtract(const Duration(minutes: 20)),
  imageUrl: 'assets/images/marketplace.png',
  description: 'AC not cooling, makes noise. Rattling from the outdoor unit.',
  budgetAmount: 1500,
  paymentMode: 'Cash',
  isInstant: true,
  scheduledTime: null,
  acceptCount: offers,
  chatCount: 0,
);

Future<void> pumpRequirement(
  WidgetTester tester, {
  required PostDetails requirement,
  required String? signedInAs,
  PostOfferRepository? offers,
  VisitRepository? visits,
  ValueChanged<PostOffer>? onOfferMade,
  ValueChanged<PostOffer>? onOfferAccepted,
}) async {
  tester.view.physicalSize = const Size(390 * 3, 1600 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(useMaterial3: true, fontFamily: 'Mulish'),
      home: RequirementPage(
        post: requirement,
        localityName: 'Ajnara Gen X',
        currentUsername: signedInAs,
        offers: offers ?? PostOfferRepository(),
        visits: visits ?? VisitRepository(),
        onOfferMade: onOfferMade,
        onOfferAccepted: onOfferAccepted,
      ),
    ),
  );
  await tester.pump(const Duration(seconds: 1));
}

/// The pills and prices on an offer card are laid out tightly, so the real
/// typeface has to be in place or they measure wide enough to overflow.
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

void main() {
  setUpAll(loadFonts);

  // The board's session store is a singleton; one test must not colour the
  // next.
  setUp(PostBoardRepository.shared.clear);
  tearDown(PostBoardRepository.shared.clear);

  group('somebody else posted it', () {
    testWidgets('there is no way to accept, only to offer', (tester) async {
      await pumpRequirement(
        tester,
        requirement: post(author: 'rahul_verma'),
        signedInAs: 'chakorichaturvedi',
      );

      // The offers are all readable...
      expect(find.text('Shahnaz RO & Chimney'), findsOneWidget);
      expect(find.text('3 offers'), findsOneWidget);
      // ...but taking one is not this user's to do.
      expect(find.text('Accept'), findsNothing);
      expect(find.text('Make an offer'), findsOneWidget);
    });

    testWidgets('an offer made here joins the list and lifts the count', (
      tester,
    ) async {
      PostOffer? reported;
      final offers = PostOfferRepository();

      await pumpRequirement(
        tester,
        requirement: post(author: 'rahul_verma'),
        signedInAs: 'chakorichaturvedi',
        offers: offers,
        onOfferMade: (offer) => reported = offer,
      );

      await tester.tap(find.text('Make an offer'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), '450');
      await tester.enterText(find.byType(TextField).at(1), 'today, 6 pm');
      await tester.pump();

      await tester.tap(find.text('Send offer'));
      await tester.pumpAndSettle();

      // Reported upwards so the board can move its own count...
      expect(reported, isNotNull);
      expect(reported!.price, '₹450');
      // ...and shown here straight away, under the seeker's own handle.
      expect(find.text('4 offers'), findsOneWidget);
      expect(find.text('chakorichaturvedi'), findsWidgets);
      expect(find.text('₹450'), findsOneWidget);
    });
  });

  group('I posted it', () {
    testWidgets('the offers can be accepted', (tester) async {
      await pumpRequirement(
        tester,
        requirement: post(author: 'chakorichaturvedi'),
        signedInAs: 'chakorichaturvedi',
      );

      // One Accept per offer, and no way to bid on your own requirement.
      expect(find.text('Accept'), findsNWidgets(3));
      expect(find.text('Make an offer'), findsNothing);
    });

    testWidgets('with no offers yet, there is still nothing to bid on', (
      tester,
    ) async {
      await pumpRequirement(
        tester,
        requirement: post(author: 'chakorichaturvedi', offers: 0),
        signedInAs: 'chakorichaturvedi',
      );

      expect(find.text('No offers yet'), findsOneWidget);
      // You cannot offer on your own requirement, empty or not.
      expect(find.text('Make an offer'), findsNothing);
      expect(find.text('Accept'), findsNothing);
    });

    testWidgets('once settled, it is neither acceptable nor biddable', (
      tester,
    ) async {
      await pumpRequirement(
        tester,
        requirement: post(author: 'chakorichaturvedi'),
        signedInAs: 'chakorichaturvedi',
      );

      await tester.tap(find.text('Accept').first);
      await tester.pumpAndSettle();
      Navigator.of(tester.element(find.text('Visit booked'))).pop();
      await tester.pumpAndSettle();

      expect(find.text('ACCEPTED'), findsOneWidget);
      expect(find.text('Accept'), findsNothing);
      expect(find.text('Make an offer'), findsNothing);
    });

    testWidgets('accepting books the visit outright', (tester) async {
      PostOffer? accepted;
      final visits = VisitRepository();

      await pumpRequirement(
        tester,
        requirement: post(author: 'chakorichaturvedi'),
        signedInAs: 'chakorichaturvedi',
        visits: visits,
        onOfferAccepted: (offer) => accepted = offer,
      );

      await tester.tap(find.text('Accept').first);
      await tester.pumpAndSettle();

      expect(accepted, isNotNull);
      expect(accepted!.name, 'Shahnaz RO & Chimney');

      // The offer named the price and the time, so accepting settles both
      // and the seeker lands on a booked visit rather than a slot picker.
      expect(find.text('Visit booked'), findsOneWidget);
      expect(find.text('Your visit'), findsNothing);
      expect(visits.current, isNull);
      expect(visits.booked, hasLength(1));

      final visit = visits.booked.single;
      expect(visit.providerName, 'Shahnaz RO & Chimney');
      expect(visit.servicesTotal, 899);
      expect(visit.reference, isNotNull);
      // The provider's own wording for when they would come.
      expect(visit.whenLabel, 'Today, 4–6 pm');

      // And behind it the requirement is settled. Popped through the
      // navigator rather than pageBack(), which looks for a Material back
      // button — this flow uses the app's own bare chevron.
      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pumpAndSettle();
      expect(find.text('ACCEPTED'), findsOneWidget);
      expect(find.text('Accept'), findsNothing);
    });
  });

  group('a settled post of somebody else\'s', () {
    testWidgets('cannot be offered on any more', (tester) async {
      await pumpRequirement(
        tester,
        requirement: post(
          author: 'rahul_verma',
        ).copyWith(isAccepted: true, acceptedBy: 'Sharma Carpentry'),
        signedInAs: 'chakorichaturvedi',
      );

      expect(find.text('ACCEPTED'), findsOneWidget);
      expect(find.text('Make an offer'), findsNothing);
      expect(find.text('Accept'), findsNothing);
    });
  });

  group('offering on a stranger\'s post', () {
    testWidgets('adds one offer, not two', (tester) async {
      final offers = PostOfferRepository();
      // A post nobody has answered yet.
      final theirs = post(author: 'rahul_verma', offers: 0);

      await pumpRequirement(
        tester,
        requirement: theirs,
        signedInAs: 'chakorichaturvedi',
        offers: offers,
      );

      expect(find.text('No offers yet'), findsOneWidget);

      await tester.tap(find.text('Make an offer'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, '750');
      await tester.enterText(find.byType(TextField).at(1), 'tomorrow morning');
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('Send offer'));
      await tester.pumpAndSettle();

      // The count is the total, so the seeded slice must not grow with it —
      // offering used to summon a stranger's offer alongside your own.
      expect(find.text('1 offer'), findsOneWidget);
      expect(find.text('₹750'), findsOneWidget);
      expect(find.text('Shahnaz RO & Chimney'), findsNothing);
    });
  });

  group('a closed post', () {
    testWidgets('reads closed on the detail screen, not open', (tester) async {
      await pumpRequirement(
        tester,
        requirement: post(author: 'chakorichaturvedi').copyWith(isClosed: true),
        signedInAs: 'chakorichaturvedi',
      );

      expect(find.text('CLOSED'), findsOneWidget);
      expect(find.text('OPEN'), findsNothing);
      // The work is done, so Accept is greyed rather than taken away — an
      // offer with no button would read as one that was never actionable.
      expect(find.text('Accept'), findsNWidgets(3));
      for (final element in find.text('Accept').evaluate()) {
        final button = element.findAncestorWidgetOfExactType<PressableScale>();
        expect(button?.onTap, isNull);
      }
      expect(find.text('Make an offer'), findsNothing);
    });

    testWidgets('somebody else\'s closed post shows no button at all', (
      tester,
    ) async {
      await pumpRequirement(
        tester,
        requirement: post(author: 'rahul_verma').copyWith(isClosed: true),
        signedInAs: 'chakorichaturvedi',
      );

      // It was never theirs to press, so there is nothing to grey out.
      expect(find.text('Accept'), findsNothing);
      expect(find.text('Make an offer'), findsNothing);
    });
  });

  group('the money fields', () {
    testWidgets('take digits and nothing else', (tester) async {
      await pumpRequirement(
        tester,
        requirement: post(author: 'rahul_verma'),
        signedInAs: 'chakorichaturvedi',
      );

      await tester.tap(find.text('Make an offer'));
      await tester.pumpAndSettle();

      // A number keyboard is only a request; a paste or a hardware keyboard
      // can still put letters in, and "₹750tomorrow" is not a price.
      await tester.enterText(find.byType(TextField).first, '750tomorrow');
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('750'), findsOneWidget);
      expect(find.text('750tomorrow'), findsNothing);
    });
  });

  group('the board behind keeps up', () {
    // Accepting and offering happen on the requirement screen, but the board
    // holds the list the cards are drawn from, so the events have to land
    // there too — otherwise the card behind still reads OPEN.
    const anOffer = PostOffer(
      name: 'Sharma Carpentry',
      badge: OfferBadge.verified,
      price: '₹1200',
      timing: 'tomorrow',
      note: '',
    );

    Future<PostBloc> loadedBoard() async {
      final bloc = PostBloc(dashboardRepository: const DashboardRepository());
      addTearDown(bloc.close);
      bloc.add(const OnFetchPostDetails());
      // The stub repository answers after a second.
      await Future<void>.delayed(const Duration(seconds: 2));
      return bloc;
    }

    test('accepting settles that post and names who took it', () async {
      final bloc = await loadedBoard();
      final settledBefore = bloc.state.postDetails
          .where((post) => post.isAccepted)
          .length;
      final target = bloc.state.postDetails.firstWhere(
        (post) => !post.isAccepted,
      );

      bloc.add(OnOfferAccepted(target, anOffer));
      await Future<void>.delayed(Duration.zero);

      final updated = bloc.state.postDetails.firstWhere(
        (post) => post.key == target.key,
      );
      expect(updated.isAccepted, isTrue);
      expect(updated.acceptedBy, 'Sharma Carpentry');
      // Only that one moved: the seed already carries settled requirements
      // of its own, so count the difference rather than a fixed total.
      expect(
        bloc.state.postDetails.where((post) => post.isAccepted).length,
        settledBefore + 1,
      );
    });

    test('an offer lifts that post\'s count and no other', () async {
      final bloc = await loadedBoard();
      final target = bloc.state.postDetails.first;
      final before = target.acceptCount;
      final othersBefore = bloc.state.postDetails
          .skip(1)
          .map((post) => post.acceptCount)
          .toList();

      bloc.add(OnOfferMade(target));
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.postDetails.first.acceptCount, before + 1);
      expect(
        bloc.state.postDetails.skip(1).map((post) => post.acceptCount).toList(),
        othersBefore,
      );
    });
  });

  testWidgets('the offer cards survive the narrowest phone', (tester) async {
    // Avatar, name, badge, price and timing all share one row, so this is
    // the layout most likely to run out of width.
    tester.view.physicalSize = const Size(320 * 3, 1600 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true, fontFamily: 'Mulish'),
        home: RequirementPage(
          post: post(author: 'chakorichaturvedi'),
          localityName: 'Ajnara Gen X',
          currentUsername: 'chakorichaturvedi',
          offers: PostOfferRepository(),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(tester.takeException(), isNull);
  });

  testWidgets('signed out, a requirement is nobody\'s to act on', (
    tester,
  ) async {
    await pumpRequirement(
      tester,
      requirement: post(author: 'chakorichaturvedi'),
      signedInAs: null,
    );

    expect(find.text('Accept'), findsNothing);
    // Offering is still open to anyone who signs in; the button is there.
    expect(find.text('Make an offer'), findsOneWidget);
  });
}
