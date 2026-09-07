import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:local_markerplace/chat/presentation/chats_page.dart';
import 'package:local_markerplace/chat/repository/chat_repository.dart';
import 'package:local_markerplace/dashboard/presentation/posts/presentation/my_posts_page.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_tab_bar.dart';
import 'package:local_markerplace/visit/presentation/my_orders_page.dart';
import 'package:local_markerplace/visit/repository/visit_repository.dart';

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

/// Stands in for the shell: it is the first route, and it goes back to
/// itself when a child screen reports a tab — exactly what the real
/// `_selectTabFromChild` does.
class _Shell extends StatefulWidget {
  const _Shell({required this.build});

  final Widget Function(ValueChanged<DiscoveryTab> onTabSelected) build;

  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  DiscoveryTab _tab = DiscoveryTab.me;

  void _fromChild(DiscoveryTab tab) {
    // The shell returns to itself; the child must not pop as well.
    Navigator.of(context).popUntil((route) => route.isFirst);
    setState(() => _tab = tab);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('shell on ${_tab.name}'),
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => widget.build(_fromChild)),
              ),
              child: const Text('open'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> openAndLeave(
  WidgetTester tester,
  Widget Function(ValueChanged<DiscoveryTab>) build,
) async {
  tester.view.physicalSize = const Size(390 * 3, 1000 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(useMaterial3: true, fontFamily: 'Mulish'),
      home: _Shell(build: build),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();

  await tester.tap(
    find.descendant(
      of: find.byType(DiscoveryTabBar),
      matching: find.text('Explore'),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadFonts);

  group('leaving a pushed screen by its tab bar', () {
    // The shell already returns to itself when a child reports a tab. A
    // child that also popped took the shell off the stack with it, and the
    // app went black.

    testWidgets('Chats lands back on the shell', (tester) async {
      await openAndLeave(
        tester,
        (onTabSelected) => ChatsPage(
          repository: ChatRepository(),
          onTabSelected: onTabSelected,
        ),
      );

      expect(find.text('shell on explore'), findsOneWidget);
      expect(find.byType(ChatsPage), findsNothing);
    });

    testWidgets('My orders lands back on the shell', (tester) async {
      await openAndLeave(
        tester,
        (onTabSelected) => MyOrdersPage(
          repository: VisitRepository(),
          onTabSelected: onTabSelected,
        ),
      );

      expect(find.text('shell on explore'), findsOneWidget);
    });

    testWidgets('My posts lands back on the shell', (tester) async {
      await openAndLeave(
        tester,
        (onTabSelected) => MyPostsPage(onTabSelected: onTabSelected),
      );

      expect(find.text('shell on explore'), findsOneWidget);
    });
  });
}
