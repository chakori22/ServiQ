part of 'conversation_bloc.dart';

// Sentinel so copyWith can tell "not passed" apart from an explicit null,
// which is what lets the booking be cleared once its receipt has been shown.
const _unset = Object();

class ConversationState extends Equatable {
  final String providerName;

  /// Null until the thread has been read.
  final ChatThread? thread;

  final bool isLoading;

  /// A visit just booked by accepting an offer, waiting for the screen to
  /// show its receipt. Cleared with [BookingSeen] so it is pushed once.
  final Visit? booked;

  const ConversationState({
    required this.providerName,
    required this.thread,
    required this.isLoading,
    required this.booked,
  });

  const ConversationState.initial({
    this.providerName = '',
    this.thread,
    this.isLoading = true,
    this.booked,
  });

  ConversationState copyWith({
    String? providerName,
    ChatThread? thread,
    bool? isLoading,
    Object? booked = _unset,
  }) {
    return ConversationState(
      providerName: providerName ?? this.providerName,
      thread: thread ?? this.thread,
      isLoading: isLoading ?? this.isLoading,
      booked: booked == _unset ? this.booked : booked as Visit?,
    );
  }

  List<ChatMessage> get messages => thread?.messages ?? const [];

  @override
  List<Object?> get props => [providerName, thread, isLoading, booked];
}
