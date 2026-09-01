import 'package:flutter/material.dart';
import 'package:local_markerplace/core/app_color.dart';

/// The white rounded panel every section of the cart sits in.
///
/// Kept as one widget so the sections cannot drift apart on radius, padding
/// or shadow as they are edited.
class CartCard extends StatelessWidget {
  const CartCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      // A Material, not a coloured Container: the taps inside these cards
      // paint ripples, and a ripple needs a Material surface above the page
      // background to land on.
      child: Material(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Section heading above a [CartCard], e.g. "Booking details".
class CartSectionTitle extends StatelessWidget {
  const CartSectionTitle({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColor.neutralGreyColor800,
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// The pale information strip used for slot caveats and unavailable modes.
class CartInfoStrip extends StatelessWidget {
  const CartInfoStrip({
    super.key,
    required this.message,
    this.icon = Icons.info_outline_rounded,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.neutralGreyColor50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColor.neutralGreyColor400),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                height: 1.35,
                color: AppColor.neutralGreyColor500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
