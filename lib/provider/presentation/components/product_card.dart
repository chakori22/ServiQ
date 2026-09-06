import 'package:flutter/material.dart';

import 'package:local_markerplace/components/art/seeded_artwork.dart';
import 'package:local_markerplace/components/motion/entrance.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/provider/model/store_product.dart';

/// A part on the Store tab: a placeholder photo, the name, price, stock and
/// an Add chip.
class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, this.onAdd});

  final StoreProduct product;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
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
