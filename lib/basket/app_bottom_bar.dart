import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:local_markerplace/basket/basket.dart';
import 'package:local_markerplace/basket/bloc/basket_bloc.dart';
import 'package:local_markerplace/visit/repository/visit_repository.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_tab_bar.dart';
import 'package:local_markerplace/discovery/presentation/components/pending_booking_bar.dart';

/// The app's bottom furniture: the cart, when there is one, sitting above the
/// four tabs.
///
/// Every screen that draws the tab bar uses this instead, so the cart cannot
/// be true on one screen and missing on the next — which is exactly what
/// happened when only the shell carried it and the provider's own page,
/// where things are added, did not.
///
/// It rebuilds itself after the cart is opened, because the seeker may have
/// emptied it in there; [onCartChanged] lets the host refresh whatever it
/// shows about the cart too.
class AppBottomBar extends StatelessWidget {
  const AppBottomBar({
    super.key,
    required this.current,
    required this.onSelect,
    this.onPost,
    this.onCartChanged,
  });

  final DiscoveryTab current;
  final ValueChanged<DiscoveryTab> onSelect;
  final VoidCallback? onPost;

  /// Called after the cart screen closes, for hosts showing a count of their
  /// own — the store grid's chip and its steppers.
  final VoidCallback? onCartChanged;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          BasketBloc(visitRepository: VisitRepository.shared)
            ..add(const BasketRequested()),
      child: _AppBottomBarView(
        current: current,
        onSelect: onSelect,
        onPost: onPost,
        onCartChanged: onCartChanged,
      ),
    );
  }
}

class _AppBottomBarView extends StatelessWidget {
  const _AppBottomBarView({
    required this.current,
    required this.onSelect,
    required this.onPost,
    required this.onCartChanged,
  });

  final DiscoveryTab current;
  final ValueChanged<DiscoveryTab> onSelect;
  final VoidCallback? onPost;
  final VoidCallback? onCartChanged;

  /// The seeker may have emptied the cart in there, so the bar asks again on
  /// the way back and the host is told too.
  Future<void> _openCart(BuildContext context) async {
    final bloc = context.read<BasketBloc>();
    await openBasket(context);
    bloc.add(const BasketRequested());
    onCartChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<BasketBloc>().state.bar;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (cart != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: PendingBookingBar(
              booking: cart,
              onView: () => _openCart(context),
            ),
          ),
        DiscoveryTabBar(current: current, onSelect: onSelect, onPost: onPost),
      ],
    );
  }
}
