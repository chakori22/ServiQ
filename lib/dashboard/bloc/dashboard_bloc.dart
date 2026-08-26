import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:local_markerplace/dashboard/model/post_details.dart';
import 'package:local_markerplace/dashboard/model/services.dart';
import 'package:local_markerplace/dashboard/model/your_post.dart';
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
    on<OnFetchYourPostDetails>(_onFetchYourPostDetails);
    on<OnFetchServiceDetails>(_onFetchServiceDetails);
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

  Future<void> _onFetchYourPostDetails(
    OnFetchYourPostDetails event,
    Emitter<DashboardState> emit,
  ) async {
    final result = await _dashboardRepository.getYourPostDetails();
    result.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.errorMessage));
      },
      (yourPostDetails) {
        emit(
          state.copyWith(errorMessage: "", yourPostDetails: yourPostDetails),
        );
      },
    );
  }

  Future<void> _onFetchServiceDetails(
    OnFetchServiceDetails event,
    Emitter<DashboardState> emit,
  ) async {
    final result = await _dashboardRepository.getServiceDetails();
    result.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.errorMessage));
      },
      (serviceDetails) {
        emit(state.copyWith(errorMessage: "", serviceDetails: serviceDetails));
      },
    );
  }
}
