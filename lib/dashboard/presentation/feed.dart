import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:local_markerplace/app_color.dart';
import 'package:local_markerplace/dashboard/bloc/dashboard_bloc.dart';
import 'package:local_markerplace/dashboard/presentation/components/option_card.dart';
import 'package:local_markerplace/dashboard/presentation/components/dashboard_post.dart';
import 'package:local_markerplace/dashboard/presentation/components/service_card.dart';
import 'package:local_markerplace/dashboard/presentation/components/your_post.dart';
import 'package:local_markerplace/dashboard/presentation/create_post/instant/instant_form.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    context.read<DashboardBloc>().add(const OnFetchPostDetails());
    context.read<DashboardBloc>().add(const OnFetchYourPostDetails());
    context.read<DashboardBloc>().add(const OnFetchServiceDetails());
    // Fetch post details when the widget is initialized
    // You can use a Bloc or any state management solution to fetch the data
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardBloc, DashboardState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            elevation: 2,
            animateColor: true,
            backgroundColor: AppColor.indicativeBlueColor300,
            surfaceTintColor: AppColor.neutralGreyColor100,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                height: 1,
                color: AppColor.white.withOpacity(0.4),
              ),
            ),

            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Home',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColor.white,
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColor.white,
                      ),
                    ],
                  ),
                  //const SizedBox(height: 2),
                  const Text(
                    'Indirapuram Ghaziabad',
                    style: TextStyle(fontSize: 14, color: AppColor.white),
                  ),
                ],
              ),
            ),

            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Icon(
                  Icons.notifications_none_rounded,
                  size: 24,
                  color: AppColor.white,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Icon(
                  Icons.person_outline_rounded,
                  size: 24,
                  color: AppColor.white,
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    ClipPath(
                      clipper: BottomCurveClipper(),
                      child: Container(
                        height: 250,
                        width: double.infinity,

                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColor.indicativeBlueColor300,
                              AppColor.indicativeBlueColor500,
                              AppColor.indicativeBlueColor700,
                            ],
                          ),
                        ),

                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  AnimatedBuilder(
                                    animation: _controller,
                                    builder: (context, child) {
                                      return ShaderMask(
                                        shaderCallback: (bounds) {
                                          final position =
                                              _controller.value * 2 - 1;

                                          return LinearGradient(
                                            begin: Alignment(position - 0.5, 0),
                                            end: Alignment(position + 0.5, 0),
                                            colors: const [
                                              Colors.transparent,
                                              Colors.white54,
                                              Colors.transparent,
                                            ],
                                          ).createShader(bounds);
                                        },
                                        blendMode: BlendMode.srcATop,
                                        child: child,
                                      );
                                    },
                                    child: SvgPicture.asset(
                                      'assets/images/post_tab_person_gold.svg',
                                      width: 120,
                                      height: 180,
                                      fit: BoxFit.contain,
                                    ),
                                  ),

                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Real-time help, right \naround the corner.',
                                        style: TextStyle(
                                          color: AppColor.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          ServiceOptionCard(
                                            title: 'Get Instant\nService',
                                            icon: Icons.bolt_rounded,
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const InstantFormPage(),
                                                ),
                                              );
                                            },
                                          ),

                                          const SizedBox(width: 12),

                                          ServiceOptionCard(
                                            title: 'Schedule for\nLater',
                                            icon: Icons.calendar_month_rounded,
                                            onTap: () {
                                              // Schedule service
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              //   Text(
                              //     'Welcome to Local Marketplace',
                              //     style: Theme.of(context).textTheme.headlineSmall
                              //         ?.copyWith(
                              //           color: AppColor.white,
                              //           fontWeight: FontWeight.w700,
                              //         ),
                              //   ),

                              //   const SizedBox(height: 8),

                              //   Text(
                              //     'Find shops, products and services near you.',
                              //     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              //       color: AppColor.white.withOpacity(0.85),
                              //     ),
                              //   ),

                              //   const SizedBox(height: 20),

                              //   // Search container
                              //   Container(
                              //     height: 52,
                              //     width: double.infinity,
                              //     decoration: BoxDecoration(
                              //       color: AppColor.white,
                              //       borderRadius: BorderRadius.circular(14),
                              //       boxShadow: [
                              //         BoxShadow(
                              //           color: Colors.black.withOpacity(0.08),
                              //           blurRadius: 10,
                              //           offset: const Offset(0, 4),
                              //         ),
                              //       ],
                              //     ),
                              //     child: Row(
                              //       children: [
                              //         const SizedBox(width: 16),

                              //         Icon(
                              //           Icons.search_rounded,
                              //           color: AppColor.neutralGreyColor500,
                              //         ),

                              //         const SizedBox(width: 12),

                              //         Text(
                              //           'Search shops, services...',
                              //           style: TextStyle(
                              //             color: AppColor.neutralGreyColor500,
                              //             fontSize: 14,
                              //           ),
                              //         ),
                              //       ],
                              //     ),
                              //   ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18.0,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Services Near Me',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColor.neutralGreyColor700,
                              fontSize: 24,
                            ),
                          ),
                          AnimatedScale(
                            scale: 1.0,
                            duration: const Duration(milliseconds: 300),
                            child: TextButton(
                              onPressed: () {},
                              child: Row(
                                children: [
                                  Text(
                                    'View All',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColor.indicativeBlueColor400,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 12,
                                    color: AppColor.indicativeBlueColor400,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    state.serviceDetails.isEmpty
                        ? SizedBox.shrink()
                        : SizedBox(
                            height: 208,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              itemCount: state.serviceDetails.length,
                              itemBuilder: (context, index) {
                                final service = state.serviceDetails[index];
                                return SizedBox(
                                  width: 174,
                                  child: ServiceCard(
                                    serviceDetails: service,
                                    index: index,
                                  ),
                                );
                              },
                            ),
                          ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18.0,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Posts',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColor.neutralGreyColor700,
                              fontSize: 24,
                            ),
                          ),
                          AnimatedScale(
                            scale: 1.0,
                            duration: const Duration(milliseconds: 300),
                            child: TextButton(
                              onPressed: () {},
                              child: Row(
                                children: [
                                  Text(
                                    'View All',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColor.indicativeBlueColor400,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 12,
                                    color: AppColor.indicativeBlueColor400,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    DashboardPostCard(
                      postDetailsList: state.filteredPostDetails,
                    ),
                    AnimatedBuilder(
                      builder: (context, child) {
                        return ClipPath(
                          clipper: WavyClipper(phase: _controller.value),
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(
                                    0xFFFDEBE4,
                                  ), // Very light soft skin tone (Top)
                                  Color(0xFFFFF8F5),
                                  // Lighter pink/white towards the bottom
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            child: YourPostCard(
                              postDetailsList: state.yourPostDetails,
                            ),
                          ),
                        );
                      },
                      animation: _controller,
                    ),
                    // YourPostCard(postDetailsList: state.yourPostDetails),
                  ],
                ),
              ),
              if (state.selectedServicesCount > 0)
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 8,
                  child: _CartSummaryBar(state: state),
                ),
            ],
          ),

          // /
        );
      },
    );
  }
}

