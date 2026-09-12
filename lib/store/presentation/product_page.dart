import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_markerplace/visit/bloc/quantity_bloc.dart';

import 'package:local_markerplace/components/art/seeded_artwork.dart';
import 'package:local_markerplace/components/motion/entrance.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/core/money.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_header.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/provider/model/store_product.dart';
import 'package:local_markerplace/store/model/cart_product.dart';
import 'package:local_markerplace/visit/presentation/components/cart_bits.dart';
import 'package:local_markerplace/visit/presentation/components/visit_bits.dart';

/// 14 · 01 — one part, and the decision to buy it.
///
/// Pops with the [CartProduct] to add, or with nothing if the seeker backs
/// out. The screen never touches the cart itself: whoever opened it owns the
/// provider the part belongs to, and a part in a cart without its provider
/// is not deliverable.
class ProductPage extends StatelessWidget {
  const ProductPage({
    super.key,
    required this.product,
    required this.localityName,
    this.onBookFitting,
  });

  final StoreProduct product;

  /// Named on the free-delivery line: "Delivery in Ajnara Gen X".
  final String localityName;

  /// Opens the fitting service on the provider's Services tab. Null when
  /// the part has no matching service, and then the offer is left off.
  final VoidCallback? onBookFitting;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuantityBloc(unitPrice: rupeesFrom(product.price)),
      child: _ProductView(
        product: product,
        localityName: localityName,
        onBookFitting: onBookFitting,
      ),
    );
  }
}

class _ProductView extends StatelessWidget {
  const _ProductView({
    required this.product,
    required this.localityName,
    required this.onBookFitting,
  });

  final StoreProduct product;
  final String localityName;
  final VoidCallback? onBookFitting;

  /// Hands the part back to whoever opened the page; putting it in a cart is
  /// theirs to do, since only they know whose cart it is.
  void _add(BuildContext context, QuantityState state) {
    Navigator.of(context).pop(
      CartProduct(
        name: product.name,
        detail: product.detail,
        unitPrice: state.unitPrice,
        quantity: state.quantity,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<QuantityBloc>().state;
    final fitting = product.fittingName;

    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const DiscoveryHeader(title: 'Store'),
            const SizedBox(height: 14),
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColor.discoveryBorder,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // No product photography exists, so the part gets the
                    // same generated artwork it wears on the store grid —
                    // arriving here should look like the tile grew, not like
                    // a different part.
                    FadeSlideIn(
                      child: SizedBox(
                        height: 190,
                        child: SeededArtwork(
                          seed: product.name,
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    FadeSlideIn(
                      index: 1,
                      child: Text(product.name, style: DiscoveryText.meName),
                    ),
                    const SizedBox(height: 10),
                    FadeSlideIn(
                      index: 2,
                      child: Row(
                        children: [
                          Text(product.price, style: DiscoveryText.price),
                          const SizedBox(width: 12),
                          _StockPill(product: product),
                        ],
                      ),
                    ),
                    if (product.detail.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text(
                        product.detail,
                        style: DiscoveryText.caption.copyWith(
                          height: 19 / 12.5,
                        ),
                      ),
                    ],
                    const VisitRule(top: 20, bottom: 18),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Quantity',
                            style: DiscoveryText.rowTitle.copyWith(
                              fontSize: 13.5,
                              color: AppColor.discoveryInkMuted,
                            ),
                          ),
                        ),
                        CartQuantityStepper(
                          value: state.quantity,
                          unitLabel: state.quantity == 1 ? 'Piece' : 'Pieces',
                          onChanged: (value) => context
                              .read<QuantityBloc>()
                              .add(QuantityChanged(value)),
                        ),
                      ],
                    ),
                    if (fitting != null) ...[
                      const SizedBox(height: 22),
                      _FittingOffer(
                        service: fitting,
                        fromPrice: product.fittingFrom ?? '',
                        onTap: onBookFitting,
                      ),
                    ],
                    const VisitRule(top: 22, bottom: 14),
                    TotalRow(
                      label: '${product.name} × ${state.quantity}',
                      value: rupees(state.lineTotal),
                    ),
                    TotalRow(
                      label: 'Delivery in $localityName',
                      value: rupees(0),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          decoration: const BoxDecoration(
            color: AppColor.white,
            border: Border(top: BorderSide(color: AppColor.discoveryBorder)),
          ),
          child: VisitCta(
            label: 'Add to cart · ${rupees(state.lineTotal)}',
            onTap: () => _add(context, state),
          ),
        ),
      ),
    );
  }
}

/// "IN STOCK", or the warning when there are only a couple left.
class _StockPill extends StatelessWidget {
  const _StockPill({required this.product});

  final StoreProduct product;

  @override
  Widget build(BuildContext context) {
    final isLow = product.isLow;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isLow ? AppColor.stockLowTint : AppColor.discoveryLiveTint,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        product.stockLabel.toUpperCase(),
        style: (isLow ? DiscoveryText.stockLow : DiscoveryText.stockIn)
            .copyWith(fontSize: 10, letterSpacing: 0.5),
      ),
    );
  }
}

/// The design's argument for a store attached to a person: whoever sells the
/// part can also fit it, on the same trip.
class _FittingOffer extends StatelessWidget {
  const _FittingOffer({
    required this.service,
    required this.fromPrice,
    required this.onTap,
  });

  final String service;
  final String fromPrice;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      pressedScale: 0.98,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColor.visitEtaTint,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.handyman_outlined,
              size: 20,
              color: AppColor.discoveryGradientEnd,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Need it fitted?',
                    style: DiscoveryText.groupHeading.copyWith(
                      color: AppColor.discoveryGradientEnd,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Add $service to your visit'
                    '${fromPrice.isEmpty ? '' : ' — from $fromPrice'}.',
                    style: DiscoveryText.meta.copyWith(
                      height: 16 / 11.5,
                      color: AppColor.discoveryGradientStart,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: AppColor.discoveryGradientEnd,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
