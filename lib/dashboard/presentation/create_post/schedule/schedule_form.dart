import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_markerplace/components/dropdown.dart';
import 'package:local_markerplace/components/primary_button.dart';
import 'package:local_markerplace/components/textfield.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/dashboard/model/time_slot.dart';
import 'package:local_markerplace/dashboard/presentation/create_post/bloc/create_post_bloc.dart';
import 'package:local_markerplace/dashboard/repository/dashboard_repository.dart';
import 'package:shimmer/shimmer.dart';

/// "Schedule for Later" form.
///
/// Collects the same details as the instant form — category, description,
/// budget, photo — and adds a date. The times themselves are not picked
/// freehand: choosing a date fetches that day's windows from the API, and the
/// user picks one of those.
class ScheduleFormPage extends StatelessWidget {
  const ScheduleFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          CreatePostBloc(dashboardRepository: const DashboardRepository()),
      child: const _ScheduleForm(),
    );
  }
}

class _ScheduleForm extends StatefulWidget {
  const _ScheduleForm();

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

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColor.neutralGreyColor300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.neutralGreyColor60,
      appBar: AppBar(
        elevation: 4,
        automaticallyImplyLeading: false,
        backgroundColor: AppColor.white,
        surfaceTintColor: AppColor.white,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 8),
            const Text(
              'Schedule for Later',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColor.neutralGreyColor700,
              ),
            ),
          ],
        ),
      ),
      body: BlocConsumer<CreatePostBloc, CreatePostState>(
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
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppDropdownField<String>(
                    labelText: 'Category',
                    hintText: 'Select category',
                    value: state.selectedcategory.isNotEmpty
                        ? state.selectedcategory
                        : "Others",
                    floatingLabel: true,
                    enabledLabelColor: AppColor.indicativeBlueColor700,
                    borderColor: AppColor.neutralGreyColor300,
                    items: state.category.map((category) {
                      return AppDropdownItem(value: category, label: category);
                    }).toList(),
                    onChanged: (value) {
                      context.read<CreatePostBloc>().add(
                        OnSelectCategory(value ?? "Others"),
                      );
                    },
                  ),
                  Visibility(
                    visible: state.selectedcategory == "Others",
                    child: const SizedBox(height: 12),
                  ),
                  Visibility(
                    visible: state.selectedcategory == "Others",
                    child: AppTextField(
                      labelText: 'If others(please specify)',
                      floatingLabel: true,
                      controller: _otherCategoryController,
                      hintText: 'Enter description',
                      prefixText: '',
                      keyboardType: TextInputType.text,
                      maxLines: 1,
                      maxLength: 200,
                      enabledLabelColor: AppColor.indicativeBlueColor700,
                      borderColor: AppColor.neutralGreyColor300,
                      onChanged: (value) {
                        context.read<CreatePostBloc>().add(
                          OnChangeOtherCategory(value),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    labelText: 'Description',
                    floatingLabel: true,
                    controller: _descriptionController,
                    hintText: 'Enter description',
                    prefixText: '',
                    keyboardType: TextInputType.text,
                    maxLines: 4,
                    maxLength: 200,
                    enabledLabelColor: AppColor.indicativeBlueColor700,
                    borderColor: AppColor.neutralGreyColor300,
                    onChanged: (value) {
                      context.read<CreatePostBloc>().add(
                        OnChangeDescription(value),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    labelText: 'Budget',
                    floatingLabel: true,
                    controller: _budgetController,
                    hintText: 'Enter budget',
                    prefixText: '₹',
                    keyboardType: TextInputType.number,
                    maxLines: 1,
                    maxLength: 20,
                    enabledLabelColor: AppColor.indicativeBlueColor700,
                    borderColor: AppColor.neutralGreyColor300,
                    onChanged: (value) {
                      context.read<CreatePostBloc>().add(OnChangeBudget(value));
                    },
                  ),
                  const SizedBox(height: 12),
                  _DateField(
                    controller: _dateController,
                    onTap: () => _pickDate(state.selectedDate),
                  ),
                  const SizedBox(height: 20),
                  _TimeSlotSection(state: state),
                  const SizedBox(height: 20),
                  _buildPhotosSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<CreatePostBloc, CreatePostState>(
        builder: (context, state) => _buildBottomBar(state.isScheduleFormValid),
      ),
    );
  }

  /// Fixed Post button, pinned to the bottom of the screen regardless of
  /// scroll position. SafeArea keeps it clear of the home indicator on
  /// devices with a gesture bar.
  Widget _buildBottomBar(bool isFormValid) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: PrimaryButton(
          label: "Share",
          enabled: isFormValid,
          onPressed: () {
            context.read<CreatePostBloc>().add(const OnSubmitPost());
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  Widget _buildPhotosSection() {
    return _FloatingLabelBox(
      label: 'Photo',
      child: SizedBox(
        width: double.infinity,
        height: 90,
        child: _pickedImage == null
            ? GestureDetector(
                onTap: _showImageSourceSheet,
                behavior: HitTestBehavior.opaque,
                child: const Icon(
                  Icons.add_a_photo_outlined,
                  color: AppColor.neutralGreyColor700,
                ),
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(_pickedImage!, fit: BoxFit.cover),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: _removeImage,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.black87,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
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
          labelText: 'Date',
          hintText: 'Select date',
          floatingLabel: true,
          enabledLabelColor: AppColor.indicativeBlueColor700,
          borderColor: AppColor.neutralGreyColor300,
          suffixIcon: const Icon(
            Icons.calendar_month_rounded,
            size: 20,
            color: AppColor.neutralGreyColor500,
          ),
        ),
      ),
    );
  }
}

const List<String> _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];
const List<String> _weekdays = [
  'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
];

/// "Mon, 12 Sep 2026" — what the date field shows once a day is chosen.
String formatScheduleDate(DateTime date) {
  final weekday = _weekdays[date.weekday - 1];
  return '$weekday, ${date.day} ${_months[date.month - 1]} ${date.year}';
}

/// A field-styled box with a floating label notched into its border, matching
/// [AppTextField]'s outlined look for content that isn't a text field.
class _FloatingLabelBox extends StatelessWidget {
  const _FloatingLabelBox({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          // Full width so the box lines up with the text fields above it
          // rather than shrinking to fit its content.
          width: double.infinity,
          // Top margin leaves room for the label notch, exactly as the
          // shared text field does.
          margin: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            color: AppColor.neutralGreyColor60,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColor.neutralGreyColor300),
          ),
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
        Positioned(
          left: 16,
          top: 0,
          child: Container(
            // Page-coloured background cuts the notch out of the border line.
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              label,
              softWrap: false,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColor.indicativeBlueColor700,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
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
    return _FloatingLabelBox(
      label: 'Time',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildContent(context),
      ),
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
              onSelected: () => context.read<CreatePostBloc>().add(
                OnSelectTimeSlot(slot.id),
              ),
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
            color: isSelected
                ? AppColor.white
                : AppColor.neutralGreyColor700,
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
      style: const TextStyle(
        fontSize: 13,
        color: AppColor.neutralGreyColor400,
      ),
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
