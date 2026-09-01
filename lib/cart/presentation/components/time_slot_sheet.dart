import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_markerplace/cart/bloc/cart_bloc.dart';
import 'package:local_markerplace/cart/model/cart_slot.dart';
import 'package:local_markerplace/components/primary_button.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:shimmer/shimmer.dart';

/// Opens the start-time picker over the cart.
///
/// The sheet is handed the live [CartBloc] rather than building its own: it
/// reads the days that bloc loaded and writes the confirmed slot straight
/// back to the cart behind it.
Future<void> showTimeSlotSheet(BuildContext context, CartBloc cartBloc) {
  // Reloaded each time the sheet opens so a cart left sitting does not offer
  // slots that have since passed.
  cartBloc.add(const OnFetchSlots());

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColor.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) =>
        BlocProvider.value(value: cartBloc, child: const _TimeSlotSheet()),
  );
}

class _TimeSlotSheet extends StatefulWidget {
  const _TimeSlotSheet();

  @override
  State<_TimeSlotSheet> createState() => _TimeSlotSheetState();
}

class _TimeSlotSheetState extends State<_TimeSlotSheet> {
  /// Which date tab is open. Held here, not in the bloc: browsing days is
  /// part of using the picker, not part of the cart.
  int _dayIndex = 0;

  /// The slot the customer has tapped but not yet confirmed. Nothing reaches
  /// the cart until Confirm, so backing out changes nothing.
  CartSlot? _draftSlot;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.62,
      child: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          final days = state.slotDays;
          // A reload can leave the open tab pointing past the end of a
          // shorter list, so clamp before reading it.
          final dayIndex = days.isEmpty
              ? 0
              : _dayIndex.clamp(0, days.length - 1);

          return Column(
            children: [
              const _SheetHeader(),
              if (days.isNotEmpty)
                _DayTabs(
                  days: days,
                  selectedIndex: dayIndex,
                  onSelected: (index) {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _dayIndex = index;
                      // Slots belong to a single day, so the pending pick
                      // goes with the day it was made on.
                      _draftSlot = null;
                    });
                  },
                ),
              Expanded(
                child: state.slotsLoading
                    ? const _SlotShimmer()
                    : days.isEmpty
                    ? const _SheetMessage(
                        'No times are available right now. Please try again '
                        'later.',
                      )
                    : _SlotGrid(
                        slots: days[dayIndex].slots,
                        selectedSlot: _draftSlot,
                        onSelected: (slot) {
                          HapticFeedback.selectionClick();
                          setState(() => _draftSlot = slot);
                        },
                      ),
              ),
              const _ArrivalNote(),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: PrimaryButton(
                    label: 'Confirm',
                    enabled: _draftSlot != null,
                    onPressed: () {
                      final slot = _draftSlot;
                      if (slot == null) return;
                      context.read<CartBloc>().add(OnSelectSlot(slot));
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 16),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Select start time of service',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColor.neutralGreyColor800,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColor.neutralGreyColor50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 18,
                color: AppColor.neutralGreyColor500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The date strip. A day nothing is left on is shown but not selectable, so
/// the customer can see how far out availability starts.
class _DayTabs extends StatelessWidget {
  const _DayTabs({
    required this.days,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<CartSlotDay> days;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColor.neutralGreyColor70),
          bottom: BorderSide(color: AppColor.neutralGreyColor70),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            for (int index = 0; index < days.length; index++)
              _DayTab(
                day: days[index],
                today: today,
                isSelected: index == selectedIndex,
                onTap: days[index].isFullyBooked
                    ? null
                    : () => onSelected(index),
              ),
          ],
        ),
      ),
    );
  }
}

class _DayTab extends StatelessWidget {
  const _DayTab({
    required this.day,
    required this.today,
    required this.isSelected,
    required this.onTap,
  });

  final CartSlotDay day;
  final DateTime today;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color foreground = onTap == null
        ? AppColor.neutralGreyColor200
        : isSelected
        ? AppColor.indicativeBlueColor500
        : AppColor.neutralGreyColor500;

    return InkWell(
      onTap: onTap,
      child: Container(
        width: 92,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 3,
              color: isSelected
                  ? AppColor.indicativeBlueColor500
                  : Colors.transparent,
            ),
          ),
        ),
        child: Column(
          children: [
            Text(
              day.dayLabel,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: foreground,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              day.subLabel(today),
              style: TextStyle(fontSize: 13, color: foreground),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlotGrid extends StatelessWidget {
  const _SlotGrid({
    required this.slots,
    required this.selectedSlot,
    required this.onSelected,
  });

  final List<CartSlot> slots;
  final CartSlot? selectedSlot;
  final ValueChanged<CartSlot> onSelected;

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return const _SheetMessage('No times left on this day. Try another one.');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: slots
            .map(
              (slot) => _SlotChip(
                slot: slot,
                isSelected: slot.id == selectedSlot?.id,
                onTap: () => onSelected(slot),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.slot,
    required this.isSelected,
    required this.onTap,
  });

  final CartSlot slot;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool enabled = slot.isAvailable;

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 104,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: !enabled
              ? AppColor.neutralGreyColor50
              : isSelected
              ? AppColor.indicativeBlueColor50
              : AppColor.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: !enabled
                ? AppColor.neutralGreyColor70
                : isSelected
                ? AppColor.indicativeBlueColor500
                : AppColor.neutralGreyColor100,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 180),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: !enabled
                ? AppColor.neutralGreyColor200
                : isSelected
                ? AppColor.indicativeBlueColor700
                : AppColor.neutralGreyColor700,
          ),
          child: Text(slot.label, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}

class _ArrivalNote extends StatelessWidget {
  const _ArrivalNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColor.indicativeBlueColor50,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: const Text(
        'Professional will arrive within 30 mins of the selected slot.',
        style: TextStyle(fontSize: 13, color: AppColor.neutralGreyColor700),
      ),
    );
  }
}

class _SheetMessage extends StatelessWidget {
  const _SheetMessage(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: AppColor.neutralGreyColor400,
          ),
        ),
      ),
    );
  }
}

/// Placeholder chips shown while the days are being fetched.
class _SlotShimmer extends StatelessWidget {
  const _SlotShimmer();

  static const int chipCount = 9;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColor.indicativeBlueColor100,
      highlightColor: AppColor.indicativeBlueColor50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(
            chipCount,
            (_) => Container(
              width: 104,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