class _CartSummaryBar extends StatelessWidget {
  final DashboardState state;

  const _CartSummaryBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final firstSelected = state.selectedServices.first;

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(8),
        height: 60,
        decoration: BoxDecoration(
          color: AppColor.indicativeBlueColor100,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 40,
                height: 40,
                color: AppColor.white,
                child: Center(
                  child: SvgPicture.asset(
                    firstSelected.imageUrl,
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${state.selectedServicesCount} ${state.selectedServicesCount > 1 ? 'services' : 'service'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColor.neutralGreyColor700,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    state.selectedServicesSummary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColor.neutralGreyColor500,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              // TODO: navigate to the cart page once it exists.
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.indicativeBlueColor400,
                foregroundColor: AppColor.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Go to cart',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WavyClipper extends CustomClipper<Path> {
  final double phase; // Ranges from 0.0 to 1.0

  WavyClipper({required this.phase});

  @override
  Path getClip(Size size) {
    final path = Path();

    // Increased amplitude from 10 to 22.0 for taller wave height
    const double amplitude = 4.0;
    const double waveCount =
        8.0; // Number of waves visible across the screen width

    final double frequency = (2 * pi * waveCount) / size.width;

    // Multiplied by 2*pi to ensure a seamless loop from 0 to 1
    final double phaseShift = phase * 2 * pi;

    // Move to starting point on the left (- phaseShift moves wave right)
    path.moveTo(0, amplitude * sin(-phaseShift) + amplitude);

    // Draw the sine wave across the width of the screen
    for (double x = 0; x <= size.width; x++) {
      // Changed + phaseShift to - phaseShift to shift direction to the right
      double y = amplitude * sin(frequency * x - phaseShift) + amplitude;
      path.lineTo(x, y);
    }

    // Complete the path block by drawing down to the bottom corners
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(WavyClipper oldClipper) => oldClipper.phase != phase;
}

class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Start from top-left
    path.lineTo(0, size.height - 30);

    // Small curve
    path.quadraticBezierTo(
      size.width * 0.10,
      size.height - 5,
      size.width * 0.20,
      size.height - 30,
    );

    // Big curve
    path.quadraticBezierTo(
      size.width * 0.35,
      size.height - 80,
      size.width * 0.50,
      size.height - 30,
    );

    // Small curve
    path.quadraticBezierTo(
      size.width * 0.58,
      size.height - 5,
      size.width * 0.66,
      size.height - 30,
    );

    // Big curve
    path.quadraticBezierTo(
      size.width * 0.82,
      size.height - 80,
      size.width,
      size.height - 30,
    );

    // Right side
    path.lineTo(size.width, 0);

    // Close
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
