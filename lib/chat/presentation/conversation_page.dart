import 'package:flutter/material.dart';

import 'package:local_markerplace/chat/model/chat_message.dart';
import 'package:local_markerplace/chat/model/chat_thread.dart';
import 'package:local_markerplace/chat/presentation/components/chat_bits.dart';
import 'package:local_markerplace/chat/repository/chat_repository.dart';
import 'package:local_markerplace/components/app_back_button.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/discovery/presentation/components/provider_avatar.dart';
import 'package:local_markerplace/visit/model/visit_service.dart';
import 'package:local_markerplace/visit/presentation/visit_booked_page.dart';
import 'package:local_markerplace/visit/repository/visit_repository.dart';

/// One conversation.
///
/// Everything the two of them agreed is here, including the price: an offer
/// is a message, so accepting one is answering the person rather than
/// leaving for a form.
class ConversationPage extends StatefulWidget {
  const ConversationPage({
    super.key,
    required this.providerName,
    this.repository,
    this.visits,
  });

  final String providerName;
  final ChatRepository? repository;
  final VisitRepository? visits;

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  late final ChatRepository _chats = widget.repository ?? ChatRepository.shared;
  late final VisitRepository _visits = widget.visits ?? VisitRepository.shared;

  final TextEditingController _message = TextEditingController();
  final ScrollController _scroll = ScrollController();

  late ChatThread _thread = _chats.markRead(widget.providerName);

  @override
  void initState() {
    super.initState();
    // Opening a thread should land on the newest message, not the oldest.
    WidgetsBinding.instance.addPostFrameCallback((_) => _toBottom());
  }

  @override
  void dispose() {
    _message.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _toBottom() {
    if (!_scroll.hasClients) return;
    _scroll.jumpTo(_scroll.position.maxScrollExtent);
  }

  void _send() {
    final text = _message.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _thread = _chats.send(widget.providerName, text);
      _message.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _toBottom());
  }

  /// Taking an offer books the visit outright, the same way taking one on
  /// the board does: the provider named a price and a time, and accepting
  /// agreed to both.
  Future<void> _accept(int index, ChatOffer offer) async {
    setState(
      () => _thread = _chats.answerOffer(
        widget.providerName,
        index,
        ChatOfferStatus.accepted,
      ),
    );

    final booked = _visits.bookFromOffer(
      providerName: _thread.providerName,
      providerLine: 'agreed in chat',
      isVerifiedProvider: _thread.isVerified,
      agreedWhen: _capitalised(offer.timing),
      service: VisitService(
        name: _thread.postTitle ?? 'Agreed in chat',
        detail: offer.terms,
        unitPrice: offer.price,
      ),
    );
    if (!mounted) return;

    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => VisitBookedPage(visit: booked)));
    if (mounted) setState(() {});
  }

  void _decline(int index) {
    setState(
      () => _thread = _chats.answerOffer(
        widget.providerName,
        index,
        ChatOfferStatus.declined,
      ),
    );
  }

  static String _capitalised(String text) =>
      text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);

  @override
  Widget build(BuildContext context) {
    final messages = _thread.messages;

    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(thread: _thread),
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColor.discoveryBorder,
            ),
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                itemCount: messages.length + 1,
                itemBuilder: (context, index) {
                  // The last row is the note about what accepting does; it
                  // belongs with the conversation rather than pinned, so it
                  // scrolls away once the thread grows.
                  if (index == messages.length) {
                    return _AcceptNote(thread: _thread);
                  }

                  final message = messages[index];
                  final previous = index == 0 ? null : messages[index - 1];
                  final offer = message.offer;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_startsNewDay(previous, message))
                        ChatDayLabel(label: _dayLabel(message.sentAt)),
                      if (message.text.isNotEmpty)
                        MessageBubble(message: message),
                      if (offer != null)
                        ChatOfferCard(
                          offer: offer,
                          timeLabel: message.timeLabel,
                          onAccept: () => _accept(index, offer),
                          onDecline: () => _decline(index),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ChatComposer(
        controller: _message,
        canSend: true,
        onSend: _send,
      ),
    );
  }

  static bool _startsNewDay(ChatMessage? previous, ChatMessage message) {
    if (previous == null) return true;
    final a = previous.sentAt;
    final b = message.sentAt;
    return a.year != b.year || a.month != b.month || a.day != b.day;
  }

  static String _dayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = DateTime(
      date.year,
      date.month,
      date.day,
    ).difference(today).inDays;
    if (days == 0) return 'Today';
    if (days == -1) return 'Yesterday';
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[date.weekday - 1];
  }
}

/// Who the conversation is with, and what it is about.
class _Header extends StatelessWidget {
  const _Header({required this.thread});

  final ChatThread thread;

  @override
  Widget build(BuildContext context) {
    final about = thread.postTitle;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 20, 10),
      child: Row(
        children: [
          const AppBackButton(),
          const SizedBox(width: 6),
          ProviderAvatar(
            initials: thread.initials,
            seed: thread.providerName,
            size: 40,
            isVerified: thread.isVerified,
          ),
          const SizedBox(width: 12),
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
                const SizedBox(height: 3),
                Text(
                  about == null ? thread.replyLine : 'On "$about"',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DiscoveryText.smallPrint,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// What accepting an offer costs the seeker in privacy, said where the
/// offer is.
class _AcceptNote extends StatelessWidget {
  const _AcceptNote({required this.thread});

  final ChatThread thread;

  @override
  Widget build(BuildContext context) {
    if (!thread.hasPendingOffer) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        'Accepting shares your number with ${thread.providerName} only.',
        textAlign: TextAlign.center,
        style: DiscoveryText.fine,
      ),
    );
  }
}
