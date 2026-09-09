import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/model/service_category.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';

/// What the seeker chose in the filter sheet.
///
/// A class rather than a bare string because "All" and "dismissed without
/// choosing" are different answers that would otherwise both be null: the
/// sheet returns null only when it was closed, and a choice whose [label] is
/// null means every category.
class CategoryChoice {
  const CategoryChoice(this.label);

  /// The category to narrow to, or null for all of them.
  final String? label;

  bool get isAll => label == null;
}

/// The catalogue's filter, as a sheet.
///
/// The chips above the list only fit a few; the server sends twenty-three
/// trades, so the full set needs somewhere it can be read rather than
/// scrolled past sideways. The sheet is that place, and the chips stay as
/// the shortcut to the ones already on screen.
class CategoryFilterSheet extends StatelessWidget {
  const CategoryFilterSheet({
    super.key,
    required this.categories,
    this.selected,
  });

  final List<ServiceCategory> categories;

  /// The category currently applied, or null when the list is unfiltered.
  final String? selected;

  static Future<CategoryChoice?> show(
    BuildContext context, {
    required List<ServiceCategory> categories,
    String? selected,
  }) {
    return showModalBottomSheet<CategoryChoice>(
      context: context,
      backgroundColor: Colors.transparent,
      // Twenty-three rows do not fit a default sheet, and one that cannot
      // reach its own last row is worse than no sheet at all.
      isScrollControlled: true,
      builder: (_) =>
          CategoryFilterSheet(categories: categories, selected: selected),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.72,
      ),
      decoration: const BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColor.discoveryBorder,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Filter by category',
                style: DiscoveryText.sheetTitle,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                children: [
                  _Row(
                    label: 'All categories',
                    icon: Icons.grid_view_rounded,
                    isSelected: selected == null,
                    onTap: () =>
                        Navigator.of(context).pop(const CategoryChoice(null)),
                  ),
                  for (final category in categories) ...[
                    const SizedBox(height: 10),
                    _Row(
                      label: category.label,
                      icon: category.icon,
                      iconAsset: category.iconAsset,
                      isSelected: selected == category.label,
                      onTap: () => Navigator.of(
                        context,
                      ).pop(CategoryChoice(category.label)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One category, with the tile's own glyph so the sheet reads as the grid
/// does rather than as a list of words.
class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.iconAsset = '',
  });

  final String label;
  final IconData? icon;
  final String iconAsset;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final glyph = icon;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColor.discoveryTint
              : AppColor.providerNoteFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColor.discoveryAccent : Colors.transparent,
            width: 1.4,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColor.white,
                shape: BoxShape.circle,
              ),
              child: iconAsset.isNotEmpty
                  ? SvgPicture.asset(iconAsset, width: 17, height: 17)
                  : Icon(
                      glyph ?? Icons.handyman_outlined,
                      size: 17,
                      color: AppColor.discoveryAccent,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: DiscoveryText.rowTitle,
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_rounded,
                size: 20,
                color: AppColor.discoveryAccent,
              ),
          ],
        ),
      ),
    );
  }
}
