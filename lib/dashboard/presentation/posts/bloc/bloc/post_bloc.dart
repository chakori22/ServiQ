import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:local_markerplace/dashboard/model/post_details.dart';
import 'package:local_markerplace/dashboard/model/post_draft.dart';
import 'package:local_markerplace/dashboard/model/post_offer.dart';
import 'package:local_markerplace/dashboard/repository/dashboard_repository.dart';
part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc({required DashboardRepository dashboardRepository})
    : _dashboardRepository = dashboardRepository,
      super(const PostState.initial()) {
    on<OnFetchPostDetails>(_onFetchPostDetails);
    on<OnStartPostUpload>(_onStartPostUpload);
    on<OnDismissAlertMessage>(_onDismissAlertMessage);
    on<OnOfferMade>(_onOfferMade);
    on<OnOfferAccepted>(_onOfferAccepted);
  }
  final DashboardRepository _dashboardRepository;

  /// Bumps the offer count on the post that was offered on. The offer's own
  /// details live in the offer store; the board only needs the number.
  void _onOfferMade(OnOfferMade event, Emitter<PostState> emit) {
    emit(
      state.copyWith(
        postDetails: [
          for (final post in state.postDetails)
            if (post.key == event.post.key)
              post.copyWith(acceptCount: post.acceptCount + 1)
            else
              post,
        ],
      ),
    );
  }

  /// Settles a requirement on the offer its owner picked.
  void _onOfferAccepted(OnOfferAccepted event, Emitter<PostState> emit) {
    emit(
      state.copyWith(
        postDetails: [
          for (final post in state.postDetails)
            if (post.key == event.post.key)
              post.copyWith(isAccepted: true, acceptedBy: event.offer.name)
            else
              post,
        ],
      ),
    );
  }

  Future<void> _onFetchPostDetails(
    OnFetchPostDetails event,
    Emitter<PostState> emit,
  ) async {
    emit(state.copyWith(postsLoading: true));
    final result = await _dashboardRepository.getPostDetails(
      currentUsername: event.currentUsername,
    );
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

  /// Runs the upload for a post the user just shared, keeping the banner's
  /// percentage in state as it goes. The finished post is prepended to the
  /// feed rather than refetched, so the user sees it the moment it lands.
  Future<void> _onStartPostUpload(
    OnStartPostUpload event,
    Emitter<PostState> emit,
  ) async {
    emit(state.copyWith(uploadingDraft: event.draft, uploadProgress: 0));

    await emit.forEach<double>(
      _dashboardRepository.uploadPost(event.draft),
      onData: (progress) => state.copyWith(uploadProgress: progress),
      onError: (_, _) => state.copyWith(
        errorMessage: 'Could not finish posting. Please try again.',
        clearUploadingDraft: true,
        uploadProgress: 0,
      ),
    );

    // A failure already cleared the draft; only publish when it survived.
    if (state.uploadingDraft == null) return;

    emit(
      state.copyWith(
        postDetails: [event.draft.toPostDetails(), ...state.postDetails],
        clearUploadingDraft: true,
        uploadProgress: 0,
      ),
    );
  }

  void _onDismissAlertMessage(
    OnDismissAlertMessage event,
    Emitter<PostState> emit,
  ) {
    emit(state.copyWith(errorMessage: ''));
  }
}
