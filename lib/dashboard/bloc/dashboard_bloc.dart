import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(const DashboardState.initial()) {
    on<DashboardStarted>(_onDashboardStarted);
  }
  void _onDashboardStarted(
    DashboardStarted event,
    Emitter<DashboardState> emit,
  ) {
    // TODO: implement event handler
  }
}
