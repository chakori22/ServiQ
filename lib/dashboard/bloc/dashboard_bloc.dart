import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:local_markerplace/dashboard/model/post_details.dart';
import 'package:local_markerplace/dashboard/repository/dashboard_repository.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

// class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
//   DashboardBloc() : super(const DashboardState.initial()) {
//     on<OnFetchPostDetails>(_onFetchPostDetails);
//   }
//   void _onFetchPostDetails(
//     OnFetchPostDetails event,
//     Emitter<DashboardState> emit,
//   ) {
//     // TODO: implement event handler
//   }
// }

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc({required DashboardRepository dashboardRepository})
    : _dashboardRepository = dashboardRepository,
      super(const DashboardState.initial()) {
    on<OnFetchPostDetails>(_onFetchPostDetails);
  }

  final DashboardRepository _dashboardRepository;

  Future<void> _onFetchPostDetails(
    OnFetchPostDetails event,
    Emitter<DashboardState> emit,
  ) async {
    final result = await _dashboardRepository.getPostDetails();
    result.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.errorMessage));
      },
      (postDetails) {
        emit(
          state.copyWith(
            errorMessage: "",
            filteredPostDetails: postDetails.sublist(0, 4),
            postDetails: postDetails,
          ),
        );
      },
    );
  }
}
