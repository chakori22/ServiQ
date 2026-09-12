part of 'notification_bloc.dart';

sealed class NotificationEvent extends Equatable {
  const NotificationEvent();
}

/// Draw the drawer.
final class NotificationsRequested extends NotificationEvent {
  const NotificationsRequested();

  @override
  List<Object> get props => [];
}

/// "Mark all read" — the drawer's only action.
final class AllNotificationsRead extends NotificationEvent {
  const AllNotificationsRead();

  @override
  List<Object> get props => [];
}
