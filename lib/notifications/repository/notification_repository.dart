import 'dart:async';

import 'package:local_markerplace/notifications/model/app_notification.dart';

/// What the notifications drawer shows.
///
/// There is no notifications endpoint yet, so the list below is the seed data
/// drawn in the design, timed relative to now so the TODAY / EARLIER split
/// and the age stamps read correctly whenever the sheet is opened. Swapping
/// this class for an API-backed one is the only change the drawer needs.
class NotificationRepository {
  NotificationRepository._();

  /// The one every bell and the drawer read, so marking things read in the
  /// drawer is reflected by the badge that opened it. It lives only as long
  /// as the app does — there is nowhere to persist it to yet.
  static final NotificationRepository shared = NotificationRepository._();

  /// Announced when the drawer is read, so the bells that badge it are told.
  Stream<void> get changes => _changes.stream;

  final StreamController<void> _changes = StreamController<void>.broadcast();

  /// Built on first read so the ages are relative to when the app was
  /// opened, then kept so "mark all read" sticks.
  List<AppNotification>? _items;

  List<AppNotification> notifications() => _items ??= _seed();

  /// How many the bell should badge.
  int get unreadCount =>
      notifications().where((notification) => notification.isUnread).length;

  void markAllRead() {
    _items = [
      for (final notification in notifications())
        notification.copyWith(isUnread: false),
    ];
    if (!_changes.isClosed) _changes.add(null);
  }

  List<AppNotification> _seed() {
    final now = DateTime.now();

    return [
      AppNotification(
        kind: NotificationKind.offer,
        title: 'Shahnaz RO & Chimney offered ₹899',
        body: 'on "AC not cooling, makes noise"',
        at: now.subtract(const Duration(minutes: 20)),
        isUnread: true,
      ),
      AppNotification(
        kind: NotificationKind.accepted,
        title: 'Your offer was accepted',
        body: 'Wardrobe repair · Sharma Carpentry',
        at: now.subtract(const Duration(hours: 2)),
        isUnread: true,
      ),
      AppNotification(
        kind: NotificationKind.area,
        title: 'New requirement near you',
        body: 'Chimney deep clean · Ajnara Gen X',
        at: now.subtract(const Duration(hours: 5)),
        isUnread: true,
      ),
      AppNotification(
        kind: NotificationKind.accepted,
        title: 'Aadhaar approved',
        body: 'You now show the Provider check',
        at: now.subtract(const Duration(days: 2)),
      ),
      AppNotification(
        kind: NotificationKind.message,
        title: 'Message from CoolAir AC Service',
        body: 'Can I come at 5 instead?',
        at: now.subtract(const Duration(days: 3)),
      ),
      AppNotification(
        kind: NotificationKind.area,
        title: '3 new providers in Ajnara Gen X',
        body: 'Electrician, Plumber, Carpenter',
        at: now.subtract(const Duration(days: 4)),
      ),
    ];
  }
}
