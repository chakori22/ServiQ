import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:local_markerplace/discovery/presentation/discovery_shell.dart';

import '../support/fake_home_source.dart';

/// Changing the area on home is a different feed, so it has to go back to
/// the endpoint — the screen the seeker lands on must be the one they asked
/// for and not the one they were already looking at.
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
/// fetch has been given a turn.
Future<void> settleFetch(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadFonts);

  Future<void> pumpShell(WidgetTester tester, FakeHomeSource source) async {
    tester.view.physicalSize = const Size(390 * 3, 900 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, fontFamily: 'Mulish'),
        home: DiscoveryShell(
          initialLocality: 'Galleria Market 1',
          homeRepository: source,
        ),
      ),
    );
    await settleFetch(tester);
  }

  /// Opens the picker from home's header and takes the named area.
  Future<void> changeAreaTo(WidgetTester tester, String name) async {
    await tester.tap(find.text('Galleria Market 1').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text(name).last);
    await settleFetch(tester);
  }

  testWidgets('choosing another area asks the endpoint for it', (tester) async {
    final source = FakeHomeSource(feed: sampleFeed());
    await pumpShell(tester, source);
    expect(source.requested, ['galleria-market-1']);

    await changeAreaTo(tester, 'Mahagun Mascot');

    expect(source.requested, ['galleria-market-1', 'mahagun-mascot']);
  });

  testWidgets('choosing the area already showing asks again too', (
    tester,
  ) async {
    final source = FakeHomeSource(feed: sampleFeed());
    await pumpShell(tester, source);

    await changeAreaTo(tester, 'Galleria Market 1');

    // The seeker went to the picker and chose — that is a request for this
    // area's feed, whether or not it is the one they were already on.
    expect(source.requested, ['galleria-market-1', 'galleria-market-1']);
  });
}
