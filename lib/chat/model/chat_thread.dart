import 'package:equatable/equatable.dart';

import 'package:local_markerplace/chat/model/chat_message.dart';

/// A conversation with one provider.
///
/// Threads are not started by the seeker: one opens when an offer is
/// accepted or a provider is connected with, which is why the list carries a
/// note saying so and why there is no "new message" button.
class ChatThread extends Equatable {
  const ChatThread({
    required this.providerName,
    required this.messages,
    this.isVerified = true,
    this.replyLine = 'Usually replies in 10 min',
    this.postTitle,
    this.unreadCount = 0,
  });

  final String providerName;

  /// Oldest first, which is the order the conversation is read in.
  final List<ChatMessage> messages;

  final bool isVerified;

  /// "Usually replies in 10 min" — shown under the name in the header when
  /// the thread is not about a particular post.
  final String replyLine;

  /// The requirement the thread came out of, if it did. The header shows it
  /// instead of the reply line, because which job this is about matters more
  /// than how fast they answer.
  final String? postTitle;

  final int unreadCount;

  ChatMessage? get lastMessage => messages.isEmpty ? null : messages.last;

  /// "You: Great, see you tomorrow", or the provider's own words.
  ///
  /// A thread with an offer still waiting is summarised by the offer instead
  /// of by whatever was said after it: the offer is the thing that needs an
  /// answer, and a counter-question sent underneath it would otherwise bury
  /// it in the list.
  String get previewLine {
    final last = lastMessage;
    if (last == null) return 'No messages yet';
    if (hasPendingOffer) {
      final about = postTitle;
      return about == null
          ? 'Sent an offer'
          : 'Sent an offer on "${about.split(',').first}"';
    }
    return last.isMine ? 'You: ${last.text}' : last.text;
  }

  /// Whether a price is sitting in the thread unanswered.
  bool get hasPendingOffer => messages.any(
    (message) => message.offer?.status == ChatOfferStatus.pending,
  );

  /// Up to two letters for the avatar.
  String get initials {
    final words = providerName.trim().split(RegExp(r'\s+'));
    if (words.isEmpty || words.first.isEmpty) return '?';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return (words[0][0] + words[1][0]).toUpperCase();
  }

  /// "2 min" / "1 h" / "yesterday" / "3 d" — how the list ages a thread.
  String get ageLabel {
    final last = lastMessage;
    if (last == null) return '';
    final elapsed = DateTime.now().difference(last.sentAt);
    if (elapsed.inMinutes < 1) return 'now';
    if (elapsed.inMinutes < 60) return '${elapsed.inMinutes} min';
    if (elapsed.inHours < 24) return '${elapsed.inHours} h';
    if (elapsed.inDays == 1) return 'yesterday';
    return '${elapsed.inDays} d';
  }

  ChatThread copyWith({List<ChatMessage>? messages, int? unreadCount}) =>
      ChatThread(
        providerName: providerName,
        messages: messages ?? this.messages,
        isVerified: isVerified,
        replyLine: replyLine,
        postTitle: postTitle,
        unreadCount: unreadCount ?? this.unreadCount,
      );

  @override
  List<Object?> get props => [providerName, messages, unreadCount];
}
