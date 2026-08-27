part of 'create_post_bloc.dart';

class CreatePostState extends Equatable {
  final String errorMessage;
  final List<String> category;
  final String selectedcategory;
  final String otherCategory;
  final String description;
  final String budget;
  final String imagePath;

  const CreatePostState({
    required this.errorMessage,
    required this.category,
    required this.selectedcategory,
    required this.otherCategory,
    required this.description,
    required this.budget,
    required this.imagePath,
  });

  const CreatePostState.initial({
    this.errorMessage = '',
    this.category = const [],
    this.selectedcategory = '',
    this.otherCategory = '',
    this.description = '',
    this.budget = '',
    this.imagePath = '',
  });

  CreatePostState copyWith({
    String? errorMessage,
    List<String>? category,
    String? selectedcategory,
    String? otherCategory,
    String? description,
    String? budget,
    String? imagePath,
  }) {
    return CreatePostState(
      errorMessage: errorMessage ?? this.errorMessage,
      category: category ?? this.category,
      selectedcategory: selectedcategory ?? this.selectedcategory,
      otherCategory: otherCategory ?? this.otherCategory,
      description: description ?? this.description,
      budget: budget ?? this.budget,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  bool get isFormValid {
    final categoryValid =
        selectedcategory.isNotEmpty &&
        (selectedcategory != 'Others' || otherCategory.trim().isNotEmpty);

    return categoryValid &&
        description.trim().isNotEmpty &&
        budget.trim().isNotEmpty &&
        imagePath.isNotEmpty;
  }

  @override
  List<Object> get props => [
    errorMessage,
    category,
    selectedcategory,
    otherCategory,
    description,
    budget,
    imagePath,
  ];
}
