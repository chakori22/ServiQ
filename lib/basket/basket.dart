import 'package:flutter/material.dart';

import 'package:local_markerplace/basket/checkout_all_page.dart';
import 'package:local_markerplace/basket/your_carts_sheet.dart';
import 'package:local_markerplace/core/money.dart';
import 'package:local_markerplace/discovery/model/pending_booking.dart';
import 'package:local_markerplace/visit/presentation/your_visit_page.dart';
import 'package:local_markerplace/visit/repository/visit_repository.dart';

/// What the bar above the tabs says.
///
/// There is a cart per provider, so the bar names the one last added to and
/// says how many others are behind it. Null when every cart is empty, which
/// is the bar's cue to be absent rather than empty.
PendingBooking? currentBasket({VisitRepository? visits}) {
  final store = visits ?? VisitRepository.shared;
  final newest = store.current;
  if (newest == null) return null;

  final others = store.cartCount - 1;
  return PendingBooking(
    providerName: newest.providerName,
    summary: newest.contentLine,
    amount: rupees(store.grandTotal),
    otherCarts: others,
  );
}

/// Opens one provider's cart.
Future<void> openCart(
  BuildContext context,
  String providerName, {
  VisitRepository? visits,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) =>
          YourVisitPage(providerName: providerName, repository: visits),
    ),
  );
}

/// What the bar does when tapped.
///
/// One cart goes straight to it; several open the list, because with more
/// than one open the seeker has to say which they meant.
Future<void> openBasket(BuildContext context, {VisitRepository? visits}) async {
  final store = visits ?? VisitRepository.shared;
  final newest = store.current;
  if (newest == null) return;

  if (store.cartCount == 1) {
    return openCart(context, newest.providerName, visits: visits);
  }
  await showYourCartsSheet(
    context,
    visits: store,
    onOpenCart: (providerName) =>
        openCart(context, providerName, visits: visits),
    onCheckoutAll: () => Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CheckoutAllPage(repository: visits)),
    ),
  );
}

/// Opens the list of carts directly — the chevron on the bar.
Future<void> openAllCarts(
  BuildContext context, {
  VisitRepository? visits,
}) async {
  final store = visits ?? VisitRepository.shared;
  if (store.isEmpty) return;
  await showYourCartsSheet(
    context,
    visits: store,
    onOpenCart: (providerName) =>
        openCart(context, providerName, visits: visits),
    onCheckoutAll: () => Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CheckoutAllPage(repository: visits)),
    ),
  );
}
