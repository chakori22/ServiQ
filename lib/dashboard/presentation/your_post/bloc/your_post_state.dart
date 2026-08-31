part of 'your_post_bloc.dart';

class YourPostState extends Equatable {
  final String errorMessage;
  final List<YourPostDetails> yourPostDetails;
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

  bool get isEmpty => yourPostDetails.isEmpty;

  YourPostState copyWith({
    String? errorMessage,
    List<YourPostDetails>? yourPostDetails,
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
