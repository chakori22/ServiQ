part of 'create_post_bloc.dart';

class CreatePostState extends Equatable {
  final String errorMessage;
  final List<String> category;
  final String selectedcategory;
  final String otherCategory;
  final String description;
  final String budget;
  final String imagePath;

  /// Day chosen on the "Schedule for Later" form; null on the instant form and
  /// until the user picks one.
  final DateTime? selectedDate;

  /// Windows returned by the API for [selectedDate].
  final List<TimeSlot> timeSlots;

  final String selectedTimeSlotId;
  final bool timeSlotsLoading;

  const CreatePostState({
    required this.errorMessage,
    required this.category,
    required this.selectedcategory,
    required this.otherCategory,
    required this.description,
    required this.budget,
    required this.imagePath,
    required this.selectedDate,
    required this.timeSlots,
    required this.selectedTimeSlotId,
    required this.timeSlotsLoading,
  });

  const CreatePostState.initial({
    this.errorMessage = '',
    this.category = const [],
    this.selectedcategory = '',
    this.otherCategory = '',
    this.description = '',
    this.budget = '',
    this.imagePath = '',
    this.selectedDate,
    this.timeSlots = const [],
    this.selectedTimeSlotId = '',
    this.timeSlotsLoading = false,
  });

  CreatePostState copyWith({
    String? errorMessage,
    List<String>? category,
    String? selectedcategory,
    String? otherCategory,
    String? description,
    String? budget,
    String? imagePath,
    DateTime? selectedDate,
    List<TimeSlot>? timeSlots,
    String? selectedTimeSlotId,
    bool? timeSlotsLoading,
  }) {
    return CreatePostState(
      errorMessage: errorMessage ?? this.errorMessage,
      category: category ?? this.category,
      selectedcategory: selectedcategory ?? this.selectedcategory,
      otherCategory: otherCategory ?? this.otherCategory,
      description: description ?? this.description,
      budget: budget ?? this.budget,
      imagePath: imagePath ?? this.imagePath,
      selectedDate: selectedDate ?? this.selectedDate,
      timeSlots: timeSlots ?? this.timeSlots,
      selectedTimeSlotId: selectedTimeSlotId ?? this.selectedTimeSlotId,
      timeSlotsLoading: timeSlotsLoading ?? this.timeSlotsLoading,
    );
  }

  /// The windows that can actually be booked. The API reports the full day,
  /// including windows already taken; the form only ever offers these.
  List<TimeSlot> get availableTimeSlots =>
      timeSlots.where((slot) => slot.isAvailable).toList();

  /// The window the user picked, or null if none is selected any more (a new
  /// date clears the choice, since slot ids belong to a single day).
  TimeSlot? get selectedTimeSlot {
    for (final slot in timeSlots) {
      if (slot.id == selectedTimeSlotId) return slot;
    }
    return null;
  }

  /// Instant posts need every shared field filled in.
  bool get isFormValid {
    final categoryValid =
        selectedcategory.isNotEmpty &&
        (selectedcategory != 'Others' || otherCategory.trim().isNotEmpty);

    return categoryValid &&
        description.trim().isNotEmpty &&
        budget.trim().isNotEmpty &&
        imagePath.isNotEmpty;
  }

  /// Scheduled posts need the same fields, plus a date and one of the
  /// windows the API returned for it.
  bool get isScheduleFormValid =>
      isFormValid && selectedDate != null && selectedTimeSlot != null;

  /// Packs the filled-in form into the draft the posts page uploads.
  ///
  /// [isInstant] is what separates the two forms: the scheduled one also
  /// carries the start of the window the user picked, while an instant post
  /// has no timing of its own.
  PostDraft toDraft({required bool isInstant}) {
    return PostDraft(
      category: selectedcategory == 'Others'
          ? otherCategory.trim()
          : selectedcategory,
      description: description.trim(),
      budget: budget.trim(),
      imagePath: imagePath,
      isInstant: isInstant,
      scheduledTime: isInstant ? null : selectedTimeSlot?.startTime,
    );
  }

  @override
  List<Object?> get props => [
    errorMessage,
    category,
    selectedcategory,
    otherCategory,
    description,
    budget,
    imagePath,
    selectedDate,
    timeSlots,
    selectedTimeSlotId,
    timeSlotsLoading,
  ];
}
