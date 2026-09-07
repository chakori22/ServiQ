import 'package:flutter/material.dart';

import 'package:local_markerplace/chat/model/chat_message.dart';
import 'package:local_markerplace/chat/model/chat_thread.dart';
import 'package:local_markerplace/components/motion/app_motion.dart';
import 'package:local_markerplace/components/motion/entrance.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/core/money.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/discovery/presentation/components/provider_avatar.dart';

/// One conversation in the list: who it is with, what was last said, how
/// long ago, and how much of it is unread.
class ChatRow extends StatelessWidget {
  const ChatRow({super.key, required this.thread, required this.onTap});

  final ChatThread thread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unread = thread.unreadCount;

    return PressableScale(
      onTap: onTap,
      pressedScale: 0.99,
      child: Container(
        color: AppColor.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProviderAvatar(
              initials: thread.initials,
              seed: thread.providerName,
              size: 48,
              isVerified: thread.isVerified,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    thread.providerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: DiscoveryText.rowTitle.copyWith(fontSize: 14.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    thread.previewLine,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: unread > 0
                        ? DiscoveryText.caption.copyWith(
                            color: AppColor.discoveryInkMuted,
                            fontWeight: FontWeight.w700,
                          )
                        : DiscoveryText.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(thread.ageLabel, style: DiscoveryText.timestamp),
                if (unread > 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(minWidth: 22),
                    height: 22,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: AppColor.discoveryAccent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$unread',
                      style: DiscoveryText.onAccent(11.5, letterSpacing: 0),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// "TODAY" — the day a run of messages was sent on.
class ChatDayLabel extends StatelessWidget {
  const ChatDayLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Center(
      child: Text(label.toUpperCase(), style: DiscoveryText.tipsHeading),
    ),
  );
}

/// One message. The seeker's own sit right and carry the accent; the
/// provider's sit left on the flow's tint.
class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.76,
        ),
        padding: const EdgeInsets.fromLTRB(14, 11, 14, 9),
        decoration: BoxDecoration(
          color: isMine ? AppColor.discoveryAccent : AppColor.discoveryTint,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            // The corner nearest the sender is squared off, which is what
            // points a bubble at whoever wrote it.
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: DiscoveryText.body.copyWith(
                height: 19 / 13.5,
                color: isMine ? AppColor.white : AppColor.discoveryInk,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              message.timeLabel,
              style: DiscoveryText.fine.copyWith(
                color: isMine
                    ? AppColor.white.withValues(alpha: 0.75)
                    : AppColor.discoveryTextTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A price named in the thread, with the two ways to answer it.
///
/// It sits on the page rather than inside a bubble: an offer is a decision,
/// not a remark, and the white card is what separates the two.
class ChatOfferCard extends StatelessWidget {
  const ChatOfferCard({
    super.key,
    required this.offer,
    required this.timeLabel,
    required this.onAccept,
    required this.onDecline,
  });

  final ChatOffer offer;
  final String timeLabel;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        child: _card(),
      ),
    );
  }

  Widget _card() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.discoveryBorder, width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('OFFER', style: DiscoveryText.tipsHeading),
          const SizedBox(height: 8),
          Text(rupees(offer.price), style: DiscoveryText.offerPrice),
          const SizedBox(height: 5),
          Text(offer.terms, style: DiscoveryText.smallPrint),
          const SizedBox(height: 12),
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColor.discoveryBorder,
          ),
          const SizedBox(height: 12),
          switch (offer.status) {
            ChatOfferStatus.pending => Row(
              children: [
                _AcceptButton(onTap: onAccept),
                const SizedBox(width: 8),
                PressableScale(
                  onTap: onDecline,
                  pressedScale: 0.92,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Text(
                      'Decline',
                      style: DiscoveryText.caption.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ChatOfferStatus.accepted => Text(
              'Accepted · booked with this provider',
              style: DiscoveryText.addChip.copyWith(
                color: AppColor.discoveryLiveText,
              ),
            ),
            ChatOfferStatus.declined => Text(
              'Declined',
              style: DiscoveryText.addChip.copyWith(
                color: AppColor.discoveryTextTertiary,
              ),
            ),
          },
          const SizedBox(height: 10),
          Text(timeLabel, style: DiscoveryText.fine),
        ],
      ),
    );
  }
}

class _AcceptButton extends StatelessWidget {
  const _AcceptButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      pressedScale: 0.94,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 26),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
            colors: [
              AppColor.discoveryGradientStart,
              AppColor.discoveryGradientEnd,
            ],
          ),
        ),
        child: Text(
          'Accept',
          style: DiscoveryText.onAccent(13.5, letterSpacing: -0.135),
        ),
      ),
    );
  }
}

/// The field and the send button along the bottom of a conversation.
class ChatComposer extends StatelessWidget {
  const ChatComposer({
    super.key,
    required this.controller,
    required this.onSend,
    required this.canSend,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool canSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: const BoxDecoration(
          color: AppColor.white,
          border: Border(top: BorderSide(color: AppColor.discoveryBorder)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                minLines: 1,
                maxLines: 4,
                style: DiscoveryText.body,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Message',
                  hintStyle: DiscoveryText.searchHint,
                  filled: true,
                  fillColor: AppColor.discoveryTint,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: const BorderSide(
                      color: AppColor.discoveryBorder,
                      width: 1.4,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: const BorderSide(
                      color: AppColor.discoveryBorder,
                      width: 1.4,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: const BorderSide(
                      color: AppColor.discoveryAccent,
                      width: 1.6,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            PressableScale(
              onTap: canSend ? onSend : null,
              pressedScale: 0.88,
              child: AnimatedContainer(
                duration: AppMotion.quick,
                curve: AppMotion.emphasized,
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: canSend ? null : AppColor.buttonDisabledFill,
                  gradient: canSend
                      ? const LinearGradient(
                          colors: [
                            AppColor.discoveryGradientStart,
                            AppColor.discoveryGradientEnd,
                          ],
                        )
                      : null,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 20,
                  color: canSend
                      ? AppColor.white
                      : AppColor.discoveryTextDisabled,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
