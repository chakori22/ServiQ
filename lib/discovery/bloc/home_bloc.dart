import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:local_markerplace/discovery/model/home_feed.dart';
import 'package:local_markerplace/discovery/repository/home_repository.dart';
import 'package:local_markerplace/network/failure.dart';

part 'home_event.dart';
part 'home_state.dart';

/// Home's feed, and the two things that can happen to it: it arrives, or it
/// doesn't.
///
/// The screen holds no fetching of its own — it says what happened (the area
/// opened, the seeker pulled to refresh, they pressed Try again) and draws
/// whichever state comes back.
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeSource homeRepository;

  HomeBloc({required this.homeRepository}) : super(const HomeState.initial()) {
    on<HomeRequested>(_onHomeRequested);
    on<HomeRefreshed>(_onHomeRefreshed);
  }

  /// Opening an area, and re-opening it after a failure.
  ///
  /// This is the one that shows the skeleton: there is nothing on screen
  /// worth keeping, so the screen wears the shape it is about to become.
  Future<void> _onHomeRequested(
    HomeRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        localitySlug: event.localitySlug,
        isLoading: true,
        failure: null,
        failedAt: null,
      ),
    );
    await _fetch(event.localitySlug, emit);
  }

  /// Pulling the list down.
  ///
  /// Deliberately not a skeleton: the seeker is looking at the feed and
  /// asking for a newer one, and the pull's own indicator already says so.
  Future<void> _onHomeRefreshed(
    HomeRefreshed event,
    Emitter<HomeState> emit,
  ) async {
    if (state.isLoading || state.isRefreshing) return;
    emit(state.copyWith(isRefreshing: true));
    await _fetch(state.localitySlug, emit);
  }

  Future<void> _fetch(String localitySlug, Emitter<HomeState> emit) async {
    final result = await homeRepository.home(localitySlug: localitySlug);

    result.fold(
      // The moment is kept because the error state quotes it: a reference
      // with no time against it is not much use to whoever is asked about it.
      (failure) => emit(
        state.copyWith(
          isLoading: false,
          isRefreshing: false,
          failure: failure,
          failedAt: DateTime.now(),
        ),
      ),
      (feed) => emit(
        state.copyWith(
          isLoading: false,
          isRefreshing: false,
          feed: feed,
          failure: null,
          failedAt: null,
        ),
      ),
    );
  }
}
