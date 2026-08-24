part of 'dashboard_bloc.dart';

class DashboardState extends Equatable {
  final String errorMessage;
  final List<PostDetails> postDetails;
  final List<PostDetails> filteredPostDetails;
  const DashboardState({
    required this.errorMessage,
    required this.postDetails,
    required this.filteredPostDetails,
  });

  const DashboardState.initial({
    this.errorMessage = '',
    this.postDetails = const [],
    this.filteredPostDetails = const [],
  });

  DashboardState copyWith({
    String? errorMessage,
    List<PostDetails>? postDetails,
    List<PostDetails>? filteredPostDetails,
  }) {
    return DashboardState(
      errorMessage: errorMessage ?? this.errorMessage,
      postDetails: postDetails ?? this.postDetails,
      filteredPostDetails: filteredPostDetails ?? this.filteredPostDetails,
    );
  }

  @override
  List<Object> get props => [errorMessage, postDetails, filteredPostDetails];
}
