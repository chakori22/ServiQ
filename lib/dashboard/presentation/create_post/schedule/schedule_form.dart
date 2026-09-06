import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_markerplace/components/dropdown.dart';
import 'package:local_markerplace/components/textfield.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/core/app_routes.dart';
import 'package:local_markerplace/dashboard/model/time_slot.dart';
import 'package:local_markerplace/dashboard/presentation/create_post/bloc/create_post_bloc.dart';
import 'package:local_markerplace/dashboard/model/post_priority.dart';
import 'package:local_markerplace/dashboard/presentation/create_post/priority/priority_page.dart';
import 'package:local_markerplace/dashboard/presentation/create_post/components/composer_fields.dart';
import 'package:local_markerplace/dashboard/presentation/posts/presentation/post_screen.dart';
import 'package:local_markerplace/dashboard/repository/dashboard_repository.dart';
import 'package:local_markerplace/network/auth_session.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_header.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:shimmer/shimmer.dart';

/// "Schedule for Later" form.
///
/// Collects the same details as the instant form — category, description,
/// budget, photo — and adds a date. The times themselves are not picked
/// freehand: choosing a date fetches that day's windows from the API, and the
/// user picks one of those.
class ScheduleFormPage extends StatelessWidget {
  const ScheduleFormPage({super.key, this.localityName});

  /// The area the requirement is for. Travels on so the board the post
  /// lands on can still name it.
  final String? localityName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          CreatePostBloc(dashboardRepository: const DashboardRepository()),
      child: _ScheduleForm(localityName: localityName),
    );
  }
}

class _ScheduleForm extends StatefulWidget {
  const _ScheduleForm({this.localityName});

  final String? localityName;

  @override
  State<_ScheduleForm> createState() => _ScheduleFormState();
}

class _ScheduleFormState extends State<_ScheduleForm> {
  /// How many dates the user can choose from, counting today. Jobs can only
  /// be booked a few days out, so the calendar stops there.
  static const int _selectableDateCount = 4;

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _otherCategoryController =
      TextEditingController();

  /// Holds the formatted date so the field can render through the shared
  /// [AppTextField]; the date itself lives in CreatePostState.
  final TextEditingController _dateController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  /// Local File used for previewing the picked photo; the path is mirrored
  /// into CreatePostState via OnChangeImage for form validation.
  File? _pickedImage;

  @override
  void initState() {
    context.read<CreatePostBloc>().add(const OnFetchCategories());
    super.initState();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _budgetController.dispose();
    _otherCategoryController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? picked = await _imagePicker.pickImage(
      source: source,
      imageQuality: 80, // compress to keep upload size reasonable
      maxWidth: 1600,
    );

    if (picked == null || !mounted) return;

    setState(() {
      _pickedImage = File(picked.path);
    });
    context.read<CreatePostBloc>().add(OnChangeImage(picked.path));
  }

  void _removeImage() {
    setState(() {
      _pickedImage = null;
    });
    context.read<CreatePostBloc>().add(const OnChangeImage(''));
  }

