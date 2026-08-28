part of 'dashboard_bloc.dart';

class DashboardState extends Equatable {
  final String errorMessage;
  final List<PostDetails> postDetails;
  final List<PostDetails> filteredPostDetails;
  final List<YourPostDetails> yourPostDetails;
  final List<ServiceDetails> serviceDetails;
  final bool servicesLoading;
  final bool postsLoading;
  final bool yourPostsLoading;
  const DashboardState({
    required this.errorMessage,
    required this.postDetails,
    required this.filteredPostDetails,
    required this.yourPostDetails,
    required this.serviceDetails,
    required this.servicesLoading,
    required this.postsLoading,
    required this.yourPostsLoading,
  });

  const DashboardState.initial({
    this.errorMessage = '',
    this.postDetails = const [],
    this.filteredPostDetails = const [],
    this.yourPostDetails = const [],
    this.serviceDetails = const [],
    this.servicesLoading = false,
    this.postsLoading = false,
    this.yourPostsLoading = false,
  });

  DashboardState copyWith({
    String? errorMessage,
    List<PostDetails>? postDetails,
    List<PostDetails>? filteredPostDetails,
    List<YourPostDetails>? yourPostDetails,
    List<ServiceDetails>? serviceDetails,
    bool? servicesLoading,
    bool? postsLoading,
    bool? yourPostsLoading,
  }) {
    return DashboardState(
      errorMessage: errorMessage ?? this.errorMessage,
      postDetails: postDetails ?? this.postDetails,
      filteredPostDetails: filteredPostDetails ?? this.filteredPostDetails,
      yourPostDetails: yourPostDetails ?? this.yourPostDetails,
      serviceDetails: serviceDetails ?? this.serviceDetails,
      servicesLoading: servicesLoading ?? this.servicesLoading,
      postsLoading: postsLoading ?? this.postsLoading,
      yourPostsLoading: yourPostsLoading ?? this.yourPostsLoading,
    );
  }

  List<ServiceDetails> get selectedServices =>
      serviceDetails.where((service) => service.isSelected).toList();

  int get selectedServicesCount => selectedServices.length;

  String get selectedServicesSummary =>
      selectedServices.map((service) => service.title).join(', ');

  @override
  List<Object> get props => [
    errorMessage,
    postDetails,
    filteredPostDetails,
    yourPostDetails,
    serviceDetails,
    servicesLoading,
    postsLoading,
    yourPostsLoading,
  ];
}
