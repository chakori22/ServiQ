import 'package:equatable/equatable.dart';

/// Which part of the day a slot falls in. The design groups the grid under
/// these three headings, each with its own free count.
enum SlotPeriod {
  morning('MORNING', '12 am – 12 pm'),
  afternoon('AFTERNOON', '12 pm – 6 pm'),
  evening('EVENING', '6 pm onwards');

  const SlotPeriod(this.label, this.span);

  final String label;
  final String span;

  static SlotPeriod of(int hour) {
    if (hour < 12) return SlotPeriod.morning;
    if (hour < 18) return SlotPeriod.afternoon;
    return SlotPeriod.evening;
  }
}

/// A start time a visit can be booked into.
///
/// The design asks for the moment the work starts rather than a window to
/// arrive in — the provider is told to be there within half an hour of it —
/// so slots sit on the half hour rather than spanning two of them.
class VisitSlot extends Equatable {
  const VisitSlot({
    required this.startHour,
    required this.isFree,
    required this.date,
    this.startMinute = 0,
  });

  /// 24-hour start.
  final int startHour;

  /// 0 or 30.
  final int startMinute;

  /// False when the provider is already booked — the design still shows it,
  /// marked "full", so the seeker can see how busy the day is.
  final bool isFree;

  final DateTime date;

  SlotPeriod get period => SlotPeriod.of(startHour);

  int get _hour12 => startHour % 12 == 0 ? 12 : startHour % 12;

  String get _meridiem => startHour < 12 ? 'AM' : 'PM';

  /// "7:00 AM" — the chip on the picker.
  String get timeLabel => '$_hour12:${_pad(startMinute)} $_meridiem';

  /// "7:00 am", as the cart and the confirmation read it mid-sentence.
  String get spokenLabel =>
      '$_hour12:${_pad(startMinute)} '
      '${_meridiem.toLowerCase()}';

  /// "07:00AM", the compact form the booking-details row uses.
  String get compactLabel => '${_pad(_hour12)}:${_pad(startMinute)}$_meridiem';

  static String _pad(int value) => value.toString().padLeft(2, '0');

  @override
  List<Object?> get props => [startHour, startMinute, isFree, date];
}

/// One pickable day, with the windows it still has.
class VisitDay extends Equatable {
  const VisitDay({required this.date, required this.slots});

  final DateTime date;
  final List<VisitSlot> slots;

  /// "Today" / "Tomorrow" / "Fri".
  String get weekdayLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final difference = DateTime(
      date.year,
      date.month,
      date.day,
    ).difference(today).inDays;
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[date.weekday - 1];
  }

  /// "Sep 7" — the way the booking-details row writes it.
  String get monthDayLabel {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  /// "Mon" / "Tue" — the weekday under a day tab, and in "Mon, Sep 7".
  String get shortWeekday {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[date.weekday - 1];
  }

  /// "3 Sep".
  String get dateLabel {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  List<VisitSlot> inPeriod(SlotPeriod period) =>
      slots.where((slot) => slot.period == period).toList();

  int freeIn(SlotPeriod period) =>
      inPeriod(period).where((slot) => slot.isFree).length;

  @override
  List<Object?> get props => [date, slots];
}
