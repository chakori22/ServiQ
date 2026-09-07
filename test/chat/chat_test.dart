import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:local_markerplace/chat/model/chat_message.dart';
import 'package:local_markerplace/chat/model/chat_thread.dart';
import 'package:local_markerplace/chat/presentation/chats_page.dart';
import 'package:local_markerplace/chat/presentation/conversation_page.dart';
import 'package:local_markerplace/chat/repository/chat_repository.dart';
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

Future<void> pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(390 * 3, 1000 * 3);
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

  group('the list', () {
    testWidgets('reads each thread by its last message', (tester) async {
      await pump(tester, ChatsPage(repository: ChatRepository()));

      expect(find.text('Chats'), findsOneWidget);
      expect(find.text('Shahnaz RO & Chimney'), findsOneWidget);
      expect(
        find.text('I can come at 4 instead, does that work?'),
        findsOneWidget,
      );
      // The seeker's own last word is marked as theirs.
      expect(find.text('You: Great, see you tomorrow'), findsOneWidget);
      // An offer is summarised by what it is about, not quoted.
      expect(find.text('Sent an offer on "AC not cooling"'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('search narrows it to one', (tester) async {
      await pump(tester, ChatsPage(repository: ChatRepository()));

      await tester.enterText(find.byType(TextField), 'carpentry');
      await tester.pumpAndSettle();

      expect(find.text('Sharma Carpentry'), findsOneWidget);
      expect(find.text('Shahnaz RO & Chimney'), findsNothing);
    });

    testWidgets('with nothing in it, it offers the two ways to start one', (
      tester,
    ) async {
      await pump(tester, ChatsPage(repository: ChatRepository(threads: [])));

      expect(find.text('No chats yet'), findsOneWidget);
      expect(find.text('Find a provider'), findsOneWidget);
      expect(find.text('Post what you need'), findsOneWidget);
      // Nothing to search, so the field is not offered either.
      expect(find.byType(TextField), findsNothing);
    });
  });

  group('a conversation', () {
    testWidgets('opening it clears the badge and shows the thread', (
      tester,
    ) async {
      final chats = ChatRepository();
      expect(chats.unreadCount, 2);

      await pump(
        tester,
        ConversationPage(
          providerName: 'Shahnaz RO & Chimney',
          repository: chats,
        ),
      );

      expect(chats.unreadCount, 0);
      expect(find.text('Usually replies in 10 min'), findsOneWidget);
      expect(find.text('TODAY'), findsWidgets);
      expect(
        find.text('Booked. ₹899 for two units, gas top-up extra if needed.'),
        findsOneWidget,
      );
    });

    testWidgets('sending adds the message and empties the field', (
      tester,
    ) async {
      final chats = ChatRepository();
      await pump(
        tester,
        ConversationPage(providerName: 'Sharma Carpentry', repository: chats),
      );

      await tester.enterText(find.byType(TextField), 'See you at 10');
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
      await tester.pumpAndSettle();

      expect(find.text('See you at 10'), findsOneWidget);
      final thread = chats.byName('Sharma Carpentry');
      expect(thread.messages.last.text, 'See you at 10');
      expect(thread.messages.last.isMine, isTrue);
      // And it is the newest conversation now.
      expect(chats.threads.first.providerName, 'Sharma Carpentry');
    });

    testWidgets('an offer is answered in the thread', (tester) async {
      final chats = ChatRepository();
      final visits = VisitRepository();

      await pump(
        tester,
        ConversationPage(
          providerName: 'CoolAir AC Service',
          repository: chats,
          visits: visits,
        ),
      );

      expect(find.text('OFFER'), findsOneWidget);
      expect(find.text('₹1,100'), findsOneWidget);
      expect(find.text('On "AC not cooling, makes noise"'), findsOneWidget);
      expect(
        find.text('Accepting shares your number with CoolAir AC Service only.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Accept'));
      await tester.pumpAndSettle();

      // Accepting books it outright, the same as taking an offer on a post.
      expect(find.text('Visit booked'), findsOneWidget);
      expect(visits.booked, hasLength(1));
      expect(visits.booked.single.servicesTotal, 1100);
      expect(visits.booked.single.whenLabel, 'Tomorrow morning');

      Navigator.of(tester.element(find.text('Visit booked'))).pop();
      await tester.pumpAndSettle();

      expect(find.text('Accepted · booked with this provider'), findsOneWidget);
      expect(find.text('Accept'), findsNothing);
    });

    testWidgets('declining leaves the offer in the conversation', (
      tester,
    ) async {
      final chats = ChatRepository();
      await pump(
        tester,
        ConversationPage(providerName: 'CoolAir AC Service', repository: chats),
      );

      await tester.tap(find.text('Decline'));
      await tester.pumpAndSettle();

      // The price stays visible: the reply arguing it down is right below.
      expect(find.text('₹1,100'), findsOneWidget);
      expect(find.text('Declined'), findsOneWidget);
      expect(find.text('Can you do ₹950? I have two units.'), findsOneWidget);
    });
  });

  group('threads', () {
    test('age into the words the list uses', () {
      final now = DateTime.now();
      ChatThread threadAt(Duration ago) => ChatThread(
        providerName: 'Anyone',
        messages: [
          ChatMessage(text: 'hello', sentAt: now.subtract(ago), isMine: false),
        ],
      );

      expect(threadAt(const Duration(minutes: 2)).ageLabel, '2 min');
      expect(threadAt(const Duration(hours: 1)).ageLabel, '1 h');
      expect(threadAt(const Duration(days: 1)).ageLabel, 'yesterday');
      expect(threadAt(const Duration(days: 3)).ageLabel, '3 d');
    });
  });
}
