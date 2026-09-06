import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:local_markerplace/provider/model/store_product.dart';
import 'package:local_markerplace/store/model/cart_product.dart';
import 'package:local_markerplace/store/presentation/product_page.dart';
import 'package:local_markerplace/visit/model/visit_service.dart';
import 'package:local_markerplace/visit/repository/visit_repository.dart';

const shahnaz = 'Shahnaz RO & Chimney';
const shahnazLine = 'Ajnara Gen X · usually replies in 10 min';

const roFilter = StoreProduct(
  name: 'RO Filter Set (3 stage)',
  price: '₹1,200',
  stockLabel: 'In stock',
  detail: 'Sediment, pre-carbon and post-carbon.',
  fittingName: 'RO Filter Change',
  fittingFrom: '₹349',
);

/// A cart with the design's three parts: one filter set and two sediment
/// filters, ₹1,900 all in.
VisitRepository seededCart() => VisitRepository()
  ..addProduct(
    providerName: shahnaz,
    providerLine: shahnazLine,
    product: const CartProduct(
      name: 'RO Filter Set (3 stage)',
      detail: '',
      unitPrice: 1200,
    ),
  )
  ..addProduct(
    providerName: shahnaz,
    providerLine: shahnazLine,
    product: const CartProduct(
      name: 'Sediment Filter 10"',
      detail: '',
      unitPrice: 350,
      quantity: 2,
    ),
  );

Future<void> pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(390 * 3, 1800 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(useMaterial3: true, fontFamily: 'Mulish'),
      home: child,
    ),
  );
  await tester.pump(const Duration(seconds: 1));
}

/// Bills and pills are laid out tightly, so the real typeface has to be in
/// place or they measure wide enough to overflow.
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

  group('parts go in the same cart as services', () {
    test('they are counted by the piece, not by the line', () {
      expect(seededCart().current!.partCount, 3);
    });

    test('the cart totals both halves', () {
      final visits = seededCart()
        ..addService(
          providerName: shahnaz,
          providerLine: shahnazLine,
          service: const VisitService(
            name: 'RO Filter Change',
            detail: '',
            unitPrice: 349,
          ),
        );

      final cart = visits.current!;
      expect(cart.partsTotal, 1900);
      expect(cart.servicesTotal, 349);
      expect(cart.estimate, 2249);
      expect(cart.contentLine, '1 service · 3 parts');
    });

    test('adding the same part twice makes one line', () {
      final visits = seededCart()
        ..addProduct(
          providerName: shahnaz,
          providerLine: shahnazLine,
          product: const CartProduct(
            name: 'RO Filter Set (3 stage)',
            detail: '',
            unitPrice: 1200,
          ),
        );
      expect(visits.current!.parts.length, 2);
      expect(visits.current!.parts.first.quantity, 2);
    });

    test('another provider starts a new cart rather than mixing them', () {
      final visits = seededCart();
      final replaced = visits.addProduct(
        providerName: 'Delhi Cool Care',
        providerLine: 'Ajnara Gen X',
        product: const CartProduct(
          name: 'AC Gas Top-up Kit',
          detail: '',
          unitPrice: 600,
        ),
      );
      expect(replaced, isTrue);
      expect(visits.current!.providerName, 'Delhi Cool Care');
      expect(visits.current!.partCount, 1);
    });

    test('taking out the last part empties the cart', () {
      final visits = VisitRepository()
        ..addProduct(
          providerName: shahnaz,
          providerLine: shahnazLine,
          product: const CartProduct(
            name: 'RO Filter Set (3 stage)',
            detail: '',
            unitPrice: 1200,
          ),
        )
        ..removePartAt(0);
      expect(visits.current, isNull);
    });

    test('a part goes when its service stays', () {
      final visits = seededCart()
        ..addService(
          providerName: shahnaz,
          providerLine: shahnazLine,
          service: const VisitService(
            name: 'RO Filter Change',
            detail: '',
            unitPrice: 349,
          ),
        )
        ..removePartAt(0)
        ..removePartAt(0);

      expect(visits.current, isNotNull);
      expect(visits.current!.parts, isEmpty);
      expect(visits.current!.services, hasLength(1));
    });
  });

  group('a part on its own', () {
    testWidgets('quantity moves the price on the button', (tester) async {
      await pump(
        tester,
        const ProductPage(product: roFilter, localityName: 'Ajnara Gen X'),
      );

      expect(find.text('Add to cart · ₹1,200'), findsOneWidget);
      expect(find.text('IN STOCK'), findsOneWidget);
      // The provider sells the part and can also fit it.
      expect(find.text('Need it fitted?'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Add to cart · ₹2,400'), findsOneWidget);
    });

    testWidgets('it pops with what was chosen, and adds nothing itself', (
      tester,
    ) async {
      CartProduct? popped;
      await pump(
        tester,
        Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              popped = await Navigator.of(context).push<CartProduct>(
                MaterialPageRoute(
                  builder: (_) => const ProductPage(
                    product: roFilter,
                    localityName: 'Ajnara Gen X',
                  ),
                ),
              );
            },
            child: const Text('open'),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add to cart · ₹1,200'));
      await tester.pumpAndSettle();

      expect(popped?.name, 'RO Filter Set (3 stage)');
      expect(popped?.unitPrice, 1200);
    });
  });
}
