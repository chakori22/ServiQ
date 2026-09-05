import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:local_markerplace/components/textfield.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_assets.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';

/// The search box on home, which does not take input — tapping it opens the
/// search screen. Drawn to match the real field so the transition between the
/// two reads as the same control.
class DiscoverySearchButton extends StatelessWidget {
  const DiscoverySearchButton({
    super.key,
    required this.onTap,
    this.hintText = 'Search providers',
  });

  final VoidCallback onTap;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 14.6),
        decoration: BoxDecoration(
          color: AppColor.discoveryTint,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColor.discoveryBorder, width: 1.4),
        ),
        child: Row(
          children: [
            SvgPicture.asset(DiscoveryAssets.search, width: 16, height: 16),
            const SizedBox(width: 12),
            Text(hintText, style: DiscoveryText.searchHint),
          ],
        ),
      ),
    );
  }
}

/// The live search field. Renders through the app's shared [AppTextField] so
/// it stays the same control as every other input, with the discovery
/// palette and radius passed in rather than re-implemented.
class DiscoverySearchField extends StatelessWidget {
  const DiscoverySearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    this.autofocus = true,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      onChanged: onChanged,
      autofocus: autofocus,
      hintText: 'Search providers',
      textInputAction: TextInputAction.search,
      fillColor: AppColor.white,
      // The focused field is what the design shows, so the accent border is
      // the field's resting state here rather than a focus-only treatment.
      borderColor: AppColor.discoveryAccent,
      borderWidth: 1.8,
      cornerRadius: 16,
      verticalPadding: 14.2,
      textStyle: DiscoveryText.searchValue,
      hintStyle: DiscoveryText.searchHint,
      prefixIcon: SvgPicture.asset(
        DiscoveryAssets.search,
        width: 16,
        height: 16,
      ),
      // The decorator hands a suffix a 48pt minimum box. Align sizes itself
      // to its child inside that, which keeps the button at the design's
      // 20pt instead of stretching it to fill — and, unlike Center, leaves
      // the entered text its room.
      suffixIcon: controller.text.isEmpty
          ? null
          : GestureDetector(
              onTap: onClear,
              child: Align(
                widthFactor: 1,
                heightFactor: 1,
                child: Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColor.discoveryClearFill,
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    DiscoveryAssets.clearGlyph,
                    width: 8.7,
                    height: 8.7,
                  ),
                ),
              ),
            ),
    );
  }
}
