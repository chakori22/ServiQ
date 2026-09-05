import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:local_markerplace/discovery/model/locality.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_tab_bar.dart';
import 'package:local_markerplace/discovery/presentation/discovery_home_view.dart';
import 'package:local_markerplace/discovery/presentation/discovery_shell.dart';
import 'package:local_markerplace/discovery/presentation/explore_zones_view.dart';
import 'package:local_markerplace/discovery/presentation/location_page.dart';
import 'package:local_markerplace/discovery/presentation/locality_page.dart';
import 'package:local_markerplace/discovery/presentation/search_page.dart';
import 'package:local_markerplace/discovery/presentation/zone_detail_page.dart';
import 'package:local_markerplace/discovery/repository/discovery_repository.dart';

/// Every screen is laid out to a fixed 390x844 in the design, so these pump
/// each one at that size. An overflow inside a card only shows up at the
/// exact height the design specifies, which is what caught the provider
/// card's two-line name not fitting.
/// The layouts are measured against Plus Jakarta Sans, so the real faces have
/// to be in the test binding — the fallback the test framework ships with is
/// wider and reports overflows the app never has.
Future<void> loadFonts() async {
  for (final path in const [
    'assets/fonts/PlusJakartaSans-Medium.ttf',
    'assets/fonts/PlusJakartaSans-Bold.ttf',
    'assets/fonts/PlusJakartaSans-ExtraBold.ttf',
  ]) {
    final loader = FontLoader('Plus Jakarta Sans')
      ..addFont(File(path).readAsBytes().then((b) => ByteData.view(b.buffer)));
    await loader.load();
  }
}

