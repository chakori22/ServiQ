part of 'your_post_bloc.dart';

class YourPostState extends Equatable {
  final String errorMessage;
  final List<PostDetails> yourPostDetails;
  final bool yourPostsLoading;

  const YourPostState({
    required this.errorMessage,
    required this.yourPostDetails,

    required this.yourPostsLoading,
  });

  const YourPostState.initial({
    this.errorMessage = '',
    this.yourPostDetails = const [],
    this.yourPostsLoading = false,
  });

  YourPostState copyWith({
    String? errorMessage,
    List<PostDetails>? yourPostDetails,
    List<PostDetails>? filteredPostDetails,
    bool? yourPostsLoading,
  }) {
    return YourPostState(
      errorMessage: errorMessage ?? this.errorMessage,
      yourPostDetails: yourPostDetails ?? this.yourPostDetails,
      yourPostsLoading: yourPostsLoading ?? this.yourPostsLoading,
    );
  }

  @override
  List<Object> get props => [errorMessage, yourPostDetails, yourPostsLoading];
}
