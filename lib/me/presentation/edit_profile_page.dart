import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:local_markerplace/components/primary_button.dart';
import 'package:local_markerplace/components/textfield.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_assets.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_filter_chip.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_header.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/me/bloc/edit_profile_bloc.dart';
import 'package:local_markerplace/me/model/seeker_account.dart';
import 'package:local_markerplace/onboarding/model/seeker_profile.dart';

/// 02 · Edit profile.
///
/// The phone is shown but locked: it is how the seeker signs in, so changing
/// it is a different flow entirely and the field says so rather than
/// pretending to be editable.
class EditProfilePage extends StatelessWidget {
  const EditProfilePage({
    super.key,
    required this.account,
    this.onSave,
    this.onChangePhoto,
    this.onPickLocality,
  });

  final SeekerAccount account;

  /// Handed the edited name and the chosen interests.
  final void Function(String name, Set<String> interests)? onSave;

  final VoidCallback? onChangePhoto;
  final VoidCallback? onPickLocality;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EditProfileBloc()..add(EditProfileOpened(account)),
      child: _EditProfileView(
        account: account,
        onSave: onSave,
        onChangePhoto: onChangePhoto,
        onPickLocality: onPickLocality,
      ),
    );
  }
}

class _EditProfileView extends StatefulWidget {
  const _EditProfileView({
    required this.account,
    required this.onSave,
    required this.onChangePhoto,
    required this.onPickLocality,
  });

  final SeekerAccount account;
  final void Function(String name, Set<String> interests)? onSave;
  final VoidCallback? onChangePhoto;
  final VoidCallback? onPickLocality;

  @override
  State<_EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<_EditProfileView> {
  /// The controller belongs to the field; what has been typed belongs to the
  /// bloc, which is told on every change.
  late final TextEditingController _name = TextEditingController(
    text: widget.account.name,
  );

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditProfileBloc>().state;

    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const DiscoveryHeader(title: 'Edit profile'),
            const SizedBox(height: 6),
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColor.discoveryBorder,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: widget.onChangePhoto,
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(21.6),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColor.discoveryAvatarTop,
                                  AppColor.discoveryAvatarBottom,
                                ],
                              ),
                            ),
                            child: Text(
                              widget.account.initials,
                              style: DiscoveryText.avatarInitials(24.48),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Change photo',
                            style: DiscoveryText.inlineLink.copyWith(
                              fontSize: 13,
                              letterSpacing: -0.13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text('NAME', style: DiscoveryText.fieldLabel),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: _name,
                    onChanged: (value) => context.read<EditProfileBloc>().add(
                      ProfileNameChanged(value),
                    ),
                    fillColor: AppColor.white,
                    borderColor: AppColor.discoveryAccent,
                    borderWidth: 1.8,
                    cornerRadius: 16,
                    verticalPadding: 17,
                    textStyle: DiscoveryText.fieldInput,
                  ),
                  const SizedBox(height: 20),
                  Text('PHONE', style: DiscoveryText.fieldLabel),
                  const SizedBox(height: 8),
                  Container(
                    height: 56,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColor.discoveryTint,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColor.discoveryBorder,
                        width: 1.4,
                      ),
                    ),
                    child: Text(
                      widget.account.phone,
                      style: DiscoveryText.fieldLocked,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Phone is how you sign in and cannot be changed here',
                    style: DiscoveryText.smallPrint.copyWith(
                      color: AppColor.discoveryTextTertiary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('HOME LOCALITY', style: DiscoveryText.fieldLabel),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: widget.onPickLocality,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColor.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColor.discoveryAccent,
                          width: 1.8,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.account.localityName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: DiscoveryText.fieldInput,
                            ),
                          ),
                          SvgPicture.asset(
                            DiscoveryAssets.caretDown,
                            width: 9.7,
                            height: 5.7,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('INTERESTS', style: DiscoveryText.fieldLabel),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final interest in seekerServiceInterests)
                        DiscoveryFilterChip(
                          label: interest.label,
                          isSelected: state.interests.contains(interest.label),
                          onTap: () => context.read<EditProfileBloc>().add(
                            InterestToggled(interest.label),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    label: 'Save changes',
                    enabled: state.canSave,
                    gradient: true,
                    height: 56,
                    gradientColors: const [
                      AppColor.discoveryGradientStart,
                      AppColor.discoveryGradientEnd,
                    ],
                    labelStyle: DiscoveryText.onAccent(
                      16.5,
                      letterSpacing: -0.165,
                    ),
                    onPressed: () {
                      widget.onSave?.call(state.name.trim(), state.interests);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
