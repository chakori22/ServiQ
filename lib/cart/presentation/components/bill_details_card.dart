import 'package:flutter/material.dart';
import 'package:local_markerplace/cart/model/cart_bill.dart';
import 'package:local_markerplace/cart/presentation/components/cart_card.dart';
import 'package:local_markerplace/core/app_color.dart';

/// "Bill details": the amount due, what the offers saved, and — when the
/// customer expands it — how that total is made up.
class BillDetailsCard extends StatelessWidget {
  const BillDetailsCard({
    super.key,
    required this.bill,
    required this.isExpanded,
    required this.onToggle,
  });

  final CartBill bill;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return CartCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'To pay ${formatRupees(bill.toPay)}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColor.neutralGreyColor800,
                        ),
                      ),
                      if (bill.hasSavings) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${formatRupees(bill.savings)} saved on the total!',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColor.indicativeBlueColor500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: AppColor.neutralGreyColor50,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(4),
                  // The chevron turns instead of swapping, so the card reads
                  // as one thing opening rather than two icons alternating.
                  child: AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: AppColor.neutralGreyColor600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // The breakdown grows and shrinks in place rather than appearing
          // whole, so the card does not jump under the customer's finger.
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: isExpanded
                ? Column(
                    children: [
                      const Divider(
                        height: 28,
                        color: AppColor.neutralGreyColor70,
                      ),
                      _BillLine(label: 'Item total', amount: bill.itemTotal),
                      const _DashedDivider(),
                      _BillLine(
                        label: 'GST & Service Fees',
                        amount: bill.taxesAndFees,
                        // The rate is a platform-wide rule rather than a
                        // per-order charge, so it gets an explainer instead
                        // of a breakdown.
                        showInfoIcon: true,
                      ),
                      const _DashedDivider(),
                      _BillLine(
                        label: 'To pay',
                        amount: bill.toPay,
                        isTotal: true,
                      ),
                    ],
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _BillLine extends StatelessWidget {
  const _BillLine({
    required this.label,
    required this.amount,
    this.isTotal = false,
    this.showInfoIcon = false,
  });

  final String label;
  final double amount;
  final bool isTotal;
  final bool showInfoIcon;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: isTotal ? 16 : 14,
      fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
      color: isTotal
          ? AppColor.neutralGreyColor800
          : AppColor.neutralGreyColor600,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(label, style: style),
            if (showInfoIcon) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.info_outline_rounded,
                size: 15,
                color: AppColor.neutralGreyColor400,
              ),
            ],
          ],
        ),
        Text(formatRupees(amount), style: style),
      ],
    );
  }
}

/// The dotted rule the bill uses between lines, so a breakdown reads as a
/// receipt rather than as more cards.
class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const double dashWidth = 4;
          const double gapWidth = 4;
          final int dashCount =
              (constraints.maxWidth / (dashWidth + gapWidth)).floor();
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              dashCount,
              (_) => const SizedBox(
                width: dashWidth,
                height: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: AppColor.neutralGreyColor80),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
