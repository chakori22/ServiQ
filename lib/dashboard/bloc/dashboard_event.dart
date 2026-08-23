part of 'dashboard_bloc.dart';

sealed class DashboardEvent extends Equatable {
  const DashboardEvent();
}

final class DashboardStarted extends DashboardEvent {
  const DashboardStarted();

  @override
  List<Object> get props => [];
}
