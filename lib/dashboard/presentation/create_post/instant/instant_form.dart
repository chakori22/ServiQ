import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_markerplace/app_color.dart';
import 'package:local_markerplace/components/dropdown.dart';
import 'package:local_markerplace/components/primary_button.dart';
import 'package:local_markerplace/components/textfield.dart';
import 'package:local_markerplace/dashboard/presentation/create_post/bloc/create_post_bloc.dart';
import 'package:local_markerplace/dashboard/repository/dashboard_repository.dart';

class InstantFormPage extends StatelessWidget {
  const InstantFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          CreatePostBloc(dashboardRepository: const DashboardRepository()),
      child: const _InstantForm(),
    );
  }
}

class _InstantForm extends StatefulWidget {
  const _InstantForm();

  @override
  State<_InstantForm> createState() => _InstantFormState();
}

class _InstantFormState extends State<_InstantForm> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _otherCategoryController =
      TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  /// Local File used for previewing the picked photo; the path is mirrored
  /// into CreatePostState via OnChangeImage for form validation.
  File? _pickedImage;

  @override
  void initState() {
    context.read<CreatePostBloc>().add(OnFetchCategories());
    super.initState();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _budgetController.dispose();
    _otherCategoryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? picked = await _imagePicker.pickImage(
      source: source,
      imageQuality: 80, // compress to keep upload size reasonable
      maxWidth: 1600,
    );

    if (picked == null) return;

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
        animateColor: true,
        automaticallyImplyLeading: false,
        backgroundColor: AppColor.white,
        surfaceTintColor: AppColor.white,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(width: 8),
            const Text(
              'Instant Service',
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
        listener: (context, state) {
          // TODO: implement listener
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

                  _buildPhotosSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<CreatePostBloc, CreatePostState>(
        builder: (context, state) => _buildBottomBar(state.isFormValid),
      ),
    );
  }

  /// Fixed Post button, pinned to the bottom of the screen regardless of
  /// scroll position. SafeArea keeps it clear of the home indicator on
  /// devices with a gesture bar; the extra bottom padding stops it from
  /// sitting flush against the screen edge.
  Widget _buildBottomBar(bool isFormValid) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          // color: AppColor.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: PrimaryButton(
          label: "Share",
          enabled: isFormValid,
          onPressed: () {
            context.read<CreatePostBloc>().add(OnSubmitPost());
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  Widget _buildPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photo',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColor.indicativeBlueColor700,
          ),
        ),
        const SizedBox(height: 8),
        if (_pickedImage == null)
          GestureDetector(
            onTap: _showImageSourceSheet,
            child: Container(
              width: double.infinity,
              height: 90,
              decoration: BoxDecoration(
                color: AppColor.neutralGreyColor60,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColor.neutralGreyColor300),
              ),
              child: Icon(
                Icons.add_a_photo_outlined,
                color: AppColor.neutralGreyColor700,
              ),
            ),
          )
        else
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _pickedImage!,
                  width: double.infinity,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: -6,
                right: -6,
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
      ],
    );
  }
}
