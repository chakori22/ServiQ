part of 'post_bloc.dart';

class PostState extends Equatable {
  final String errorMessage;
  final List<PostDetails> postDetails;
  final bool postsLoading;

  const PostState({
    required this.errorMessage,
    required this.postDetails,

    required this.postsLoading,
  });

  const PostState.initial({
    this.errorMessage = '',
    this.postDetails = const [],
    this.postsLoading = false,
  });

  PostState copyWith({
    String? errorMessage,
    List<PostDetails>? postDetails,
    List<PostDetails>? filteredPostDetails,
    bool? postsLoading,
  }) {
    return PostState(
      errorMessage: errorMessage ?? this.errorMessage,
      postDetails: postDetails ?? this.postDetails,
      postsLoading: postsLoading ?? this.postsLoading,
    );
  }

  @override
  List<Object> get props => [errorMessage, postDetails, postsLoading];
}
