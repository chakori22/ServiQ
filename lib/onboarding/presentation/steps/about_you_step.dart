import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../components/primary_button.dart';
import '../../../components/textfield.dart';
import '../../../core/app_color.dart';
import '../../bloc/onboarding_bloc.dart';
import '../components/onboarding_chrome.dart';

/// Step 2 — name and locality on one screen.
class AboutYouStep extends StatefulWidget {
  const AboutYouStep({super.key, required this.onSkip});

  final VoidCallback onSkip;

  @override
  State<AboutYouStep> createState() => _AboutYouStepState();
}

class _AboutYouStepState extends State<AboutYouStep> {
  late final TextEditingController _nameController;
  late final TextEditingController _localityController;

  @override
  void initState() {
    super.initState();
    // Seeded from the bloc so stepping back and forward again does not wipe
    // what was already typed.
    final profile = context.read<OnboardingBloc>().state.profile;
    _nameController = TextEditingController(text: profile.fullName);
    _localityController = TextEditingController(text: profile.locality);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _localityController.dispose();
    super.dispose();
  }

  void _detectLocation() {
    // TODO(location): wire up a geolocation + reverse-geocoding lookup and
    // fill the field from it. Until then this says so rather than silently
    // doing nothing or filling in a guess.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            "Detecting your location isn't available yet — type your area for "
            'now.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<OnboardingBloc>();
    final state = context.watch<OnboardingBloc>().state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const OnboardingStepTitle(title: 'A little about you'),
        const SizedBox(height: 24),
        AppTextField(
          controller: _nameController,
          labelText: 'YOUR NAME',
          hintText: 'e.g. Priya Sharma',
          keyboardType: TextInputType.name,
          borderColor: AppColor.authAccent,
          enabledLabelColor: AppColor.authTextSecondary,
          onChanged: (value) => bloc.add(FullNameChanged(value)),
        ),
        const SizedBox(height: 20),
        AppTextField(
          controller: _localityController,
          labelText: 'WHERE YOU LIVE',
          hintText: 'Area or society',
          keyboardType: TextInputType.streetAddress,
          borderColor: AppColor.authAccent,
          enabledLabelColor: AppColor.authTextSecondary,
          prefixIcon: const Icon(
            Icons.location_on,
            size: 20,
            color: AppColor.authAccent,
          ),
          suffixIcon: TextButton(
            onPressed: _detectLocation,
            child: const Text(
              'Detect',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColor.authLink,
              ),
            ),
          ),
          onChanged: (value) => bloc.add(LocalityChanged(value)),
        ),
        const SizedBox(height: 12),
        const Text(
          'No phone number needed — we already have it from sign-in.',
          style: TextStyle(fontSize: 12.5, color: AppColor.authTextSecondary),
        ),
        const SizedBox(height: 28),
        PrimaryButton(
          label: state.primaryActionLabel,
          enabled: state.canAdvance,
          isLoading: state.isSubmitting,
          gradient: true,
          onPressed: () => bloc.add(const OnboardingSubmitted()),
        ),
        const SizedBox(height: 6),
        OnboardingFootnoteLink(
          label: 'I will do this later',
          onTap: widget.onSkip,
        ),
      ],
    );
  }
}
