import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:local_markerplace/components/motion/entrance.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/notifications/bloc/notification_bloc.dart';
import 'package:local_markerplace/notifications/model/app_notification.dart';
import 'package:local_markerplace/notifications/repository/notification_repository.dart';

/// 09 · 06 — the notifications drawer.
///
/// A sheet over whatever the bell was tapped from, rather than a screen of
/// its own: notifications are a glance, and the design draws the board still
/// visible behind the scrim.
Future<void> showNotificationsSheet(
  BuildContext context, {
  NotificationRepository? repository,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColor.white,
    // The design's scrim, which is darker than Flutter's default.
    barrierColor: AppColor.discoveryInk.withValues(alpha: 0.45),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => NotificationsSheet(
      repository: repository ?? NotificationRepository.shared,
    ),
  );
}

class NotificationsSheet extends StatelessWidget {
  const NotificationsSheet({super.key, this.repository});

  /// Defaults to the shared store, which is what the bells count from.
  final NotificationRepository? repository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationBloc(
        notificationRepository: repository ?? NotificationRepository.shared,
      )..add(const NotificationsRequested()),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<NotificationBloc>().state;
    final now = DateTime.now();
    final today = state.todayAt(now);
    final earlier = state.earlierAt(now);

    // The design gives the sheet 694 of 844 — most of the screen, but with
    // the board still showing above it.
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.82,
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: AppColor.discoveryBorder,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 17),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text('Notifications', style: DiscoveryText.sheetTitle),
                ),
                // Nothing to mark once everything has been read, so the
                // action steps back rather than sitting there doing nothing.
                if (state.hasUnread)
                  PressableScale(
                    onTap: () => context.read<NotificationBloc>().add(
                      const AllNotificationsRead(),
                    ),
                    pressedScale: 0.92,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 6,
                      ),
                      child: Text('Mark all read', style: DiscoveryText.link),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                if (today.isNotEmpty) ...[
                  const _SectionHeading('TODAY'),
                  for (final (index, notification) in today.indexed)
                    NotificationRow(notification: notification, index: index),
                ],
                if (earlier.isNotEmpty) ...[
                  const _SectionHeading('EARLIER'),
                  for (final (index, notification) in earlier.indexed)
                    NotificationRow(
                      notification: notification,
                      index: today.length + index,
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "TODAY" / "EARLIER".
class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      child: Text(label, style: DiscoveryText.fieldLabel),
    );
  }
}

/// One notification: its mark, what happened, what it was about, and how long
/// ago. An unread one sits on a pale tint and carries a dot.
class NotificationRow extends StatelessWidget {
  const NotificationRow({
    super.key,
    required this.notification,
    this.index = 0,
  });

  final AppNotification notification;

  /// Position in the drawer, which staggers the row's entrance.
  final int index;

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      index: index,
      child: ColoredBox(
        color: notification.isUnread
            ? AppColor.providerNoteFill
            : AppColor.white,
        child: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 18),
                child: _KindMark(kind: notification.kind),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(top: 17, bottom: 16),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColor.discoveryBorder),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notification.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: DiscoveryText.reviewAuthor.copyWith(
                                height: 18 / 13.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notification.body,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: DiscoveryText.meta.copyWith(
                                height: 15 / 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              notification.age,
                              style: DiscoveryText.reviewAge,
                            ),
                            const SizedBox(height: 9),
                            // The unread dot keeps its space either way, so
                            // marking everything read does not reflow the
                            // whole list.
                            SizedBox(
                              width: 8,
                              height: 8,
                              child: notification.isUnread
                                  ? const DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: AppColor.discoveryAccent,
                                        shape: BoxShape.circle,
                                      ),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The 38pt disc that says what kind of notification this is.
///
/// The design draws four differently tinted discs with a small glyph in each;
/// the tint is what tells them apart at a glance, so it carries the meaning
/// and the glyph only confirms it.
class _KindMark extends StatelessWidget {
  const _KindMark({required this.kind});

  final NotificationKind kind;

  @override
  Widget build(BuildContext context) {
    final (background, foreground, icon) = switch (kind) {
      NotificationKind.offer => (
        AppColor.artBlueLight,
        AppColor.discoveryAccent,
        Icons.info_outline_rounded,
      ),
      NotificationKind.accepted => (
        AppColor.discoveryLiveTint,
        AppColor.discoveryLiveText,
        Icons.check_rounded,
      ),
      NotificationKind.message => (
        AppColor.artVioletLight,
        AppColor.artVioletDeep,
        Icons.chat_bubble_outline_rounded,
      ),
      NotificationKind.area => (
        AppColor.artAmberLight,
        AppColor.artAmberDeep,
        Icons.info_outline_rounded,
      ),
    };

    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Icon(icon, size: 19, color: foreground),
    );
  }
}
