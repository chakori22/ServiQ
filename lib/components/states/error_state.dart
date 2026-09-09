import 'package:flutter/material.dart';

import 'package:local_markerplace/components/states/state_actions.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';

/// 07 · 05 / 06 — a screen that could not load.
///
/// The design separates the two causes because the answer differs: a server
/// fault is not the seeker's doing and says so, while being offline is
/// something they can act on. Both offer a retry and a way out, and the
/// server one carries a reference so a support conversation has something to
/// quote.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.title,
    required this.body,
    required this.onRetry,
    this.retryLabel = 'Try again',
    this.secondaryLabel,
    this.onSecondary,
    this.reference,
    this.occurredAt,
    this.isOffline = false,
  });

  final String title;
  final String body;

  final VoidCallback onRetry;
  final String retryLabel;

  /// "Go to Home" — somewhere to be when retrying is not working.
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  /// "7f3c91". Shown as "If it keeps happening, quote ref …".
  final String? reference;

  /// When it happened, under the reference.
  final DateTime? occurredAt;

  /// Swaps the mark for the offline glyph. The copy is the caller's either
  /// way, since only they know what failed to load.
  final bool isOffline;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: _Mark(isOffline: isOffline)),
          const SizedBox(height: 26),
          Text(
            title,
            textAlign: TextAlign.center,
            style: DiscoveryText.emptyTitle,
          ),
          const SizedBox(height: 10),
          Text(
            body,
            textAlign: TextAlign.center,
            style: DiscoveryText.caption.copyWith(height: 19 / 13),
          ),
          const SizedBox(height: 32),
          StatePrimaryButton(label: retryLabel, onTap: onRetry),
          if (secondaryLabel != null) ...[
            const SizedBox(height: 14),
            StateSecondaryButton(label: secondaryLabel!, onTap: onSecondary),
          ],
          if (reference != null) ...[
            const SizedBox(height: 22),
            Text(
              'If it keeps happening, quote ref $reference',
              textAlign: TextAlign.center,
              style: DiscoveryText.fine.copyWith(
                color: AppColor.discoveryTextDisabled,
              ),
            ),
          ],
          if (occurredAt != null) ...[
            const SizedBox(height: 6),
            Text(
              stampOf(occurredAt!),
              textAlign: TextAlign.center,
              style: DiscoveryText.fine.copyWith(
                color: AppColor.uploadDashedBorder,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// "9 Sep, 14:02".
  static String stampOf(DateTime at) {
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
    final minute = at.minute.toString().padLeft(2, '0');
    return '${at.day} ${months[at.month - 1]}, ${at.hour}:$minute';
  }
}

/// The tinted disc with an exclamation, or a struck-through signal when the
/// cause is the connection rather than the server.
class _Mark extends StatelessWidget {
  const _Mark({required this.isOffline});

  final bool isOffline;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColor.stockLowTint,
      ),
      child: Icon(
        isOffline ? Icons.wifi_off_rounded : Icons.priority_high_rounded,
        size: isOffline ? 40 : 44,
        color: AppColor.authError,
      ),
    );
  }
}
