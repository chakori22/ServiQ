part of 'chats_bloc.dart';

sealed class ChatsEvent extends Equatable {
  const ChatsEvent();
}

/// Draw the list — on opening it, and again after a thread was read.
final class ChatsRequested extends ChatsEvent {
  const ChatsRequested();

  @override
  List<Object> get props => [];
}

final class ChatsSearched extends ChatsEvent {
  final String query;

  const ChatsSearched(this.query);

  @override
  List<Object> get props => [query];
}
