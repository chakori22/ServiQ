import 'package:flutter/material.dart';

import 'package:local_markerplace/components/motion/app_motion.dart';
import 'package:local_markerplace/components/motion/entrance.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/visit/model/visit_mode.dart';

/// The three ways a booking can be timed, as one pill at the top of the
/// cart. The chosen one fills; the rest sit on the pill's white ground.
class CartModeTabs extends StatelessWidget {
  const CartModeTabs({
    super.key,
    required this.selected,
    required this.onSelect,
    this.disabled = const <VisitMode>{},
  });

  final VisitMode? selected;
  final ValueChanged<VisitMode> onSelect;

  /// Modes that cannot be taken right now — instant, when nobody is free.
  /// They stay on the pill, greyed, rather than disappearing, so the seeker
  /// can see the option exists.
  final Set<VisitMode> disabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColor.discoveryBorder, width: 1.4),
      ),
      child: Row(
        children: [
          for (final mode in VisitMode.values)
            Expanded(
              child: _ModeTab(
                mode: mode,
                isSelected: mode == selected,
                isDisabled: disabled.contains(mode),
                onTap: () => onSelect(mode),
              ),
            ),
        ],
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.mode,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
  });

  final VisitMode mode;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      // A disabled mode still answers, because the cart uses the tap to say
      // why it cannot be taken.
      onTap: onTap,
      pressedScale: 0.96,
      child: AnimatedContainer(
        duration: AppMotion.quick,
        curve: AppMotion.emphasized,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? (isDisabled
                    ? AppColor.buttonDisabledFill
                    : AppColor.discoveryGradientEnd)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: AnimatedDefaultTextStyle(
          duration: AppMotion.quick,
          curve: AppMotion.emphasized,
          style: isSelected && !isDisabled
              ? DiscoveryText.onAccent(14, letterSpacing: -0.14)
              : DiscoveryText.rowTitle.copyWith(
                  fontSize: 14,
                  color: isDisabled
                      ? AppColor.discoveryTextDisabled
                      : AppColor.discoveryInk,
                ),
          child: Text(mode.label, maxLines: 1),
        ),
      ),
    );
  }
}

/// A white card with the cart's corner radius. Every block on the screen is
/// one of these, sitting on the tinted page.
class CartCard extends StatelessWidget {
  const CartCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColor.discoveryShadow.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
    if (onTap == null) return card;
    return PressableScale(onTap: onTap, pressedScale: 0.99, child: card);
  }
}

/// "Review booking" / "Booking details" — a heading over a card, with an
/// optional count on the right.
class CartSectionHeading extends StatelessWidget {
  const CartSectionHeading({super.key, required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
      child: Row(
        children: [
          Expanded(child: Text(title, style: DiscoveryText.sectionTitle)),
          if (trailing != null)
            Text(
              trailing!,
              style: DiscoveryText.rowTitle.copyWith(fontSize: 13),
            ),
        ],
      ),
    );
  }
}

/// The quantity control on a booked service: an outlined accent box with the
/// count between a minus and a plus, and its unit named underneath.
class CartQuantityStepper extends StatelessWidget {
  const CartQuantityStepper({
    super.key,
    required this.value,
    required this.unitLabel,
    required this.onChanged,
    this.minimum = 1,
  });

  final int value;
  final String unitLabel;
  final ValueChanged<int> onChanged;

  /// One on a service the cart removes elsewhere; zero where stepping down
  /// past the last one should take it out.
  final int minimum;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 104,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppColor.visitEtaTint,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColor.discoveryAccent, width: 1.4),
            ),
            child: Row(
              children: [
                _StepButton(
                  // At one, stepping down empties the line rather than
                  // reaching zero, so the button says so before it is
                  // pressed.
                  icon: minimum == 0 && value <= 1
                      ? Icons.delete_outline_rounded
                      : Icons.remove_rounded,
                  onTap: value > minimum ? () => onChanged(value - 1) : null,
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '$value',
                      style: DiscoveryText.rowTitle.copyWith(
                        fontSize: 15,
                        color: AppColor.discoveryGradientEnd,
                      ),
                    ),
                  ),
                ),
                _StepButton(
                  icon: Icons.add_rounded,
                  onTap: value < 20 ? () => onChanged(value + 1) : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 3),
          Text(unitLabel, style: DiscoveryText.fine),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      pressedScale: 0.82,
      child: SizedBox(
        width: 32,
        height: 42,
        child: Icon(
          icon,
          size: 17,
          color: onTap == null
              ? AppColor.discoveryTextDisabled
              : AppColor.discoveryAccent,
        ),
      ),
    );
  }
}

/// A quiet note inside a card — "slots may vary", and the like.
class CartNote extends StatelessWidget {
  const CartNote({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.discoveryTint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: AppColor.discoveryTextTertiary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: DiscoveryText.smallPrint.copyWith(height: 17 / 11.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// A row inside the booking-details card: an icon, a title, a line under it,
/// and a chevron where it can be changed.
class CartDetailRow extends StatelessWidget {
  const CartDetailRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.link,
    this.onLinkTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  /// An inline action under the subtitle — "Change slot" — used where a
  /// chevron would be the wrong affordance.
  final String? link;
  final VoidCallback? onLinkTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      pressedScale: onTap == null ? 1 : 0.99,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 20, color: AppColor.discoveryInkMuted),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DiscoveryText.rowTitle.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: DiscoveryText.smallPrint.copyWith(height: 17 / 11.5),
                ),
                if (link != null) ...[
                  const SizedBox(height: 5),
                  PressableScale(
                    onTap: onLinkTap,
                    pressedScale: 0.94,
                    child: Text(
                      link!,
                      style: DiscoveryText.link.copyWith(
                        fontSize: 12.5,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColor.discoveryAccent,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 10),
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: AppColor.discoveryTextTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The hairline between rows inside a cart card.
class CartDivider extends StatelessWidget {
  const CartDivider({super.key, this.top = 14, this.bottom = 14});

  final double top;
  final double bottom;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: top, bottom: bottom),
    child: const Divider(
      height: 1,
      thickness: 1,
      color: AppColor.discoveryBorder,
    ),
  );
}
