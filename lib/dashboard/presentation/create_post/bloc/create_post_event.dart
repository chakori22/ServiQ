part of 'create_post_bloc.dart';

sealed class CreatePostEvent extends Equatable {
  const CreatePostEvent();
}

final class OnDismissAlertMessage extends CreatePostEvent {
  const OnDismissAlertMessage();

  @override
  List<Object> get props => [];
}

final class OnFetchCategories extends CreatePostEvent {
  const OnFetchCategories();

  @override
  List<Object> get props => [];
}

final class OnSelectCategory extends CreatePostEvent {
  final String category;

  const OnSelectCategory(this.category);

  @override
  List<Object> get props => [category];
}

final class OnChangeOtherCategory extends CreatePostEvent {
  final String otherCategory;

  const OnChangeOtherCategory(this.otherCategory);

  @override
  List<Object> get props => [otherCategory];
}

final class OnChangeDescription extends CreatePostEvent {
  final String description;

  const OnChangeDescription(this.description);

  @override
  List<Object> get props => [description];
}

final class OnChangeBudget extends CreatePostEvent {
  final String budget;

  const OnChangeBudget(this.budget);

  @override
  List<Object> get props => [budget];
}

final class OnChangeImage extends CreatePostEvent {
  final String imagePath;

  const OnChangeImage(this.imagePath);

  @override
  List<Object> get props => [imagePath];
}
