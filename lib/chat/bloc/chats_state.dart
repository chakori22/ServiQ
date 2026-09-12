part of 'chats_bloc.dart';

class ChatsState extends Equatable {
  /// Every conversation, which is what decides between the empty state and
  /// the list — a search that matches nothing is not the same as having no
  /// chats at all.
  final List<ChatThread> threads;

  /// The threads matching [query].
  final List<ChatThread> results;

  final String query;
  final bool isLoading;

  const ChatsState({
    required this.threads,
    required this.results,
    required this.query,
    required this.isLoading,
  });

  const ChatsState.initial({
    this.threads = const [],
    this.results = const [],
    this.query = '',
    this.isLoading = true,
  });

  ChatsState copyWith({
    List<ChatThread>? threads,
    List<ChatThread>? results,
    String? query,
    bool? isLoading,
  }) {
    return ChatsState(
      threads: threads ?? this.threads,
      results: results ?? this.results,
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool get hasThreads => threads.isNotEmpty;

  /// Chats exist but none match what was typed.
  bool get hasNoMatches => hasThreads && results.isEmpty;

  @override
  List<Object?> get props => [threads, results, query, isLoading];
}
