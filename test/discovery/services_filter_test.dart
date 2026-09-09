import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:local_markerplace/discovery/model/service_category.dart';
import 'package:local_markerplace/discovery/presentation/components/category_filter_sheet.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_filter_chip.dart';
import 'package:local_markerplace/discovery/presentation/discovery_home_view.dart';
import 'package:local_markerplace/discovery/presentation/services_page.dart';
import 'package:local_markerplace/visit/repository/visit_repository.dart';

import '../support/fake_home_source.dart';

/// The catalogue's filter: the icon in the header, the sheet behind it, and
/// what the list does once a trade is chosen.
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

/// The trades home would hand over, in the shape the endpoint sends them.
const _categories = [
  ServiceCategory(label: 'Electrician', icon: Icons.bolt_rounded),
  ServiceCategory(label: 'Plumber', icon: Icons.water_drop_outlined),
  ServiceCategory(label: 'Pest control', icon: Icons.bug_report_outlined),
];

/// The number the header quotes — "12 jobs in Ajnara Gen X · Electrician".
int jobCount(WidgetTester tester) {
  final text = tester
      .widgetList<Text>(find.byType(Text))
      .map((t) => t.data ?? '')
      .firstWhere((data) => RegExp(r'^\d+ jobs? in ').hasMatch(data));
  return int.parse(text.split(' ').first);
}

void main() {
  setUpAll(loadFonts);

  Future<void> pumpCatalogue(
    WidgetTester tester, {
    String? initialCategory,
  }) async {
    tester.view.physicalSize = const Size(390 * 3, 900 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true, fontFamily: 'Mulish'),
        home: ServicesPage(
          localityName: 'Ajnara Gen X',
          initialCategory: initialCategory,
          categories: _categories,
          visits: VisitRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openSheet(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();
  }

  testWidgets('the catalogue opens on everything, with the filter to hand', (
    tester,
  ) async {
    await pumpCatalogue(tester);

    expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
    // The filter lives in the sheet now; there is no chip rail above the
    // list holding a second copy of the same choice.
    expect(find.byType(DiscoveryFilterChip), findsNothing);
    // Nothing is narrowed, so the subtitle names only the area.
    expect(find.textContaining('in Ajnara Gen X'), findsOneWidget);
    expect(find.textContaining('· Electrician'), findsNothing);

    // And the sheet opens on All.
    await openSheet(tester);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });

  testWidgets('the filter icon opens the sheet on every trade', (tester) async {
    await pumpCatalogue(tester);
    await openSheet(tester);

    expect(find.byType(CategoryFilterSheet), findsOneWidget);
    expect(find.text('Filter by category'), findsOneWidget);
    expect(find.text('All categories'), findsOneWidget);
    for (final category in _categories) {
      expect(find.text(category.label), findsWidgets);
    }
  });

  testWidgets('choosing a trade narrows the list and says which', (
    tester,
  ) async {
    await pumpCatalogue(tester);
    final unfiltered = jobCount(tester);
    expect(unfiltered, greaterThan(0));
    await openSheet(tester);

    await tester.tap(find.text('Electrician').last);
    await tester.pumpAndSettle();

    // The sheet closes on the choice rather than needing a second tap.
    expect(find.byType(CategoryFilterSheet), findsNothing);
    // The header says what produced the count, so a short list reads as
    // narrowed rather than as an empty area.
    expect(find.textContaining('· Electrician'), findsOneWidget);

    // Only that trade's work is left, and less of it than before. The count
    // comes from the header rather than from the rows, which a lazy list
    // only builds as far as the viewport.
    expect(jobCount(tester), greaterThan(0));
    expect(jobCount(tester), lessThan(unfiltered));
    expect(find.byType(DiscoveryFilterChip), findsNothing);
    final onScreen = tester
        .widgetList<CatalogueServiceCard>(find.byType(CatalogueServiceCard))
        .toList();
    expect(onScreen, isNotEmpty);
    expect(
      onScreen.every((card) => card.service.categoryLabel == 'Electrician'),
      isTrue,
    );
  });

  testWidgets('the sheet marks what is already applied', (tester) async {
    await pumpCatalogue(tester, initialCategory: 'Plumber');
    await openSheet(tester);

    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });

  testWidgets('backing out of the sheet is not the same as choosing All', (
    tester,
  ) async {
    await pumpCatalogue(tester, initialCategory: 'Plumber');
    await openSheet(tester);

    // Tapping the scrim dismisses it.
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.byType(CategoryFilterSheet), findsNothing);
    expect(find.textContaining('· Plumber'), findsOneWidget);
  });

  testWidgets('home hands the catalogue every trade, not just the six shown', (
    tester,
  ) async {
    List<ServiceCategory>? handedOver;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true, fontFamily: 'Mulish'),
        home: Scaffold(
          body: SafeArea(
            bottom: false,
            child: DiscoveryHomeView(
              localityName: 'Galleria Market 1',
              localitySlug: 'galleria-market-1',
              homeRepository: FakeHomeSource(feed: sampleFeed(categories: 23)),
              onChangeLocality: () {},
              onSearch: () {},
              onSeeAllCategories: (categories) => handedOver = categories,
              onSeeAllProviders: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    await tester.tap(find.text('See all').first);
    await tester.pump();

    // The grid shows six; the filter behind "See all" offers all of them.
    expect(handedOver, hasLength(23));
  });
}
