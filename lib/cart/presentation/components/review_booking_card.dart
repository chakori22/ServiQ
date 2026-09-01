import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:local_markerplace/cart/model/cart_bill.dart';
import 'package:local_markerplace/cart/model/cart_item.dart';
import 'package:local_markerplace/cart/presentation/components/cart_card.dart';
import 'package:local_markerplace/core/app_color.dart';

/// "Review booking": every service in the cart with what it costs, and the
/// ways to change that list.
///
/// A line can go either by swiping it away or by tapping its remove button —
/// the swipe is the quick path, the button the discoverable one — and the
/// card resizes into its new shape rather than snapping.
class ReviewBookingCard extends StatelessWidget {
  const ReviewBookingCard({
    super.key,
    required this.items,
    required this.showSlotCaveat,
    required this.onRemoveItem,
    required this.onAddMoreServices,
  });

  final List<CartItem> items;

  /// The slot caveat only applies to a booking that will be scheduled; an
  /// instant visit has no slot to vary.
  final bool showSlotCaveat;

  /// Called with the line the customer removed.
  final ValueChanged<CartItem> onRemoveItem;

  final VoidCallback onAddMoreServices;

  @override
  Widget build(BuildContext context) {
    return CartCard(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int index = 0; index < items.length; index++)
              _DismissibleItemRow(
                key: ValueKey(items[index].id),
                item: items[index],
                isFirst: index == 0,
                onRemove: () => onRemoveItem(items[index]),
              ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: showSlotCaveat
                  ? const Padding(
                      key: ValueKey('caveat'),
                      padding: EdgeInsets.only(top: 16),
                      child: CartInfoStrip(
                        message:
                            'Slots may vary based on partner availability '
                            'and the selected service.',
                      ),
                    )
                  : const SizedBox(key: ValueKey('no-caveat'), width: 0),
            ),
            const SizedBox(height: 8),
            const Divider(height: 24, color: AppColor.neutralGreyColor70),
            Center(
              child: InkWell(
                onTap: onAddMoreServices,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: RichText(
                    text: const TextSpan(
                      text: 'Missed something? ',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColor.neutralGreyColor500,
                      ),
                      children: [
                        TextSpan(
                          text: 'Add more services.',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColor.indicativeBlueColor500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A line that can be swiped away, with the delete affordance revealed under
/// it as the row slides.
class _DismissibleItemRow extends StatelessWidget {
  const _DismissibleItemRow({
    super.key,
    required this.item,
    required this.isFirst,
    required this.onRemove,
  });

  final CartItem item;
  final bool isFirst;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('dismiss-${item.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColor.indicativeBlueColor50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: AppColor.indicativeBlueColor500,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: isFirst ? 0 : 16),
        child: _CartItemRow(item: item, onRemove: onRemove),
      ),
    );
  }
}

class _CartItemRow extends StatelessWidget {
  const _CartItemRow({required this.item, required this.onRemove});

  final CartItem item;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _ServiceThumbnail(imageUrl: item.imageUrl),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            item.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.25,
              color: AppColor.neutralGreyColor800,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (item.isDiscounted)
              Text(
                formatRupees(item.originalPrice),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColor.neutralGreyColor400,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            Text(
              formatRupees(item.price),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColor.neutralGreyColor800,
              ),
            ),
          ],
        ),
        const SizedBox(width: 4),
        IconButton(
          onPressed: onRemove,
          visualDensity: VisualDensity.compact,
          tooltip: 'Remove ${item.title}',
          icon: const Icon(
            Icons.delete_outline_rounded,
            size: 22,
            color: AppColor.neutralGreyColor500,
          ),
        ),
      ],
    );
  }
}

class _ServiceThumbnail extends StatelessWidget {
  const _ServiceThumbnail({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColor.indicativeBlueColor50,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(8),
      child: SvgPicture.asset(imageUrl, fit: BoxFit.contain),
    );
  }
}
