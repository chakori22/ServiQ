import 'package:flutter/material.dart';

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
          // No product photography exists yet, so the design draws a shape on
          // a tinted plate. It stays until real images land.
          Container(
            height: 84,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColor.providerMapFill,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              width: 44,
              height: 34,
              decoration: BoxDecoration(
                color: AppColor.providerImageShape,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Container(height: 1.2, color: AppColor.white),
              ),
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
              GestureDetector(
                onTap: onAdd,
                behavior: HitTestBehavior.opaque,
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
