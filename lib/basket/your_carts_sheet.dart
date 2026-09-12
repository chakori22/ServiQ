import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_markerplace/basket/bloc/basket_bloc.dart';

import 'package:local_markerplace/components/art/seeded_artwork.dart';
import 'package:local_markerplace/components/motion/entrance.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/core/money.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/visit/model/visit.dart';
import 'package:local_markerplace/visit/repository/visit_repository.dart';

/// What the seeker chose off this sheet.
enum CartsAction { openedCart, checkedOutAll }

/// Every cart the seeker has open, one row per store.
///
/// It exists because a cart belongs to a provider: shopping the society
/// leaves several on the go, and the bar above the tabs can only name one of
/// them. This is where the rest are.
Future<CartsAction?> showYourCartsSheet(
  BuildContext context, {
  VisitRepository? visits,
  required Future<void> Function(String providerName) onOpenCart,
  required Future<void> Function() onCheckoutAll,
}) {
  return showModalBottomSheet<CartsAction>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColor.white,
    barrierColor: AppColor.discoveryInk.withValues(alpha: 0.45),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.8,
    ),
    builder: (_) => _YourCartsSheet(
      visits: visits ?? VisitRepository.shared,
      onOpenCart: onOpenCart,
      onCheckoutAll: onCheckoutAll,
    ),
  );
}

class _YourCartsSheet extends StatelessWidget {
  const _YourCartsSheet({
    required this.visits,
    required this.onOpenCart,
    required this.onCheckoutAll,
  });

  final VisitRepository visits;
  final Future<void> Function(String providerName) onOpenCart;
  final Future<void> Function() onCheckoutAll;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          BasketBloc(visitRepository: visits)..add(const BasketRequested()),
      child: _YourCartsView(
        onOpenCart: onOpenCart,
        onCheckoutAll: onCheckoutAll,
      ),
    );
  }
}

class _YourCartsView extends StatelessWidget {
  const _YourCartsView({required this.onOpenCart, required this.onCheckoutAll});

  final Future<void> Function(String providerName) onOpenCart;
  final Future<void> Function() onCheckoutAll;

  Future<void> _open(BuildContext context, String providerName) async {
    Navigator.of(context).pop(CartsAction.openedCart);
    await onOpenCart(providerName);
  }

  Future<void> _checkoutAll(BuildContext context) async {
    Navigator.of(context).pop(CartsAction.checkedOutAll);
    await onCheckoutAll();
  }

  /// Taking the last cart away leaves nothing to show, so the sheet goes
  /// with it.
  void _remove(BuildContext context, String providerName) {
    final bloc = context.read<BasketBloc>()..add(CartRemoved(providerName));
    if (bloc.state.isEmpty) Navigator.of(context).pop();
  }

  Future<void> _clearAll(BuildContext context) async {
    final bloc = context.read<BasketBloc>();
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColor.white,
        title: Text('Clear every cart?', style: DiscoveryText.sheetTitle),
        content: Text(
          'This empties all ${context.read<BasketBloc>().state.cartCount} '
          'carts. It cannot be undone.',
          style: DiscoveryText.caption,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Keep them', style: DiscoveryText.sheetOption),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Clear all', style: DiscoveryText.sheetOptionDanger),
          ),
        ],
      ),
    );
    if (sure != true || !context.mounted) return;
    bloc.add(const BasketCleared());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BasketBloc>().state;
    final carts = state.carts;
    if (carts.isEmpty) return const SizedBox.shrink();

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Row(
              children: [
                Expanded(
                  child: Text('Your carts', style: DiscoveryText.sectionTitle),
                ),
                PressableScale(
                  onTap: () => _clearAll(context),
                  pressedScale: 0.92,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    child: Text('Clear all', style: DiscoveryText.danger),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: carts.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) => CartRow(
                cart: carts[index],
                onOpen: () => _open(context, carts[index].providerName),
                onRemove: () => _remove(context, carts[index].providerName),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: _CheckoutAll(
              carts: carts,
              total: state.grandTotal,
              onTap: () => _checkoutAll(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// One store's cart: whose it is, what is in it, and the two things that can
/// be done with it.
class CartRow extends StatelessWidget {
  const CartRow({
    super.key,
    required this.cart,
    required this.onOpen,
    required this.onRemove,
  });

  final Visit cart;
  final VoidCallback onOpen;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final count = cart.serviceCount + cart.partCount;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColor.discoveryTint,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 46,
            height: 46,
            child: SeededArtwork(
              seed: cart.providerName,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cart.providerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DiscoveryText.rowTitle.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 3),
                Text(
                  '${cart.contentLine} · '
                  '${rupees(cart.servicesTotal + cart.partsTotal)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DiscoveryText.smallPrint,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          PressableScale(
            onTap: onOpen,
            pressedScale: 0.94,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: const LinearGradient(
                  colors: [
                    AppColor.discoveryGradientStart,
                    AppColor.discoveryGradientEnd,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View cart',
                    style: DiscoveryText.onAccent(12.5, letterSpacing: -0.125),
                  ),
                  Text(
                    '$count ${count == 1 ? 'item' : 'items'}',
                    style: DiscoveryText.onAccent(
                      10.5,
                      letterSpacing: 0,
                    ).copyWith(color: AppColor.white.withValues(alpha: 0.8)),
                  ),
                ],
              ),
            ),
          ),
          PressableScale(
            onTap: onRemove,
            pressedScale: 0.85,
            child: const SizedBox(
              width: 34,
              height: 34,
              child: Icon(
                Icons.close_rounded,
                size: 17,
                color: AppColor.discoveryTextTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Takes every cart to checkout at once, and says which are not ready.
class _CheckoutAll extends StatelessWidget {
  const _CheckoutAll({
    required this.carts,
    required this.total,
    required this.onTap,
  });

  final List<Visit> carts;
  final double total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final untimed = carts.where((cart) => !cart.isReady).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (untimed > 0) ...[
          Text(
            untimed == carts.length
                ? 'Each cart needs a time before it can be booked.'
                : '$untimed of ${carts.length} still need a time. You can '
                      'choose them on the next screen.',
            textAlign: TextAlign.center,
            style: DiscoveryText.fine,
          ),
          const SizedBox(height: 10),
        ],
        PressableScale(
          onTap: onTap,
          pressedScale: 0.97,
          child: Container(
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [
                  AppColor.discoveryGradientStart,
                  AppColor.discoveryGradientEnd,
                ],
              ),
            ),
            child: Text(
              'Checkout all · ${rupees(total)}',
              style: DiscoveryText.onAccent(16, letterSpacing: -0.16),
            ),
          ),
        ),
      ],
    );
  }
}