void main() {
  const repository = DiscoveryRepository();
  final zone = repository.zones().firstWhere((zone) => zone.isLive);

  setUpAll(loadFonts);

  Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(home: screen));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  testWidgets('area picker lists the live zone and the ones coming', (
    tester,
  ) async {
    await pumpScreen(tester, const LocationPage());

    expect(find.text('Where do you need help?'), findsOneWidget);
    expect(find.text('Use my current location'), findsOneWidget);
    expect(find.text('Crossing Republik'), findsOneWidget);
    expect(find.text('Ajnara Gen X'), findsOneWidget);
    expect(find.text('COMING SOON'), findsWidgets);
  });

  testWidgets('home shows the area, the categories and who is nearby', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      Scaffold(
        body: SafeArea(
          bottom: false,
          child: DiscoveryHomeView(
            localityName: 'Ajnara Gen X',
            onChangeLocality: () {},
            onSearch: () {},
            onSeeAllCategories: () {},
            onSeeAllProviders: () {},
          ),
        ),
        bottomNavigationBar: DiscoveryTabBar(
          current: DiscoveryTab.home,
          onSelect: (_) {},
        ),
      ),
    );

    expect(find.text('What do you need done?'), findsOneWidget);
    expect(find.text('Ajnara Gen X'), findsOneWidget);
    expect(find.text('Electrician'), findsWidgets);
    expect(find.text('Shahnaz RO & Chimney Services'), findsOneWidget);
    expect(find.text('2 services · 3 parts'), findsOneWidget);
  });

  testWidgets('explore counts a zone by its totals, not the page loaded', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      Scaffold(
        body: SafeArea(child: ExploreZonesView(onZoneTap: (_) {})),
      ),
    );

    // The card loads four societies but the zone has ten, and the design
    // shows the total.
    expect(find.text('10 societies'), findsOneWidget);
    expect(find.text('6 markets'), findsOneWidget);
  });

  testWidgets('zone detail splits societies from markets', (tester) async {
    await pumpScreen(tester, ZoneDetailPage(zone: zone, onLocalityTap: (_) {}));

    expect(find.text('Societies'), findsOneWidget);
    expect(find.text('Markets'), findsOneWidget);
    expect(find.text('Galleria Market 1'), findsOneWidget);
  });

  testWidgets('locality captions itself with the count the row promised', (
    tester,
  ) async {
    await pumpScreen(tester, const LocalityPage(localityName: 'Ajnara Gen X'));

    final locality = zone.localities.firstWhere(
      (locality) => locality.name == 'Ajnara Gen X',
    );
    expect(
      find.text('${locality.providerCount} providers · Crossing Republik'),
      findsOneWidget,
    );
  });

  testWidgets('search narrows to the typed trade', (tester) async {
    await pumpScreen(
      tester,
      const SearchPage(
        localityName: 'Ajnara Gen X',
        initialQuery: 'electrician',
      ),
    );

    final matches = repository.search(
      'electrician',
      localityName: 'Ajnara Gen X',
    );
    expect(
      find.text('${matches.length} results in Ajnara Gen X'),
      findsOneWidget,
    );
    expect(find.text('RK Electricals & Repairs'), findsOneWidget);
    // A plumber must not survive the query.
    expect(find.text('Verma Plumbing Works'), findsNothing);
  });

  test('a compound trade line is offered as one chip per trade', () {
    final trades = repository.tradesIn('Ajnara Gen X');

    expect(trades, contains('RO Repair'));
    expect(trades, contains('Chimney'));
    expect(trades, isNot(contains('RO Repair · Chimney')));
  });

  test(
    'filtering by one half of a compound trade still finds the provider',
    () {
      final results = repository.search('', trade: 'Chimney');

      expect(
        results.map((provider) => provider.name),
        contains('Shahnaz RO & Chimney Services'),
      );
    },
  );

  testWidgets('the shell drills from explore down to a locality', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const DiscoveryShell(initialLocality: 'Ajnara Gen X'),
    );

    expect(find.text('What do you need done?'), findsOneWidget);

    await tester.tap(find.text('Explore'));
    await tester.pumpAndSettle();
    expect(find.text('Pick an area to see who works there'), findsOneWidget);

    await tester.tap(find.text('Crossing Republik'));
    await tester.pumpAndSettle();
    expect(find.text('Societies'), findsOneWidget);

    await tester.tap(find.text('Mahagun Mascot'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('providers · Crossing Republik'),
      findsOneWidget,
    );
  });

  testWidgets('the shell asks for an area when it does not have one', (
    tester,
  ) async {
    await pumpScreen(tester, const DiscoveryShell());

    expect(find.text('Where do you need help?'), findsOneWidget);
  });

  testWidgets(
    '"Near you" shows the seeker\'s own area, not the first on file',
    (tester) async {
      await pumpScreen(
        tester,
        Scaffold(
          body: SafeArea(
            bottom: false,
            child: DiscoveryHomeView(
              localityName: 'Panchsheel Greens',
              onChangeLocality: () {},
              onSearch: () {},
              onSeeAllCategories: () {},
              onSeeAllProviders: () {},
            ),
          ),
        ),
      );

      expect(find.text('Greens Cleaning Crew'), findsOneWidget);
      // Ajnara Gen X's providers head the catalogue; they must not leak onto
      // another area's home screen.
      expect(find.text('Shahnaz RO & Chimney Services'), findsNothing);
    },
  );

  testWidgets('"Near you" says so when the area has nobody yet', (
    tester,
  ) async {
    final empty = zone.markets.firstWhere((m) => m.providerCount == 0);

    await pumpScreen(
      tester,
      Scaffold(
        body: SafeArea(
          bottom: false,
          child: DiscoveryHomeView(
            localityName: empty.name,
            onChangeLocality: () {},
            onSearch: () {},
            onSeeAllCategories: () {},
            onSeeAllProviders: () {},
          ),
        ),
      ),
    );

    expect(
      find.text('No providers in ${empty.name} yet — coming soon.'),
      findsOneWidget,
    );
  });

  test('every locality a row offers actually has providers behind it', () {
    for (final zone in repository.zones().where((zone) => zone.isLive)) {
      for (final locality in zone.localities) {
        final providers = repository.providersIn(locality.name);
        expect(
          providers.length,
          locality.providerCount,
          reason: '${locality.name} promises a count it cannot fill',
        );
      }
    }
  });

  test('a live zone lists both societies and markets', () {
    final zone = repository.zones().firstWhere((zone) => zone.isLive);

    expect(zone.societies, isNotEmpty);
    expect(zone.markets, isNotEmpty);
    // Every market bar the one held back as the coming-soon case has someone
    // working in it.
    final staffed = zone.markets.where((m) => m.providerCount > 0);
    expect(staffed.length, zone.markets.length - 1);
  });

  testWidgets('a market with nobody on file reads as coming soon', (
    tester,
  ) async {
    await pumpScreen(tester, ZoneDetailPage(zone: zone, onLocalityTap: (_) {}));

    final empty = zone.markets.firstWhere((m) => m.providerCount == 0);
    await tester.scrollUntilVisible(find.text(empty.name), 200);
    await tester.pumpAndSettle();

    expect(find.text(empty.name), findsOneWidget);
    // The row offers a pill instead of a count, so there is nothing to tap
    // through to an empty list.
    expect(find.text('COMING SOON'), findsWidgets);
  });

  testWidgets('a locality with no providers says so rather than going blank', (
    tester,
  ) async {
    final empty = zone.markets.firstWhere((m) => m.providerCount == 0);

    await pumpScreen(tester, LocalityPage(localityName: empty.name));

    expect(find.text('No providers here yet — coming soon.'), findsOneWidget);
  });

  test('a locality knows the zone it sits in', () {
    expect(
      repository.zoneOfLocality('Galleria Market 1')?.name,
      'Crossing Republik',
    );
    expect(
      zone.markets.map((locality) => locality.kind),
      everyElement(LocalityKind.market),
    );
  });
}
