import 'package:flutter/material.dart';

import 'package:local_markerplace/components/art/seeded_artwork.dart';
import 'package:local_markerplace/components/motion/entrance.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/provider/model/store_product.dart';

/// A part on the Store tab: a placeholder photo, the name, price, stock and
/// an Add chip.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onAdd,
    this.onTap,
    this.quantityInCart = 0,
    this.onIncrement,
    this.onDecrement,
  });

  final StoreProduct product;
  final VoidCallback? onAdd;

  /// Opens the part's own screen. The Add chip goes there too — the design
  /// asks for a quantity before anything reaches the cart.
  final VoidCallback? onTap;

  /// How many of this part are already in the cart. Above zero the Add chip
  /// becomes the stepper that is editing that number, so the grid can be
  /// adjusted without opening the cart.
  final int quantityInCart;

  final VoidCallback? onIncrement;

  /// Steps the count down, and at one takes the part out — which is why the
  /// button wears a bin at that point rather than a minus.
  final VoidCallback? onDecrement;

  @override
  Widget build(BuildContext context) {
    return PressableScale(onTap: onTap, pressedScale: 0.98, child: _card());
  }

  Widget _card() {
    return Container(
      padding: const EdgeInsets.all(9.2),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColor.discoveryBorder, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: AppColor.discoveryShadow.withValues(alpha: 0.05),
            blurRadius: 7,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // No product photography exists yet. Rather than the grey plate
          // with a shape on it that the design falls back to, each part gets
          // artwork generated from its own name — so a grid of eight parts
          // is eight distinguishable tiles instead of eight identical ones.
          SizedBox(
            height: 84,
            width: double.infinity,
            child: SeededArtwork(
              seed: product.name,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 32,
            child: Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: DiscoveryText.productName,
            ),
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.price,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DiscoveryText.productPrice,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      product.stockLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: product.isLow
                          ? DiscoveryText.stockLow
                          : DiscoveryText.stockIn,
                    ),
                  ],
                ),
              ),
              if (quantityInCart > 0)
                _CartStepper(
                  quantity: quantityInCart,
                  onIncrement: onIncrement,
                  onDecrement: onDecrement,
                )
              else
                PressableScale(
                  onTap: onAdd,
                  pressedScale: 0.9,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.providerChipFill,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text('Add', style: DiscoveryText.addChip),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Bin-or-minus, the count, plus — what the Add chip becomes once the part
/// is in the cart.
class _CartStepper extends StatelessWidget {
  const _CartStepper({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int quantity;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  @override
  Widget build(BuildContext context) {
    final isLast = quantity <= 1;

    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: AppColor.providerChipFill,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            // The last one leaves the cart rather than becoming zero, so the
            // button says so before it is pressed.
            icon: isLast ? Icons.delete_outline_rounded : Icons.remove_rounded,
            color: isLast ? AppColor.authError : AppColor.discoveryGradientEnd,
            onTap: onDecrement,
          ),
          Text('$quantity', style: DiscoveryText.addChip),
          _StepperButton(
            icon: Icons.add_rounded,
            color: AppColor.discoveryGradientEnd,
            onTap: onIncrement,
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      pressedScale: 0.82,
      child: SizedBox(
        width: 30,
        height: 30,
        child: Icon(icon, size: 15, color: color),
      ),
    );
  }
}
