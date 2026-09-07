import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:local_markerplace/core/app_routes.dart';
import 'package:local_markerplace/dashboard/model/post_draft.dart';
import 'package:local_markerplace/dashboard/presentation/posts/presentation/post_screen.dart';

PostDraft draft() => PostDraft(
  category: 'Plumbing',
  description: 'Kitchen tap is dripping',
  budget: '500',
  imagePath: '/tmp/photo.jpg',
  isInstant: true,
  scheduledTime: null,
);

/// Opens the board the way posting does — arriving from the form, through
/// the real router, with whatever that form handed it.
///
/// It starts somewhere else on purpose: pushing the board onto itself reuses
/// the page, and the upload is kicked off in its `initState`.
Future<void> pumpBoard(WidgetTester tester, Object? extra) async {
  tester.view.physicalSize = const Size(390 * 3, 1200 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  // Starting on the form is the real path a post takes, and it keeps the
  // legacy dashboard — which overflows at this width — out of the way.
  final router = GoRouter(
    initialLocation: AppRoutes.instantForm.path,
    routes: createRoutes(),
  );
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  await tester.pump(const Duration(seconds: 1));

  router.pushReplacementAppRoute(AppRoutes.posts, extra: extra);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

/// The simulated upload runs for three seconds; letting it finish keeps its
/// timers from outliving the test.
Future<void> drainUpload(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 4));
  await tester.pumpAndSettle();
}

void main() {
  group('sharing a post', () {
    testWidgets('shows the upload banner while it goes up', (tester) async {
      await pumpBoard(
        tester,
        PostsArgs(draft: draft(), localityName: 'Ajnara Gen X'),
      );

      expect(
        find.textContaining('Keep ServiQ open to finish posting'),
        findsOneWidget,
      );
      // The board keeps the area it was posted from.
      expect(find.text('Ajnara Gen X'), findsWidgets);

      // Once it finishes, the banner goes and the post is on the board.
      await drainUpload(tester);
      expect(
        find.textContaining('Keep ServiQ open to finish posting'),
        findsNothing,
      );
      expect(find.textContaining('Kitchen tap is dripping'), findsWidgets);
    });

    testWidgets('a draft on its own still uploads', (tester) async {
      // The board used to drop anything that was not a PostsArgs, which is
      // how the progress banner went missing when the forms were still
      // sending a bare draft.
      await pumpBoard(tester, draft());

      expect(
        find.textContaining('Keep ServiQ open to finish posting'),
        findsOneWidget,
      );
      await drainUpload(tester);
    });

    testWidgets('a deep link with nothing shows no banner', (tester) async {
      await pumpBoard(tester, null);

      expect(
        find.textContaining('Keep ServiQ open to finish posting'),
        findsNothing,
      );
      await drainUpload(tester);
    });
  });
}
