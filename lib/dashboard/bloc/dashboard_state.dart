part of 'dashboard_bloc.dart';

class DashboardState extends Equatable {
  final String errorMessage;
  const DashboardState({required this.errorMessage});

  const DashboardState.initial({this.errorMessage = ''});

  DashboardState copyWith({String? errorMessage}) {
    return DashboardState(errorMessage: errorMessage ?? this.errorMessage);
  }

  @override
  List<Object> get props => [errorMessage];
}
