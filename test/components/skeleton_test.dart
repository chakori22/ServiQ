import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:local_markerplace/components/skeleton/skeleton.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/dashboard/presentation/posts/presentation/my_posts_page.dart';
import 'package:local_markerplace/discovery/presentation/discovery_shell.dart';

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

Future<void> pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(useMaterial3: true, fontFamily: 'Mulish'),
      home: child,
    ),
  );
}

void main() {
  setUpAll(loadFonts);

  group('the skeletons', () {
    testWidgets('a list draws a row per item and names what is coming', (
      tester,
    ) async {
      await pump(
        tester,
        const Scaffold(
          body: SkeletonList(caption: 'Loading providers near you'),
        ),
      );

      expect(find.byType(SkeletonListRow), findsNWidgets(5));
      expect(find.text('Loading providers near you'), findsOneWidget);
    });

    testWidgets('a header adds the title and search blocks', (tester) async {
      await pump(
        tester,
        const Scaffold(body: SkeletonList(hasHeader: true, rows: 2)),
      );

      expect(find.byType(SkeletonListRow), findsNWidgets(2));
      // Title, search, section label, plus the bars inside the two rows.
      expect(find.byType(SkeletonBlock), findsAtLeast(9));
    });

    testWidgets('a profile keeps its real tab strip', (tester) async {
      await pump(
        tester,
        const Scaffold(
          body: SkeletonProfile(tabs: ['Services', 'Store', 'Reviews']),
        ),
      );

      // The tabs are the app's furniture, not the provider's content, so
      // they are drawn rather than blanked.
      expect(find.text('Services'), findsOneWidget);
      expect(find.text('Store'), findsOneWidget);
      expect(find.byType(SkeletonCircle), findsOneWidget);
    });

    testWidgets('they settle — nothing here loops', (tester) async {
      await pump(tester, const Scaffold(body: SkeletonList()));

      // A pulsing skeleton would never let a widget test settle, which is
      // half of why the design draws them flat.
      await tester.pumpAndSettle();
      expect(find.byType(SkeletonListRow), findsNWidgets(5));
    });

    testWidgets('the two fills are the design\'s, not one flat grey', (
      tester,
    ) async {
      await pump(
        tester,
        const Scaffold(
          body: Column(
            children: [
              SkeletonBlock(width: 100, height: 12),
              SkeletonBlock(width: 100, height: 10, soft: true),
            ],
          ),
        ),
      );

      final fills = tester
          .widgetList<Container>(find.byType(Container))
          .map((c) => (c.decoration as BoxDecoration?)?.color)
          .whereType<Color>()
          .toSet();
      expect(fills, contains(AppColor.skeletonStrong));
      expect(fills, contains(AppColor.skeletonSoft));
    });
  });

  group('screens that wait', () {
    testWidgets('the board shows the list skeleton, not a spinner', (
      tester,
    ) async {
      await pump(tester, const MyPostsPage(localityName: 'Ajnara Gen X'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(SkeletonList), findsOneWidget);
      expect(find.text('Loading your posts'), findsOneWidget);

      // Let the fetch finish so no timer outlives the test.
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    testWidgets('the shell never falls back to a spinner', (tester) async {
      // Without a stored profile the gate resolves on the first frame, so
      // what matters here is that no spinner is left anywhere in the flow.
      await pump(tester, const DiscoveryShell(initialLocality: 'Ajnara Gen X'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
    });
  });
}
