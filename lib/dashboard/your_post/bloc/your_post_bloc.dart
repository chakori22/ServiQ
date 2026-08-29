import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:local_markerplace/dashboard/model/post_details.dart';
import 'package:local_markerplace/dashboard/repository/dashboard_repository.dart';

part 'your_post_event.dart';
part 'your_post_state.dart';

class YourPostBloc extends Bloc<YourPostEvent, YourPostState> {
  YourPostBloc({required DashboardRepository dashboardRepository})
    : _dashboardRepository = dashboardRepository,
      super(const YourPostState.initial()) {
    on<OnFetchPostDetails>(_onFetchPostDetails);
  }
  final DashboardRepository _dashboardRepository;

  Future<void> _onFetchPostDetails(
    OnFetchPostDetails event,
    Emitter<YourPostState> emit,
  ) async {
    emit(state.copyWith(yourPostsLoading: true));
    final result = await _dashboardRepository.getPostDetails();
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            errorMessage: failure.errorMessage,
            yourPostDetails: const [],
            yourPostsLoading: false,
          ),
        );
      },
      (postDetails) {
        emit(
          state.copyWith(
            errorMessage: "",
            yourPostDetails: postDetails,
            yourPostsLoading: false,
          ),
        );
      },
    );
  }
}
