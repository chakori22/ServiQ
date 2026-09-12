part of 'notification_bloc.dart';

class NotificationState extends Equatable {
  final List<AppNotification> notifications;

  /// True until the first read comes back. Always brief while the store is
  /// in memory, and the reason the drawer has somewhere to put a skeleton
  /// when it stops being.
  final bool isLoading;

  const NotificationState({
    required this.notifications,
    required this.isLoading,
  });

  const NotificationState.initial({
    this.notifications = const [],
    this.isLoading = true,
  });

  NotificationState copyWith({
    List<AppNotification>? notifications,
    bool? isLoading,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// The two headings the design splits the drawer under.
  List<AppNotification> todayAt(DateTime now) =>
      notifications.where((n) => n.isToday(now)).toList();

  List<AppNotification> earlierAt(DateTime now) =>
      notifications.where((n) => !n.isToday(now)).toList();

  /// Nothing to mark once everything has been read, which is what takes the
  /// action out of the header.
  bool get hasUnread => notifications.any((n) => n.isUnread);

  int get unreadCount => notifications.where((n) => n.isUnread).length;

  @override
  List<Object?> get props => [notifications, isLoading];
}
