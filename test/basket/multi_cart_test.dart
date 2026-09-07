import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:local_markerplace/basket/basket.dart';
import 'package:local_markerplace/basket/checkout_all_page.dart';
import 'package:local_markerplace/basket/your_carts_sheet.dart';
import 'package:local_markerplace/discovery/presentation/components/pending_booking_bar.dart';
import 'package:local_markerplace/store/model/cart_product.dart';
import 'package:local_markerplace/visit/model/visit_mode.dart';
import 'package:local_markerplace/visit/model/visit_service.dart';
import 'package:local_markerplace/visit/repository/visit_repository.dart';

const shahnaz = 'Shahnaz RO & Chimney';
const coolair = 'CoolAir AC Service';
const sharma = 'Sharma Carpentry';

/// Three carts, one per store.
VisitRepository threeCarts() {
  final visits = VisitRepository()
    ..addService(
      providerName: shahnaz,
      providerLine: 'Ajnara Gen X',
      service: const VisitService(
        name: 'RO Filter Change',
        detail: '',
        unitPrice: 349,
      ),
    )
    ..addProduct(
      providerName: coolair,
      providerLine: 'Ajnara Gen X',
      product: const CartProduct(
        name: 'AC Air Filter (split)',
        detail: '',
        unitPrice: 450,
        quantity: 2,
      ),
    )
    ..addService(
      providerName: sharma,
      providerLine: 'Ajnara Gen X',
      service: const VisitService(
        name: 'Furniture Repair',
        detail: '',
        unitPrice: 399,
      ),
    );
  return visits;
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

  group('a cart per store', () {
    test('adding from a second store does not displace the first', () {
      final visits = threeCarts();

      expect(visits.cartCount, 3);
      expect(visits.cartFor(shahnaz), isNotNull);
      expect(visits.cartFor(coolair), isNotNull);
      expect(visits.cartFor(sharma), isNotNull);
      // Services and parts across all three.
      expect(visits.itemCount, 4);
      expect(visits.grandTotal, 349 + 900 + 399);
    });

    test('the newest cart leads, so the bar names what was just added', () {
      final visits = threeCarts();
      expect(visits.current!.providerName, sharma);

      visits.addService(
        providerName: shahnaz,
        providerLine: 'Ajnara Gen X',
        service: const VisitService(
          name: 'RO Service & Repair',
          detail: '',
          unitPrice: 499,
        ),
      );
      expect(visits.current!.providerName, shahnaz);
      expect(visits.cartCount, 3);
    });

    test('emptying one leaves the others alone', () {
      final visits = threeCarts()..removeServiceAt(sharma, 0);

      expect(visits.cartFor(sharma), isNull);
      expect(visits.cartCount, 2);
      expect(visits.cartFor(shahnaz), isNotNull);
    });

    test('removing and clearing', () {
      final visits = threeCarts()..removeCart(coolair);
      expect(visits.cartCount, 2);

      visits.clear();
      expect(visits.isEmpty, isTrue);
    });

    test('editing one cart cannot touch another', () {
      final visits = threeCarts()..setMode(shahnaz, VisitMode.instant);

      expect(visits.cartFor(shahnaz)!.mode, VisitMode.instant);
      expect(visits.cartFor(coolair)!.mode, isNull);
      expect(visits.cartFor(sharma)!.mode, isNull);
    });
  });

  group('the bar', () {
    testWidgets('names the newest cart and counts the rest', (tester) async {
      final visits = threeCarts();
      final booking = currentBasket(visits: visits)!;

      expect(booking.providerName, sharma);
      expect(booking.otherCarts, 2);
      // The amount is every cart together, not just the one named.
      expect(booking.amount, '₹1,648');

      await pump(
        tester,
        Scaffold(bottomNavigationBar: PendingBookingBar(booking: booking)),
      );
      expect(find.text('$sharma + 2 more'), findsOneWidget);
      expect(find.text('View carts'), findsOneWidget);
    });

    test('is absent when every cart is empty', () {
      expect(currentBasket(visits: VisitRepository()), isNull);
    });
  });

  group('checking out every cart', () {
    testWidgets('each store is listed, and untimed ones are called out', (
      tester,
    ) async {
      final visits = threeCarts()..setMode(shahnaz, VisitMode.instant);

      await pump(tester, CheckoutAllPage(repository: visits));

      expect(find.text('3 carts · 4 items'), findsOneWidget);
      expect(find.text(shahnaz), findsWidgets);
      expect(find.text(coolair), findsWidgets);
      expect(find.text(sharma), findsWidgets);
      // Only the instant one can go; the other two still need a time.
      expect(find.text('No time chosen yet'), findsNWidgets(2));
      expect(find.text('Choose a time'), findsNWidgets(2));
      expect(find.textContaining('Confirm 1 of 3'), findsOneWidget);
    });

    testWidgets('opening a cart from here and coming back makes it ready', (
      tester,
    ) async {
      final visits = threeCarts();
      await pump(tester, CheckoutAllPage(repository: visits));

      expect(find.textContaining('Choose a time to continue'), findsOneWidget);

      // The seeker taps through to one cart, sees it is on Instant, and
      // comes straight back — which used to leave the cart untimed and the
      // confirm button dead.
      await tester.tap(find.text('Choose a time').first);
      await tester.pumpAndSettle();
      expect(find.text('My Cart'), findsOneWidget);

      Navigator.of(tester.element(find.text('My Cart'))).pop();
      await tester.pumpAndSettle();

      expect(find.textContaining('Confirm 1 of 3'), findsOneWidget);
    });

    testWidgets('confirming books the ready ones and keeps the rest', (
      tester,
    ) async {
      final visits = threeCarts()
        ..setMode(shahnaz, VisitMode.instant)
        ..setMode(coolair, VisitMode.instant);

      await pump(tester, CheckoutAllPage(repository: visits));
      await tester.tap(find.textContaining('Confirm 2 of 3'));
      await tester.pumpAndSettle();

      expect(find.text('2 visits booked'), findsOneWidget);
      expect(visits.booked, hasLength(2));
      // The carpenter had no time, so their cart is still waiting.
      expect(visits.cartCount, 1);
      expect(visits.cartFor(sharma), isNotNull);
    });
  });

  group('the carts sheet', () {
    testWidgets('lists every cart and can drop one', (tester) async {
      final visits = threeCarts();
      String? opened;

      await pump(
        tester,
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => showYourCartsSheet(
                  context,
                  visits: visits,
                  onOpenCart: (name) async => opened = name,
                  onCheckoutAll: () async {},
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Your carts'), findsOneWidget);
      expect(find.byType(CartRow), findsNWidgets(3));
      expect(find.textContaining('Checkout all'), findsOneWidget);

      // The × on a row drops that store's cart only.
      await tester.tap(find.byIcon(Icons.close_rounded).first);
      await tester.pumpAndSettle();
      expect(visits.cartCount, 2);
      expect(find.byType(CartRow), findsNWidgets(2));

      await tester.tap(find.text('View cart').first);
      await tester.pumpAndSettle();
      expect(opened, isNotNull);
    });
  });
}
