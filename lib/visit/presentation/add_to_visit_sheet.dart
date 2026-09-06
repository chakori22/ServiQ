import 'package:flutter/material.dart';

import 'package:local_markerplace/components/motion/entrance.dart';
import 'package:local_markerplace/components/textfield.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/visit/model/visit.dart';
import 'package:local_markerplace/visit/model/visit_service.dart';
import 'package:local_markerplace/visit/presentation/components/visit_bits.dart';

/// 13 · 01 — adding one service to a visit.
///
/// Opens over the provider's profile rather than navigating away, because
/// the seeker is usually adding two or three in a row and should not lose
/// their place in the list.
///
/// Pops with the [VisitService] to add, or with nothing if dismissed.
Future<VisitService?> showAddToVisitSheet(
  BuildContext context, {
  required String name,
  required String detail,
  required double unitPrice,
}) {
  return showModalBottomSheet<VisitService>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColor.white,
    barrierColor: AppColor.discoveryInk.withValues(alpha: 0.45),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: _AddToVisitSheet(name: name, detail: detail, unitPrice: unitPrice),
    ),
  );
}

class _AddToVisitSheet extends StatefulWidget {
  const _AddToVisitSheet({
    required this.name,
    required this.detail,
    required this.unitPrice,
  });

  final String name;
  final String detail;
  final double unitPrice;

  @override
  State<_AddToVisitSheet> createState() => _AddToVisitSheetState();
}

class _AddToVisitSheetState extends State<_AddToVisitSheet> {
  final TextEditingController _note = TextEditingController();
  int _quantity = 1;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  double get _lineTotal => widget.unitPrice * _quantity;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(widget.name, style: DiscoveryText.meName)),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'from ${rupees(widget.unitPrice)}',
                    style: DiscoveryText.fromPrice,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              widget.detail,
              style: DiscoveryText.caption.copyWith(height: 19 / 12.5),
            ),
            const VisitRule(top: 18, bottom: 18),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'How many units?',
                    style: DiscoveryText.rowTitle.copyWith(
                      fontSize: 13.5,
                      color: AppColor.discoveryInkMuted,
                    ),
                  ),
                ),
                _Stepper(
                  value: _quantity,
                  onChanged: (value) => setState(() => _quantity = value),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Text('ANYTHING WE SHOULD KNOW?', style: DiscoveryText.tipsHeading),
            const SizedBox(height: 10),
            AppTextField(
              controller: _note,
              hintText: 'Bedroom unit rattles. Second one is in the hall.',
              keyboardType: TextInputType.text,
              maxLines: 3,
              maxLength: 160,
              fillColor: AppColor.discoveryTint,
              borderColor: AppColor.discoveryBorder,
              borderWidth: 1.4,
              cornerRadius: 14,
              verticalPadding: 12,
              textStyle: DiscoveryText.offerNote,
              hintStyle: DiscoveryText.footnote,
            ),
            const VisitRule(top: 6, bottom: 16),
            TotalRow(
              label: '${widget.name} × $_quantity',
              value: rupees(_lineTotal),
            ),
            TotalRow(
              label: 'Visit charge',
              value: rupees(Visit.visitCharge),
              footnote: 'waived once you confirm',
            ),
            const VisitRule(top: 6, bottom: 14),
            TotalRow(
              label: 'Estimate',
              value: rupees(_lineTotal),
              isTotal: true,
              footnote:
                  'Final price confirmed by the provider before work starts',
            ),
            const SizedBox(height: 18),
            VisitCta(
              label: 'Add to cart',
              onTap: () => Navigator.of(context).pop(
                VisitService(
                  name: widget.name,
                  detail: widget.detail,
                  unitPrice: widget.unitPrice,
                  quantity: _quantity,
                  note: _note.text.trim(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Minus, the count, plus — the design's 116×40 control.
class _Stepper extends StatelessWidget {
  const _Stepper({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 116,
      height: 40,
      decoration: BoxDecoration(
        color: AppColor.discoveryTint,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.discoveryBorder, width: 1.4),
      ),
      child: Row(
        children: [
          _StepperButton(
            icon: Icons.remove_rounded,
            // One is the floor; removing the service altogether is the
            // visit's job, not the stepper's.
            onTap: value > 1 ? () => onChanged(value - 1) : null,
          ),
          Expanded(
            child: Center(
              child: Text(
                '$value',
                style: DiscoveryText.groupHeading.copyWith(letterSpacing: 0),
              ),
            ),
          ),
          _StepperButton(
            icon: Icons.add_rounded,
            onTap: value < 20 ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      pressedScale: 0.85,
      child: SizedBox(
        width: 38,
        height: 38,
        child: Icon(
          icon,
          size: 18,
          color: onTap == null
              ? AppColor.discoveryTextDisabled
              : AppColor.discoveryInk,
        ),
      ),
    );
  }
}
