import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/model/service_category.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';

/// One trade in home's category grid: a glyph on a white disc over a tinted
/// rounded square, with the trade's name underneath.
class CategoryTile extends StatelessWidget {
  const CategoryTile({super.key, required this.category, this.onTap});

  final ServiceCategory category;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 92,
        decoration: BoxDecoration(
          color: AppColor.discoveryTint,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColor.discoveryBorder, width: 1.4),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColor.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColor.discoveryShadow.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SvgPicture.asset(
                category.iconAsset,
                width: 22,
                height: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: DiscoveryText.tileLabel,
            ),
          ],
        ),
      ),
    );
  }
}
