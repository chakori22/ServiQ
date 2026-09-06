import 'package:flutter/material.dart';

import 'package:local_markerplace/core/money.dart';
import 'package:local_markerplace/discovery/model/pending_booking.dart';
import 'package:local_markerplace/visit/presentation/your_visit_page.dart';
import 'package:local_markerplace/visit/repository/visit_repository.dart';

/// What the seeker has in flight.
///
/// Services and parts share one cart, because they share one provider and
/// one trip — a part bought from somebody's store is brought by the person
/// coming to do the work. This is the single place that decides what the bar
/// above the tabs says, so no two screens can disagree about it.
///
/// Returns null when the cart is empty, which is the bar's cue to be absent
/// rather than empty.
PendingBooking? currentBasket({VisitRepository? visits}) {
  final cart = (visits ?? VisitRepository.shared).current;
  if (cart == null) return null;

  return PendingBooking(
    providerName: cart.providerName,
    summary: cart.contentLine,
    amount: rupees(cart.servicesTotal + cart.partsTotal),
  );
}

/// Opens the cart.
Future<void> openBasket(BuildContext context, {VisitRepository? visits}) {
  return Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => YourVisitPage(repository: visits)));
}
