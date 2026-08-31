import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:local_markerplace/dashboard/repository/dashboard_repository.dart';

part 'create_post_event.dart';
part 'create_post_state.dart';

class CreatePostBloc extends Bloc<CreatePostEvent, CreatePostState> {
  final DashboardRepository dashboardRepository;
  CreatePostBloc({required this.dashboardRepository})
    : super(CreatePostState.initial()) {
    on<OnDismissAlertMessage>(_onDismissAlertMessage);
    on<OnFetchCategories>(_onFetchCategories);
    on<OnSelectCategory>(_onSelectCategory);
    on<OnChangeOtherCategory>(_onChangeOtherCategory);
    on<OnChangeDescription>(_onChangeDescription);
    on<OnChangeBudget>(_onChangeBudget);
    on<OnChangeImage>(_onChangeImage);
    on<OnSubmitPost>(_onSubmitPost);
  }

  void _onDismissAlertMessage(
    OnDismissAlertMessage event,
    Emitter<CreatePostState> emit,
  ) {
    emit(state.copyWith(errorMessage: ''));
  }

  Future<void> _onFetchCategories(
    OnFetchCategories event,
    Emitter<CreatePostState> emit,
  ) async {
    final result = await dashboardRepository.getCategories();
    result.fold(
      (failure) =>
          emit(state.copyWith(errorMessage: 'Failed to fetch categories')),
      (categories) => emit(state.copyWith(category: categories)),
    );
  }

  void _onSelectCategory(
    OnSelectCategory event,
    Emitter<CreatePostState> emit,
  ) {
    emit(state.copyWith(selectedcategory: event.category));
  }

  void _onChangeOtherCategory(
    OnChangeOtherCategory event,
    Emitter<CreatePostState> emit,
  ) {
    emit(state.copyWith(otherCategory: event.otherCategory));
  }

  void _onChangeDescription(
    OnChangeDescription event,
    Emitter<CreatePostState> emit,
  ) {
    emit(state.copyWith(description: event.description));
  }

  void _onChangeBudget(OnChangeBudget event, Emitter<CreatePostState> emit) {
    emit(state.copyWith(budget: event.budget));
  }

  void _onChangeImage(OnChangeImage event, Emitter<CreatePostState> emit) {
    emit(state.copyWith(imagePath: event.imagePath));
  }

  void _onSubmitPost(OnSubmitPost event, Emitter<CreatePostState> emit) {
    // Handle the submission logic here, e.g., call a repository method to submit the post.
  }
}
