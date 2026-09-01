import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_markerplace/cart/model/cart_booking_mode.dart';
import 'package:local_markerplace/core/app_color.dart';

/// The Instant / Scheduled / Recurring switch at the top of the cart.
///
/// A mode that cannot currently be booked still selects — the cart explains
/// why further down — but its pill goes grey rather than brand-coloured, so
/// the tab never looks like a working choice.
class BookingModeTabs extends StatelessWidget {
  const BookingModeTabs({
    super.key,
    required this.selected,
    required this.instantAvailable,
    required this.onChanged,
  });

  final CartBookingMode selected;
  final bool instantAvailable;
  final ValueChanged<CartBookingMode> onChanged;

  bool _isBookable(CartBookingMode mode) => switch (mode) {
    CartBookingMode.instant => instantAvailable,
    CartBookingMode.schedule => true,
  };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.white,
      borderRadius: BorderRadius.circular(28),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Row(
          children: CartBookingMode.values.map((mode) {
            return Expanded(
              child: _ModeTab(
                label: mode.label,
                isSelected: mode == selected,
                isBookable: _isBookable(mode),
                onTap: () {
                  if (mode == selected) return;
                  // A tick of feedback makes the switch feel like a control
                  // rather than a repaint.
                  HapticFeedback.selectionClick();
                  onChanged(mode);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.label,
    required this.isSelected,
    required this.isBookable,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isBookable;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color background = !isSelected
        ? Colors.transparent
        : isBookable
        ? AppColor.indicativeBlueColor700
        : AppColor.neutralGreyColor70;

    final Color foreground = !isSelected
        ? AppColor.neutralGreyColor700
        : isBookable
        ? AppColor.white
        : AppColor.neutralGreyColor400;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(24),
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: foreground,
          ),
          child: Text(label, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