  /// Opens the calendar, limited to the next [_selectableDateCount] dates
  /// starting today. Selecting a day is what asks the API for that day's
  /// windows, so nothing else needs to trigger the fetch.
  Future<void> _pickDate(DateTime? current) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? today,
      firstDate: today,
      lastDate: today.add(const Duration(days: _selectableDateCount - 1)),
    );

    if (picked == null || !mounted) return;
    _dateController.text = formatScheduleDate(picked);
    context.read<CreatePostBloc>().add(OnSelectDate(picked));
  }

  Future<void> _showImageSourceSheet() async {
    final source = await showPhotoSourceSheet(context);
    if (source == null) return;
    await _pickImage(source);
  }

  /// How far the post will be pushed. Presentational for now — nothing
  /// takes a payment and the choice does not travel with the draft.
  PostPriority _priority = PostPriority.standard;

  /// The signed-in user's handle, stamped onto whatever they post so the
  /// board's "Mine" filter can find it again. Null where no session is in
  /// the tree, and the draft falls back to its own placeholder.
  String? get _signedInUsername {
    try {
      return context.read<AuthSession>().user?.username;
    } on ProviderNotFoundException {
      return null;
    }
  }

  Future<void> _pickPriority() async {
    final chosen = await Navigator.of(context).push<PostPriority>(
      MaterialPageRoute(
        builder: (_) => PriorityPage(
          requirement: _descriptionController.text,
          selected: _priority,
        ),
      ),
    );
    if (chosen == null || !mounted) return;
    setState(() => _priority = chosen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        bottom: false,
        child: BlocConsumer<CreatePostBloc, CreatePostState>(
          listenWhen: (previous, current) =>
              current.errorMessage.isNotEmpty &&
              previous.errorMessage != current.errorMessage,
          listener: (context, state) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.errorMessage)));
            context.read<CreatePostBloc>().add(const OnDismissAlertMessage());
          },
          builder: (context, state) {
            return Column(
              children: [
                const DiscoveryHeader(title: 'Schedule a requirement'),
                const SizedBox(height: 14),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColor.discoveryBorder,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ComposerField(
                          label: 'WHAT DO YOU NEED',
                          child: AppTextField(
                            controller: _descriptionController,
                            hintText: 'Chimney deep clean before Diwali',
                            keyboardType: TextInputType.text,
                            maxLines: 4,
                            maxLength: 200,
                            fillColor: AppColor.white,
                            borderColor: AppColor.discoveryBorder,
                            borderWidth: 1.4,
                            cornerRadius: 16,
                            verticalPadding: 14.2,
                            textStyle: DiscoveryText.fieldInput,
                            hintStyle: DiscoveryText.searchHint,
                            onChanged: (value) => context
                                .read<CreatePostBloc>()
                                .add(OnChangeDescription(value)),
                          ),
                        ),
                        ComposerField(
                          label: 'CATEGORY',
                          child: AppDropdownField<String>(
                            hintText: 'Pick a category',
                            fillColor: AppColor.white,
                            value: state.selectedcategory.isEmpty
                                ? null
                                : state.selectedcategory,
                            borderColor: AppColor.discoveryBorder,
                            borderWidth: 1.4,
                            cornerRadius: 16,
                            items: state.category
                                .map(
                                  (category) => AppDropdownItem(
                                    value: category,
                                    label: category,
                                  ),
                                )
                                .toList(),
                            onChanged: (value) => context
                                .read<CreatePostBloc>()
                                .add(OnSelectCategory(value ?? '')),
                          ),
                        ),
                        if (state.selectedcategory == 'Others')
                          ComposerField(
                            label: 'WHICH TRADE',
                            child: AppTextField(
                              controller: _otherCategoryController,
                              hintText: 'Tell us what you need',
                              keyboardType: TextInputType.text,
                              maxLines: 1,
                              maxLength: 200,
                              fillColor: AppColor.white,
                              borderColor: AppColor.discoveryBorder,
                              borderWidth: 1.4,
                              cornerRadius: 16,
                              verticalPadding: 14.2,
                              textStyle: DiscoveryText.fieldInput,
                              hintStyle: DiscoveryText.searchHint,
                              onChanged: (value) => context
                                  .read<CreatePostBloc>()
                                  .add(OnChangeOtherCategory(value)),
                            ),
                          ),
                        ComposerField(
                          label: 'BUDGET',
                          child: AppTextField(
                            controller: _budgetController,
                            hintText: '500',
                            prefixText: '₹',
                            keyboardType: TextInputType.number,
                            maxLines: 1,
                            maxLength: 20,
                            fillColor: AppColor.white,
                            borderColor: AppColor.discoveryBorder,
                            borderWidth: 1.4,
                            cornerRadius: 16,
                            verticalPadding: 14.2,
                            textStyle: DiscoveryText.fieldInput,
                            hintStyle: DiscoveryText.searchHint,
                            onChanged: (value) => context
                                .read<CreatePostBloc>()
                                .add(OnChangeBudget(value)),
                          ),
                        ),
                        ComposerField(
                          label: 'DATE',
                          child: _DateField(
                            controller: _dateController,
                            onTap: () => _pickDate(state.selectedDate),
                          ),
                        ),
                        ComposerField(
                          label: 'TIME',
                          child: _TimeSlotSection(state: state),
                        ),
                        ComposerField(
                          label: 'PHOTO',
                          child: PhotoUploadTile(
                            image: _pickedImage,
                            onPick: _showImageSourceSheet,
                            onRemove: _removeImage,
                          ),
                        ),
                        ComposerField(
                          label: 'HOW URGENT',
                          child: PriorityRow(
                            priority: _priority,
                            onTap: _pickPriority,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your number stays hidden until you accept an offer.',
                          style: DiscoveryText.smallPrint.copyWith(
                            color: AppColor.discoveryTextTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: BlocBuilder<CreatePostBloc, CreatePostState>(
        builder: (context, state) => ComposerFooter(
          enabled: state.isScheduleFormValid,
          // The upload belongs to the posts page, not this form: posting
          // replaces the form with the board, which shows the post's
          // progress banner while it uploads.
          onPost: () => GoRouter.of(context).pushReplacementAppRoute(
            AppRoutes.posts,
            extra: state.toDraft(isInstant: false, username: _signedInUsername),
          ),
        ),
      ),
    );
  }
}

/// Date input. Renders through the shared [AppTextField] so it matches the
/// category, description and budget fields exactly — same border, radius and
/// floating label — but absorbs pointers so a tap opens the calendar instead
/// of the keyboard.
class _DateField extends StatelessWidget {
  const _DateField({required this.controller, required this.onTap});

  final TextEditingController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AbsorbPointer(
        child: AppTextField(
          controller: controller,
          hintText: 'Select date',
          fillColor: AppColor.white,
          borderColor: AppColor.discoveryBorder,
          borderWidth: 1.4,
          cornerRadius: 16,
          verticalPadding: 14.2,
          textStyle: DiscoveryText.fieldInput,
          hintStyle: DiscoveryText.searchHint,
          suffixIcon: const Icon(
            Icons.calendar_month_rounded,
            size: 20,
            color: AppColor.discoveryTextTertiary,
          ),
        ),
      ),
    );
  }
}

const List<String> _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];
const List<String> _weekdays = [
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun',
];

