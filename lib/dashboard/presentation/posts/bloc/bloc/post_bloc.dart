import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:local_markerplace/dashboard/model/post_details.dart';
import 'package:local_markerplace/dashboard/repository/dashboard_repository.dart';
part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc({required DashboardRepository dashboardRepository})
    : _dashboardRepository = dashboardRepository,
      super(const PostState.initial()) {
    on<OnFetchPostDetails>(_onFetchPostDetails);
  }
  final DashboardRepository _dashboardRepository;

  Future<void> _onFetchPostDetails(
    OnFetchPostDetails event,
    Emitter<PostState> emit,
  ) async {
    emit(state.copyWith(postsLoading: true));
    final result = await _dashboardRepository.getPostDetails();
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            errorMessage: failure.errorMessage,
            postsLoading: false,
          ),
        );
      },
      (postDetails) {
        emit(
          state.copyWith(
            errorMessage: "",
            postDetails: postDetails,
            postsLoading: false,
          ),
        );
      },
    );
  }
}
