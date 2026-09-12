import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:local_markerplace/chat/model/chat_thread.dart';
import 'package:local_markerplace/chat/repository/chat_repository.dart';

part 'chats_event.dart';
part 'chats_state.dart';

/// The list of conversations, and the search over it.
///
/// The screen no longer reads the repository as it builds — it says the query
/// changed and draws whatever comes back, which is what lets the search
/// become a request to the server without the list knowing.
class ChatsBloc extends Bloc<ChatsEvent, ChatsState> {
  final ChatRepository chatRepository;

  ChatsBloc({required this.chatRepository})
    : super(const ChatsState.initial()) {
    on<ChatsRequested>(_onChatsRequested);
    on<ChatsSearched>(_onChatsSearched);
  }

  /// Also the event that refreshes the list after a conversation was opened,
  /// since reading a thread changes its badge.
  void _onChatsRequested(ChatsRequested event, Emitter<ChatsState> emit) {
    emit(
      state.copyWith(
        threads: chatRepository.threads,
        results: chatRepository.search(state.query),
        isLoading: false,
      ),
    );
  }

  void _onChatsSearched(ChatsSearched event, Emitter<ChatsState> emit) {
    emit(
      state.copyWith(
        query: event.query,
        threads: chatRepository.threads,
        results: chatRepository.search(event.query),
        isLoading: false,
      ),
    );
  }
}
