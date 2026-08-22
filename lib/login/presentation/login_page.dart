import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:local_markerplace/app_color.dart';
import 'package:local_markerplace/components/primary_button.dart';
import 'package:local_markerplace/components/textfield.dart';
import '../bloc/login_bloc.dart';
import '../repository/login_repository.dart';

const _carouselImages = [
  'assets/images/serviq_login_illustration.svg',
  'assets/images/serviq_browse_marketplace.svg',
  'assets/images/serviq_trusted_providers.svg',
  'assets/images/serviq_booking_confirmed.svg',
];

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(loginRepository: const LoginRepository()),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    final sheetHeight = screenHeight * 0.4;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        child: Stack(
          children: [
            // Only fills the space above the sheet's resting position so the
            // carousel isn't hidden behind it; it still gets covered while the
            // sheet rises over the keyboard, keeping the carousel animating.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: sheetHeight,
              child: Column(
                children: [
                  const SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Column(
                        children: [
                          Text(
                            'ServiQ',
                            style: TextStyle(
                              color: AppColor.indicativeBlueColor600,
                              fontSize: 40,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Local Marketplace',
                            style: TextStyle(
                              color: AppColor.indicativeBlueColor500,
                              fontSize: 20,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Expanded(
                    child: _ImageCarousel(images: _carouselImages),
                  ),
                ],
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              left: 0,
              right: 0,
              bottom: keyboardInset,
              height: sheetHeight,
              child: const _MobileLoginSheet(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageCarousel extends StatefulWidget {
  const _ImageCarousel({required this.images});

  final List<String> images;

  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  final _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _advancePage());
  }

  void _advancePage() {
    if (!_pageController.hasClients) return;
    final nextPage = (_currentPage + 1) % widget.images.length;
    _pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: SvgPicture.asset(
                  widget.images[index],
                  fit: BoxFit.contain,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < widget.images.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: i == _currentPage ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i == _currentPage
                      ? AppColor.indicativeBlueColor200
                      : AppColor.neutralGreyColor100,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _MobileLoginSheet extends StatefulWidget {
  const _MobileLoginSheet();

  @override
  State<_MobileLoginSheet> createState() => _MobileLoginSheetState();
}

class _MobileLoginSheetState extends State<_MobileLoginSheet> {
  final _mobileController = TextEditingController();
  late final _termsRecognizer = TapGestureRecognizer()
    ..onTap = () => _showPlaceholder('Terms & Conditions');
  late final _privacyRecognizer = TapGestureRecognizer()
    ..onTap = () => _showPlaceholder('Privacy policy');

  void _showPlaceholder(String label) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(label)));
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: BoxDecoration(
        color: AppColor.indicativeBlueColor50,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: BlocBuilder<LoginBloc, LoginState>(
          builder: (context, state) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    'Log in with your number',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _mobileController,
                    hintText: 'xxxxx xxxxx',
                    prefixText: '+91  ',
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    enabledLabelColor: AppColor.indicativeBlueColor700,
                    onChanged: (value) {
                      context.read<LoginBloc>().add(MobileNumberChanged(value));
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "We'll send a verification code here",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColor.neutralGreyColor400,
                    ),
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: 'Continue',
                    enabled: state.isMobileNumberValid,
                    isLoading: state.isLoading,
                    onPressed: () {
                      context.read<LoginBloc>().add(const LoginSubmitted());
                    },
                  ),
                  const SizedBox(height: 12),
                  Text.rich(
                    TextSpan(
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColor.neutralGreyColor400,
                      ),
                      children: [
                        const TextSpan(
                          text: 'By clicking "Continue" you accept ',
                        ),
                        TextSpan(
                          text: 'Terms & Conditions',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                            color: AppColor.indicativeBlueColor700,
                          ),
                          recognizer: _termsRecognizer,
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy policy',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                            color: AppColor.indicativeBlueColor700,
                          ),
                          recognizer: _privacyRecognizer,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
