import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:local_markerplace/provider/model/provider_profile.dart';
import 'package:local_markerplace/provider/presentation/components/segmented_tabs.dart';
import 'package:local_markerplace/provider/presentation/provider_profile_page.dart';
import 'package:local_markerplace/provider/repository/provider_repository.dart';

const _shahnaz = 'Shahnaz RO & Chimney Services';

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
  const repository = ProviderRepository();

  setUpAll(loadFonts);

  Future<void> pump(WidgetTester tester, Widget screen, {Size? size}) async {
    final target = size ?? const Size(390, 844);
    tester.view.physicalSize = target * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: screen));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  testWidgets('a signed-out visitor can read the page but not act on it', (
    tester,
  ) async {
    await pump(
      tester,
      const ProviderProfilePage(providerName: _shahnaz, isSignedIn: false),
    );

    expect(find.text(_shahnaz), findsOneWidget);
    expect(find.text('VERIFIED'), findsOneWidget);
    // The actions say what signing in would buy them.
    expect(find.text('Sign in to connect'), findsOneWidget);
    expect(find.text('Sign in to chat'), findsOneWidget);
    expect(find.textContaining('This page is public'), findsOneWidget);
  });

  testWidgets('signing in turns the gated actions into real ones', (
    tester,
  ) async {
    await pump(tester, const ProviderProfilePage(providerName: _shahnaz));

    expect(find.text('Connect'), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget);
    expect(find.textContaining('This page is public'), findsNothing);
  });

  testWidgets('the four tabs each show their own content', (tester) async {
    await pump(tester, const ProviderProfilePage(providerName: _shahnaz));

    expect(find.text('AC Servicing'), findsOneWidget);

    await tester.tap(find.text('Reviews'));
    await tester.pumpAndSettle();
    expect(find.text('128 reviews'), findsOneWidget);
    expect(find.text('Anita Sharma'), findsOneWidget);

    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();
    expect(find.text('ADDRESS'), findsOneWidget);
    expect(find.text('HOURS'), findsOneWidget);

    await tester.tap(find.text('Store'));
    await tester.pumpAndSettle();
    expect(find.text('RO Filter Set (3 stage)'), findsOneWidget);
    expect(find.text('Only 2 left'), findsOneWidget);
  });

  testWidgets('an unbadged provider explains why there is no check', (
    tester,
  ) async {
    await pump(
      tester,
      const ProviderProfilePage(providerName: 'Imran AC Works'),
    );

    expect(find.text('PROVIDER'), findsOneWidget);
    expect(find.text('No verified badge'), findsOneWidget);
    expect(find.textContaining('has no GSTIN'), findsOneWidget);
    // Still bookable.
    expect(find.text('Connect'), findsOneWidget);
  });

  for (final size in const [
    Size(320, 568),
    Size(360, 640),
    Size(390, 844),
    Size(428, 926),
  ]) {
    for (final tab in ProviderTab.values) {
      testWidgets('the ${tab.label} tab fits ${size.width.toInt()}x'
          '${size.height.toInt()}', (tester) async {
        await pump(
          tester,
          ProviderProfilePage(providerName: _shahnaz, initialTab: tab),
          size: size,
        );
      });
    }
  }

  test('the head lists the visit charge, the tab lists what a job covers', () {
    final profile = repository.forName(_shahnaz);
    final summary = repository.summaryServices(profile);

    expect(summary.first.detail, contains('Visit charge'));
    expect(profile.services.first.detail, isNot(contains('Visit charge')));
    expect(summary.length, profile.services.length);
  });

  test('an unknown provider falls back rather than showing nothing', () {
    expect(repository.byName('Nobody'), isNull);
    expect(repository.forName('Nobody').name, _shahnaz);
  });

  test('a rating breakdown is a share of the whole', () {
    final profile = repository.forName(_shahnaz);
    final total = profile.ratingBreakdown.reduce((a, b) => a + b);

    expect(profile.ratingBreakdown, hasLength(5));
    expect(total, closeTo(1.0, 0.01));
  });

  test('initials come from the business name', () {
    expect(repository.forName(_shahnaz).initials, 'SR');
    expect(repository.forName('Imran AC Works').initials, 'IA');
  });

  test('a verified profile carries the badge, an individual does not', () {
    expect(repository.forName(_shahnaz).badge, ProviderBadge.verified);
    expect(repository.forName('Imran AC Works').badge, ProviderBadge.provider);
  });
}
