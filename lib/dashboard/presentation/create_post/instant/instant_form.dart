import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:local_markerplace/components/dropdown.dart';
import 'package:local_markerplace/components/motion/entrance.dart';
import 'package:local_markerplace/components/textfield.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/core/app_routes.dart';
import 'package:local_markerplace/dashboard/presentation/create_post/bloc/create_post_bloc.dart';
import 'package:local_markerplace/dashboard/model/post_priority.dart';
import 'package:local_markerplace/dashboard/presentation/create_post/priority/priority_page.dart';
import 'package:local_markerplace/dashboard/presentation/create_post/components/composer_fields.dart';
import 'package:local_markerplace/dashboard/presentation/posts/presentation/post_screen.dart';
import 'package:local_markerplace/dashboard/repository/dashboard_repository.dart';
import 'package:local_markerplace/network/auth_session.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_header.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';

/// 09 · 02 — the composer. The only screen that creates supply.
class InstantFormPage extends StatelessWidget {
  const InstantFormPage({super.key, this.localityName});

  /// The area the requirement is for. Travels on so the board the post
  /// lands on can still name it.
  final String? localityName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          CreatePostBloc(dashboardRepository: const DashboardRepository()),
      child: _InstantForm(localityName: localityName),
    );
  }
}

class _InstantForm extends StatefulWidget {
  const _InstantForm({this.localityName});

  final String? localityName;

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

    if (picked == null || !mounted) return;

    setState(() => _pickedImage = File(picked.path));
    context.read<CreatePostBloc>().add(OnChangeImage(picked.path));
  }

  void _removeImage() {
    setState(() => _pickedImage = null);
    context.read<CreatePostBloc>().add(const OnChangeImage(''));
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
          areaName: widget.localityName,
        ),
      ),
    );
    if (chosen == null || !mounted) return;
    setState(() => _priority = chosen);
  }

  Future<void> _showImageSourceSheet() async {
    final source = await showPhotoSourceSheet(context);
    if (source == null) return;
    await _pickImage(source);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<CreatePostBloc, CreatePostState>(
          builder: (context, state) {
            return Column(
              children: [
                const DiscoveryHeader(title: 'Post a requirement'),
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
                        FadeSlideIn(
                          child: ComposerField(
                            label: 'WHAT DO YOU NEED',
                            child: AppTextField(
                              controller: _descriptionController,
                              hintText: 'AC not cooling, makes noise',
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
                        ),
                        FadeSlideIn(
                          index: 1,
                          child: ComposerField(
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
                        FadeSlideIn(
                          index: 2,
                          child: ComposerField(
                            label: 'BUDGET',
                            child: AppTextField(
                              controller: _budgetController,
                              hintText: '500',
                              prefixText: '₹',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
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
                        ),
                        FadeSlideIn(
                          index: 3,
                          child: ComposerField(
                            label: 'PHOTO',
                            child: PhotoUploadTile(
                              image: _pickedImage,
                              onPick: _showImageSourceSheet,
                              onRemove: _removeImage,
                            ),
                          ),
                        ),
                        FadeSlideIn(
                          index: 4,
                          child: ComposerField(
                            label: 'HOW URGENT',
                            child: PriorityRow(
                              priority: _priority,
                              onTap: _pickPriority,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your number stays hidden until you accept an '
                          'offer.',
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
          enabled: state.isFormValid,
          // The upload belongs to the posts page, not this form: posting
          // replaces the form with the board, which shows the post's
          // progress banner while it uploads.
          onPost: () => GoRouter.of(context).pushReplacementAppRoute(
            AppRoutes.posts,
            // The board reads everything it opens with out of one
            // [PostsArgs]; handing it a bare draft leaves it unrecognised,
            // and the upload banner and the locality bar both go missing.
            extra: PostsArgs(
              draft: state.toDraft(
                isInstant: true,
                username: _signedInUsername,
              ),
              localityName: widget.localityName,
            ),
          ),
        ),
      ),
    );
  }
}
