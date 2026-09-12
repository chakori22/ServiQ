import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:local_markerplace/notifications/model/app_notification.dart';
import 'package:local_markerplace/notifications/repository/notification_repository.dart';

part 'notification_event.dart';
part 'notification_state.dart';

/// The drawer's notifications, and the one thing that can be done to them.
///
/// The repository is in-memory today, so this bloc does little more than read
/// and write it — but the drawer no longer reaches for the store itself, so
/// when notifications become an endpoint it is this class that learns to
/// wait, not the sheet.
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository notificationRepository;

  NotificationBloc({required this.notificationRepository})
    : super(const NotificationState.initial()) {
    on<NotificationsRequested>(_onNotificationsRequested);
    on<AllNotificationsRead>(_onAllNotificationsRead);
  }

  void _onNotificationsRequested(
    NotificationsRequested event,
    Emitter<NotificationState> emit,
  ) {
    emit(
      state.copyWith(
        notifications: notificationRepository.notifications(),
        isLoading: false,
      ),
    );
  }

  void _onAllNotificationsRead(
    AllNotificationsRead event,
    Emitter<NotificationState> emit,
  ) {
    notificationRepository.markAllRead();
    emit(state.copyWith(notifications: notificationRepository.notifications()));
  }
}
