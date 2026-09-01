import 'package:equatable/equatable.dart';

/// A start time the customer can book a scheduled visit for.
///
/// Slots are start times rather than windows: the professional arrives within
/// a grace period after the slot, which the picker spells out.
class CartSlot extends Equatable {
  final String id;
  final DateTime startTime;

  /// False when the slot is already taken or too close to now. Shown greyed
  /// out rather than hidden, so the shape of the day stays readable.
  final bool isAvailable;

  const CartSlot({
    required this.id,
    required this.startTime,
    this.isAvailable = true,
  });

  /// Chip label, e.g. "8:30 PM".
  String get label => formatTime(startTime);

  static String formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  /// Padded form used in the booking summary, e.g. "08:30AM".
  static String formatCompactTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:$minute$period';
  }

  @override
  List<Object?> get props => [id, startTime, isAvailable];
}

/// One day's worth of slots, as the picker's date tabs present them.
class CartSlotDay extends Equatable {
  final DateTime date;
  final List<CartSlot> slots;

  const CartSlotDay({required this.date, required this.slots});

  /// True when nothing on this day can still be booked — every slot is taken
  /// or in the past.
  bool get isFullyBooked => slots.every((slot) => !slot.isAvailable);

  /// Top line of the date tab, e.g. "1 Sep".
  String get dayLabel => '${date.day} ${_months[date.month - 1]}';

  /// Second line of the date tab: "Today", "Tom", then the weekday.
  String subLabel(DateTime today) {
    final startOfToday = DateTime(today.year, today.month, today.day);
    final startOfDate = DateTime(date.year, date.month, date.day);
    final daysAway = startOfDate.difference(startOfToday).inDays;
    if (daysAway == 0) return 'Today';
    if (daysAway == 1) return 'Tom';
    return _weekdays[date.weekday - 1];
  }

  /// Summary line for the booking details, e.g. "Wed, Sep 2".
  static String formatDate(DateTime date) {
    return '${_weekdays[date.weekday - 1]}, '
        '${_months[date.month - 1]} ${date.day}';
  }

  @override
  List<Object?> get props => [date, slots];
}

const List<String> _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];
const List<String> _weekdays = [
  'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
];
