part of 'dashboard_bloc.dart';

class DashboardState extends Equatable {
  final String errorMessage;
  final List<PostDetails> postDetails;
  final List<PostDetails> filteredPostDetails;
  final List<YourPostDetails> yourPostDetails;
  final List<ServiceDetails> serviceDetails;
  const DashboardState({
    required this.errorMessage,
    required this.postDetails,
    required this.filteredPostDetails,
    required this.yourPostDetails,
    required this.serviceDetails,
  });

  const DashboardState.initial({
    this.errorMessage = '',
    this.postDetails = const [],
    this.filteredPostDetails = const [],
    this.yourPostDetails = const [],
    this.serviceDetails = const [],
  });

  DashboardState copyWith({
    String? errorMessage,
    List<PostDetails>? postDetails,
    List<PostDetails>? filteredPostDetails,
    List<YourPostDetails>? yourPostDetails,
    List<ServiceDetails>? serviceDetails,
  }) {
    return DashboardState(
      errorMessage: errorMessage ?? this.errorMessage,
      postDetails: postDetails ?? this.postDetails,
      filteredPostDetails: filteredPostDetails ?? this.filteredPostDetails,
      yourPostDetails: yourPostDetails ?? this.yourPostDetails,
      serviceDetails: serviceDetails ?? this.serviceDetails,
    );
  }

  @override
  List<Object> get props => [
    errorMessage,
    postDetails,
    filteredPostDetails,
    yourPostDetails,
    serviceDetails,
  ];
}
