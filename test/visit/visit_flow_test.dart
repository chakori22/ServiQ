import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:local_markerplace/visit/model/visit_mode.dart';
import 'package:local_markerplace/store/model/cart_product.dart';
import 'package:local_markerplace/visit/model/visit_service.dart';
import 'package:local_markerplace/visit/presentation/your_visit_page.dart';
import 'package:local_markerplace/visit/repository/visit_repository.dart';

const shahnaz = 'Shahnaz RO & Chimney';

VisitRepository seededVisit() => VisitRepository()
  ..addService(
    providerName: shahnaz,
    providerLine: 'Ajnara Gen X · usually replies in 10 min',
    service: const VisitService(
      name: 'AC Servicing',
      detail: 'Split & window',
      unitPrice: 499,
    ),
  );

/// Pumps the flow the way the app reaches it: a screen the seeker came from,
/// with the visit pushed on top. The route underneath is what "back" has to
/// find again.
Future<void> pumpFlow(WidgetTester tester, VisitRepository visits) async {
  tester.view.physicalSize = const Size(390 * 3, 1800 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(useMaterial3: true, fontFamily: 'Mulish'),
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => YourVisitPage(repository: visits),
                ),
              ),
              child: const Text('where I came from'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('where I came from'));
  await tester.pumpAndSettle();
}

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

  group('the cart', () {
    testWidgets('opens on Instant and prices the fee into the button', (
      tester,
    ) async {
      await pumpFlow(tester, seededVisit());

      expect(find.text('My Cart'), findsOneWidget);
      expect(find.text('Review booking'), findsOneWidget);
      expect(find.text('1 service'), findsOneWidget);
      // ₹499 for the job, ₹99 for coming now.
      expect(find.text('Confirm booking · ₹598'), findsOneWidget);
    });

    testWidgets('switching to Scheduled asks for a time first', (tester) async {
      final visits = seededVisit();
      await pumpFlow(tester, visits);

      await tester.tap(find.text('Scheduled'));
      await tester.pump(const Duration(seconds: 1));

      // Nothing has been picked, so the booking cannot go ahead and the
      // instant fee is off the bill.
      expect(visits.current!.slot, isNull);
      expect(find.text('No time chosen yet'), findsOneWidget);
      expect(find.text('Select time slot'), findsOneWidget);
      expect(find.text('Confirm booking · ₹598'), findsNothing);
    });

    testWidgets('the slot sheet fills in the booking details', (tester) async {
      final visits = seededVisit();
      await pumpFlow(tester, visits);

      await tester.tap(find.text('Scheduled'));
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('Select time slot'));
      await tester.pumpAndSettle();

      expect(find.text('Select start time of service'), findsOneWidget);
      // Confirm stays inert until a time is chosen.
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(find.text('Select start time of service'), findsOneWidget);

      // The sheet opens on the first day with anything free, which is not
      // today once today's starts have gone by.
      final day = visits.days().firstWhere(
        (d) => d.slots.any((slot) => slot.isFree),
      );
      final free = day.slots.firstWhere((slot) => slot.isFree);
      await tester.tap(find.text(free.timeLabel).first);
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(visits.current!.slot, isNotNull);
      expect(find.text('Scheduled for'), findsOneWidget);
      expect(find.text('Change slot'), findsOneWidget);
      expect(find.text('Confirm booking · ₹499'), findsOneWidget);
    });

    testWidgets('Recurring keeps the repeat on the booking', (tester) async {
      final visits = seededVisit();
      await pumpFlow(tester, visits);

      await tester.tap(find.text('Recurring'));
      await tester.pump(const Duration(seconds: 1));

      expect(visits.current!.mode, VisitMode.recurring);
      expect(visits.current!.recurrence, VisitRecurrence.weekly);

      await tester.tap(find.text('Every month'));
      await tester.pump(const Duration(seconds: 1));
      expect(visits.current!.recurrence, VisitRecurrence.monthly);
      // Still no time, so it is not bookable yet.
      expect(find.text('Select time slot'), findsOneWidget);
    });

    testWidgets('the stepper edits the count and empties the line', (
      tester,
    ) async {
      final visits = seededVisit();
      await pumpFlow(tester, visits);

      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pump(const Duration(seconds: 1));
      expect(visits.current!.services.single.quantity, 2);
      expect(find.text('Units'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.remove_rounded));
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pump(const Duration(seconds: 1));

      expect(visits.current, isNull);
      expect(find.textContaining('Nothing in your cart yet'), findsOneWidget);
    });
  });

  group('services and parts share one cart', () {
    testWidgets('both are listed, and the bill separates them', (tester) async {
      final visits = seededVisit()
        ..addProduct(
          providerName: shahnaz,
          providerLine: 'Ajnara Gen X · usually replies in 10 min',
          product: const CartProduct(
            name: 'RO Filter Set (3 stage)',
            detail: '',
            unitPrice: 1200,
          ),
        );

      await pumpFlow(tester, visits);

      expect(find.text('1 service · 1 part'), findsOneWidget);
      expect(find.text('AC Servicing'), findsOneWidget);
      expect(find.text('RO Filter Set (3 stage)'), findsOneWidget);
      // The unit under each stepper is what tells them apart.
      expect(find.text('Unit'), findsOneWidget);
      expect(find.text('Piece'), findsOneWidget);

      // The bill keeps them on separate lines and adds the instant fee.
      expect(find.text('Services'), findsOneWidget);
      expect(find.text('Parts'), findsOneWidget);
      expect(find.text('₹1,798'), findsOneWidget);
      expect(find.text('Confirm booking · ₹1,798'), findsOneWidget);
    });

    testWidgets('emptying the services leaves the parts in the cart', (
      tester,
    ) async {
      final visits = seededVisit()
        ..addProduct(
          providerName: shahnaz,
          providerLine: 'Ajnara Gen X',
          product: const CartProduct(
            name: 'RO Filter Set (3 stage)',
            detail: '',
            unitPrice: 1200,
          ),
        );

      await pumpFlow(tester, visits);
      await tester.tap(find.byIcon(Icons.delete_outline_rounded).first);
      await tester.pump(const Duration(seconds: 1));

      expect(visits.current, isNotNull);
      expect(visits.current!.services, isEmpty);
      expect(visits.current!.parts, hasLength(1));
      expect(find.text('1 part'), findsOneWidget);
    });
  });

  group('once a visit is booked', () {
    /// Instant, confirm, booked — the shortest path to the receipt.
    Future<void> book(WidgetTester tester, VisitRepository visits) async {
      await pumpFlow(tester, visits);
      // The cart opens on Instant, so the service (₹499) plus the instant
      // fee (₹99) is what the button offers to confirm.
      await tester.tap(find.text(VisitMode.instant.label));
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('Confirm booking · ₹598'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm visit').last);
      await tester.pumpAndSettle();
      expect(find.text('Visit booked'), findsOneWidget);
    }

    testWidgets('the receipt is not a dead end', (tester) async {
      final visits = seededVisit();
      await book(tester, visits);

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      // Back where the seeker started, not on a visit that no longer exists.
      expect(find.text('where I came from'), findsOneWidget);
      expect(find.text('Visit booked'), findsNothing);
    });

    testWidgets('the system back does not land on the emptied visit', (
      tester,
    ) async {
      final visits = seededVisit();
      await book(tester, visits);

      // Everything between the receipt and where the seeker started was
      // removed when the visit was confirmed.
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.pop();
      await tester.pumpAndSettle();

      expect(find.text('where I came from'), findsOneWidget);
      expect(
        find.text(
          'Nothing on this visit yet. Add a service from a '
          'provider to start one.',
        ),
        findsNothing,
      );
    });
  });
}
