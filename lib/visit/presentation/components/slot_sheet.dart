import 'package:flutter/material.dart';

import 'package:local_markerplace/components/motion/app_motion.dart';
import 'package:local_markerplace/components/motion/entrance.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/visit/model/visit_slot.dart';

/// Picks the moment the work starts.
///
/// It opens over the cart rather than replacing it, because choosing a time
/// is the last thing standing between the seeker and paying — sending them
/// to another screen for it loses the bill they were looking at.
///
/// Pops with the chosen [VisitSlot], or nothing if dismissed.
Future<VisitSlot?> showSlotSheet(
  BuildContext context, {
  required List<VisitDay> days,
  VisitSlot? selected,
}) {
  return showModalBottomSheet<VisitSlot>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColor.white,
    barrierColor: AppColor.discoveryInk.withValues(alpha: 0.45),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    // Capped so the cart stays visible behind it: the sheet is a decision
    // about the booking below, not a screen of its own.
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.82,
    ),
    builder: (_) => _SlotSheet(days: days, selected: selected),
  );
}

class _SlotSheet extends StatefulWidget {
  const _SlotSheet({required this.days, required this.selected});

  final List<VisitDay> days;
  final VisitSlot? selected;

  @override
  State<_SlotSheet> createState() => _SlotSheetState();
}

class _SlotSheetState extends State<_SlotSheet> {
  late VisitDay _day = _initialDay();
  late VisitSlot? _slot = widget.selected;

  /// Opens on the day of an already-chosen time, else the first day with
  /// anything free — landing on a fully-booked today looks like a fault.
  VisitDay _initialDay() {
    final chosen = widget.selected;
    if (chosen != null) {
      for (final day in widget.days) {
        if (day.date == chosen.date) return day;
      }
    }
    return widget.days.firstWhere(
      (day) => day.slots.any((slot) => slot.isFree),
      orElse: () => widget.days.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final slots = _day.slots;

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 14, 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Select start time of service',
                    style: DiscoveryText.sectionTitle,
                  ),
                ),
                PressableScale(
                  onTap: () => Navigator.of(context).pop(),
                  pressedScale: 0.85,
                  child: Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColor.discoveryTint,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 17,
                      color: AppColor.discoveryTextTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColor.discoveryBorder,
          ),
          Row(
            children: [
              for (final day in widget.days)
                Expanded(
                  child: _DayTab(
                    day: day,
                    isSelected: day.date == _day.date,
                    onTap: () => setState(() => _day = day),
                  ),
                ),
            ],
          ),
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColor.discoveryBorder,
          ),
          Flexible(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              shrinkWrap: true,
              itemCount: slots.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                mainAxisExtent: 48,
              ),
              itemBuilder: (context, index) => _SlotChip(
                slot: slots[index],
                isSelected: _isChosen(slots[index]),
                onTap: slots[index].isFree
                    ? () => setState(() => _slot = slots[index])
                    : null,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: AppColor.visitEtaTint,
            child: Text(
              'Professional will arrive within 30 mins of the selected slot.',
              style: DiscoveryText.smallPrint.copyWith(
                color: AppColor.discoveryGradientEnd,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
            child: _ConfirmButton(
              enabled: _slot != null,
              onTap: () => Navigator.of(context).pop(_slot),
            ),
          ),
        ],
      ),
    );
  }

  bool _isChosen(VisitSlot slot) {
    final chosen = _slot;
    return chosen != null &&
        chosen.date == slot.date &&
        chosen.startHour == slot.startHour &&
        chosen.startMinute == slot.startMinute;
  }
}

/// "7 Sep / Tom" — a day, underlined when it is the one showing.
class _DayTab extends StatelessWidget {
  const _DayTab({
    required this.day,
    required this.isSelected,
    required this.onTap,
  });

  final VisitDay day;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          const SizedBox(height: 14),
          Text(
            day.dateLabel,
            style: DiscoveryText.rowTitle.copyWith(
              fontSize: 14,
              color: isSelected
                  ? AppColor.discoveryAccent
                  : AppColor.discoveryTextTertiary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            _shortLabel(day),
            style: DiscoveryText.meta.copyWith(
              color: isSelected
                  ? AppColor.discoveryAccent
                  : AppColor.discoveryTextTertiary,
            ),
          ),
          const SizedBox(height: 10),
          AnimatedContainer(
            duration: AppMotion.quick,
            curve: AppMotion.emphasized,
            height: 3,
            color: isSelected ? AppColor.discoveryAccent : Colors.transparent,
          ),
        ],
      ),
    );
  }

  /// "Today" and "Tomorrow" are too wide for a third of the sheet, so the
  /// tab shortens them the way the design does.
  static String _shortLabel(VisitDay day) => switch (day.weekdayLabel) {
    'Today' => 'Today',
    'Tomorrow' => 'Tom',
    final other => other,
  };
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.slot,
    required this.isSelected,
    required this.onTap,
  });

  final VisitSlot slot;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isTaken = !slot.isFree;

    return PressableScale(
      onTap: onTap,
      pressedScale: 0.94,
      child: AnimatedContainer(
        duration: AppMotion.quick,
        curve: AppMotion.emphasized,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColor.visitEtaTint
              : isTaken
              ? AppColor.discoveryTint
              : AppColor.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColor.discoveryAccent
                : AppColor.discoveryBorder,
            width: isSelected ? 1.8 : 1.4,
          ),
        ),
        child: Text(
          slot.timeLabel,
          maxLines: 1,
          style: DiscoveryText.rowTitle.copyWith(
            fontSize: 13,
            color: isTaken
                ? AppColor.discoveryTextDisabled
                : isSelected
                ? AppColor.discoveryAccent
                : AppColor.discoveryInk,
          ),
        ),
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: enabled ? onTap : null,
      pressedScale: 0.97,
      child: AnimatedContainer(
        duration: AppMotion.quick,
        curve: AppMotion.emphasized,
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: enabled ? null : AppColor.buttonDisabledFill,
          gradient: enabled
              ? const LinearGradient(
                  colors: [
                    AppColor.discoveryGradientStart,
                    AppColor.discoveryGradientEnd,
                  ],
                )
              : null,
        ),
        child: Text(
          'Confirm',
          style: enabled
              ? DiscoveryText.onAccent(16, letterSpacing: -0.16)
              : DiscoveryText.buttonDisabled,
        ),
      ),
    );
  }
}
