/// A bookable window returned by the backend for a chosen date.
///
/// The user picks the date; the times themselves always come from the API,
/// because only the server knows which windows are still open.
class TimeSlot {
  final String id;
  final DateTime startTime;
  final DateTime endTime;

  /// False when the window is already taken — shown, but not selectable, so
  /// the user can see the shape of the day.
  final bool isAvailable;

  const TimeSlot({
    required this.id,
    required this.startTime,
    required this.endTime,
    this.isAvailable = true,
  });

  /// Display label for the chip, e.g. "9:00 AM - 10:00 AM".
  String get label => '${formatTime(startTime)} - ${formatTime(endTime)}';

  static String formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      id: json['id'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'isAvailable': isAvailable,
    };
  }

  TimeSlot copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    bool? isAvailable,
  }) {
    return TimeSlot(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