/// "Mon, 12 Sep 2026" — what the date field shows once a day is chosen.
String formatScheduleDate(DateTime date) {
  final weekday = _weekdays[date.weekday - 1];
  return '$weekday, ${date.day} ${_months[date.month - 1]} ${date.year}';
}

/// The day's bookable windows, in whichever of its four states applies: no
/// date chosen yet, loading, nothing left on that day, or the choices.
///
/// Only windows the API reports as available are listed — a slot the user
/// can't take is noise on a form whose whole job is picking one.
class _TimeSlotSection extends StatelessWidget {
  const _TimeSlotSection({required this.state});

  final CreatePostState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.discoveryBorder, width: 1.4),
      ),
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (state.selectedDate == null) {
      return const _SlotMessage('Pick a date to see the times available.');
    }
    if (state.timeSlotsLoading) {
      return const _SlotShimmer();
    }
    final slots = state.availableTimeSlots;
    if (slots.isEmpty) {
      return const _SlotMessage(
        'No times available on this date. Try another day.',
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: slots
          .map(
            (slot) => _SlotChip(
              slot: slot,
              isSelected: slot.id == state.selectedTimeSlotId,
              onSelected: () =>
                  context.read<CreatePostBloc>().add(OnSelectTimeSlot(slot.id)),
            ),
          )
          .toList(),
    );
  }
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.slot,
    required this.isSelected,
    required this.onSelected,
  });

  final TimeSlot slot;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.indicativeBlueColor500 : AppColor.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColor.indicativeBlueColor500
                : AppColor.neutralGreyColor100,
          ),
        ),
        child: Text(
          slot.label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColor.white : AppColor.neutralGreyColor700,
          ),
        ),
      ),
    );
  }
}

class _SlotMessage extends StatelessWidget {
  const _SlotMessage(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: const TextStyle(fontSize: 13, color: AppColor.neutralGreyColor400),
    );
  }
}

/// Placeholder chips shown while the day's windows are being fetched.
class _SlotShimmer extends StatelessWidget {
  const _SlotShimmer();

  /// Roughly a working day's worth of windows.
  static const int chipCount = 6;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColor.indicativeBlueColor100,
      highlightColor: AppColor.indicativeBlueColor50,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(
          chipCount,
          (index) => Container(
            width: 140,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}
