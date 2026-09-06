import 'package:flutter/material.dart';

import 'package:local_markerplace/basket/basket.dart';
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
class AppBottomBar extends StatefulWidget {
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
  State<AppBottomBar> createState() => _AppBottomBarState();
}

class _AppBottomBarState extends State<AppBottomBar> {
  Future<void> _openCart() async {
    await openBasket(context);
    if (!mounted) return;
    setState(() {});
    widget.onCartChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final cart = currentBasket();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (cart != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: PendingBookingBar(booking: cart, onView: _openCart),
          ),
        DiscoveryTabBar(
          current: widget.current,
          onSelect: widget.onSelect,
          onPost: widget.onPost,
        ),
      ],
    );
  }
}
