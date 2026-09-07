import 'package:equatable/equatable.dart';

/// How an offer made inside a chat has been answered.
enum ChatOfferStatus { pending, accepted, declined }

/// A price a provider named in the conversation.
///
/// It is a message rather than a screen of its own: the haggling happens in
/// the thread, so the offer has to sit in it where the reply that argued the
/// price down is still visible above.
class ChatOffer extends Equatable {
  const ChatOffer({
    required this.price,
    required this.terms,
    this.status = ChatOfferStatus.pending,
  });

  /// Rupees.
  final double price;

  /// "Tomorrow morning · 30-day warranty".
  final String terms;

  final ChatOfferStatus status;

  /// When the provider said they would come, taken from the first half of
  /// [terms] — the offer names it in prose rather than as a slot.
  String get timing => terms.split(' · ').first;

  ChatOffer copyWith({ChatOfferStatus? status}) =>
      ChatOffer(price: price, terms: terms, status: status ?? this.status);

  @override
  List<Object?> get props => [price, terms, status];
}

/// One message in a thread.
class ChatMessage extends Equatable {
  const ChatMessage({
    required this.text,
    required this.sentAt,
    required this.isMine,
    this.offer,
  });

  final String text;
  final DateTime sentAt;

  /// True for the seeker's own messages, which sit right and carry the
  /// accent.
  final bool isMine;

  /// Set on the message that carries an offer. The card is drawn under the
  /// text, so a provider can explain a price and name it in one turn.
  final ChatOffer? offer;

  /// "2:04 pm".
  String get timeLabel {
    final hour = sentAt.hour % 12 == 0 ? 12 : sentAt.hour % 12;
    final minute = sentAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${sentAt.hour < 12 ? 'am' : 'pm'}';
  }

  ChatMessage copyWith({ChatOffer? offer}) => ChatMessage(
    text: text,
    sentAt: sentAt,
    isMine: isMine,
    offer: offer ?? this.offer,
  );

  @override
  List<Object?> get props => [text, sentAt, isMine, offer];
}
