part of 'dashboard_bloc.dart';

sealed class DashboardEvent extends Equatable {
  const DashboardEvent();
}

final class OnFetchPostDetails extends DashboardEvent {
  const OnFetchPostDetails();

  @override
  List<Object> get props => [];
}

final class OnFetchYourPostDetails extends DashboardEvent {
  const OnFetchYourPostDetails();

  @override
  List<Object> get props => [];
}

final class OnFetchServiceDetails extends DashboardEvent {
  const OnFetchServiceDetails();

  @override
  List<Object> get props => [];
}

final class OnToggleServiceSelection extends DashboardEvent {
  final int index;

  const OnToggleServiceSelection(this.index);

  @override
  List<Object> get props => [index];
}

final class OnChangeServiceCount extends DashboardEvent {
  final int index;
  final int count;

  const OnChangeServiceCount(this.index, this.count);

  @override
  List<Object> get props => [index, count];
}
