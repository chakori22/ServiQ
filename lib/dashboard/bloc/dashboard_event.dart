part of 'dashboard_bloc.dart';

sealed class DashboardEvent extends Equatable {
  const DashboardEvent();
}

final class OnFetchPostDetails extends DashboardEvent {
  const OnFetchPostDetails();

  @override
  List<Object> get props => [];
}
