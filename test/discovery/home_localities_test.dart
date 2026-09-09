import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:local_markerplace/components/states/empty_state.dart';
import 'package:local_markerplace/discovery/model/provider_summary.dart';
import 'package:local_markerplace/discovery/presentation/components/category_tile.dart';
import 'package:local_markerplace/discovery/presentation/discovery_home_view.dart';
import 'package:local_markerplace/network/failure.dart';

import '../support/fake_home_source.dart';

/// Home against the three answers the endpoint really gives, area by area:
/// a market with somebody in it, a society that is live but empty, and an
/// address the server has never heard of.
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

/// Static skeletons schedule no frames, so a settle can return before the
/// fetch has been given a turn. This gives it one.
Future<void> settleFetch(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadFonts);

  var changedArea = 0;
  var posted = 0;
  List<ProviderSummary>? seenAll;

  Future<void> pumpArea(
    WidgetTester tester, {
    required String name,
    required String slug,
    required FakeHomeSource source,
  }) async {
    changedArea = 0;
    posted = 0;
    seenAll = null;

    tester.view.physicalSize = const Size(390 * 3, 900 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true, fontFamily: 'Mulish'),
        home: Scaffold(
          body: SafeArea(
            bottom: false,
            child: DiscoveryHomeView(
              localityName: name,
              localitySlug: slug,
              homeRepository: source,
              onChangeLocality: () => changedArea++,
              onPost: () => posted++,
              onSearch: () {},
              onSeeAllCategories: (_) {},
              onSeeAllProviders: (providers) => seenAll = providers,
            ),
          ),
        ),
      ),
    );
    await settleFetch(tester);
  }

  testWidgets('galleria-market-1 · a live market draws who works there', (
    tester,
  ) async {
    final source = FakeHomeSource(
      feed: sampleFeed(
        slug: 'galleria-market-1',
        name: 'Galleria Market 1',
        providers: 1,
      ),
    );
    await pumpArea(
      tester,
      name: 'Galleria Market 1',
      slug: 'galleria-market-1',
      source: source,
    );

    expect(source.requested, ['galleria-market-1']);
    expect(find.text('Galleria Market 1'), findsWidgets);
    expect(find.text('Dev Electricals'), findsOneWidget);
    expect(find.byType(EmptyState), findsNothing);
  });

  testWidgets('ajnara-gen-x · a live area with nobody in it keeps the trades', (
    tester,
  ) async {
    await pumpArea(
      tester,
      name: 'Ajnara Gen X',
      slug: 'ajnara-gen-x',
      source: FakeHomeSource(
        feed: sampleFeed(
          slug: 'ajnara-gen-x',
          name: 'Ajnara Gen X',
          providers: 0,
        ),
      ),
    );

    // The area is on ServiQ, so the trades stay and only the rail is empty.
    expect(find.byType(CategoryTile), findsWidgets);
    expect(
      find.text('No providers in Ajnara Gen X yet — coming soon.'),
      findsOneWidget,
    );
    // Not the whole-screen state: that is for an area we do not cover.
    expect(find.byType(EmptyState), findsNothing);
  });

  testWidgets('gaur-city-1 · an area we do not cover reads as coming soon', (
    tester,
  ) async {
    await pumpArea(
      tester,
      name: 'Gaur City 1',
      slug: 'gaur-city-1',
      source: FakeHomeSource(
        failure: const Failure(
          errorMessage: 'Locality not found.',
          errorCode: 'LOCALITY_NOT_FOUND',
        ),
      ),
    );

    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.text('Coming soon to your neighbourhood'), findsOneWidget);
    expect(find.textContaining('Gaur City 1 is not on ServiQ yet'), findsOne);
    // Nothing to draw, so nothing pretends to be there.
    expect(find.byType(CategoryTile), findsNothing);
    // Not an apology with a reference: this is not a fault.
    expect(find.textContaining('quote ref'), findsNothing);
    expect(find.text('Try again'), findsNothing);
  });

  testWidgets('the coming soon state offers the two things that still work', (
    tester,
  ) async {
    await pumpArea(
      tester,
      name: 'Gaur City 1',
      slug: 'gaur-city-1',
      source: FakeHomeSource(
        failure: const Failure(errorCode: 'LOCALITY_NOT_FOUND'),
      ),
    );

    await tester.tap(find.text('Choose another area'));
    await tester.pump();
    expect(changedArea, 1);

    await tester.tap(find.text('Post what you need'));
    await tester.pump();
    expect(posted, 1);
  });

  testWidgets('home shows six trades however many the server sends', (
    tester,
  ) async {
    await pumpArea(
      tester,
      name: 'Galleria Market 1',
      slug: 'galleria-market-1',
      source: FakeHomeSource(feed: sampleFeed(categories: 23)),
    );

    // Two full rows of three, whatever the payload holds.
    expect(find.byType(CategoryTile), findsNWidgets(6));
    // The seventh the server sent is behind "See all", not on the grid.
    expect(find.text('Carpenter'), findsNothing);
    expect(find.text('See all'), findsWidgets);
  });

  testWidgets('See all hands over the providers home was showing', (
    tester,
  ) async {
    await pumpArea(
      tester,
      name: 'Galleria Market 1',
      slug: 'galleria-market-1',
      source: FakeHomeSource(feed: sampleFeed(providers: 3)),
    );

    await tester.tap(find.text('See all').last);
    await tester.pump();

    // The list that opens is the endpoint's providers, not a seeded set that
    // happens to share the area's name.
    expect(seenAll, isNotNull);
    expect(seenAll, hasLength(3));
    expect(seenAll!.first.name, 'Dev Electricals');
  });
}
