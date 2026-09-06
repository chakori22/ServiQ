import 'package:equatable/equatable.dart';

/// What a notification is about, which is all the row needs to pick its mark.
enum NotificationKind {
  /// A provider has offered on one of the seeker's requirements.
  offer,

  /// Something the seeker was waiting on came good — an offer accepted, a
  /// document approved.
  accepted,

  /// A direct message.
  message,

  /// News about the seeker's area rather than about them.
  area,
}

/// One line in the notifications drawer.
class AppNotification extends Equatable {
  const AppNotification({
    required this.kind,
    required this.title,
    required this.body,
    required this.at,
    this.isUnread = false,
  });

  final NotificationKind kind;

  /// "Shahnaz RO & Chimney offered ₹899" — wraps to two lines where it has to.
  final String title;

  /// The line under it, naming what the notification is about.
  final String body;

  /// When it arrived. The drawer groups and stamps from this rather than
  /// storing a pre-formatted string, so "20 min" stays true while the sheet
  /// is open.
  final DateTime at;

  final bool isUnread;

  /// Whether this belongs under TODAY rather than EARLIER.
  bool isToday(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    return !at.isBefore(today);
  }

  /// "20 min" / "2 h" / "4 d", as the design stamps each row.
  String get age {
    final difference = DateTime.now().difference(at);
    if (difference.inMinutes < 1) return 'now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min';
    if (difference.inHours < 24) return '${difference.inHours} h';
    return '${difference.inDays} d';
  }

  AppNotification copyWith({bool? isUnread}) => AppNotification(
    kind: kind,
    title: title,
    body: body,
    at: at,
    isUnread: isUnread ?? this.isUnread,
  );

  @override
  List<Object?> get props => [kind, title, body, at, isUnread];
}
