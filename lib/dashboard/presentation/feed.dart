import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:local_markerplace/app_color.dart';
import 'package:local_markerplace/dashboard/presentation/components/option_card.dart';
import 'package:local_markerplace/dashboard/presentation/components/post.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        animateColor: true,
        backgroundColor: AppColor.indicativeBlueColor300,
        surfaceTintColor: AppColor.neutralGreyColor100,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColor.white.withOpacity(0.4)),
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
            child: CircleAvatar(
              backgroundColor: AppColor.neutralGreyColor100,
              radius: 18,
              child: Icon(
                Icons.notifications_none_rounded,
                size: 22,
                color: AppColor.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: AppColor.neutralGreyColor100,
              radius: 18,
              child: Icon(
                Icons.person_outline_rounded,
                size: 22,
                color: AppColor.white,
              ),
            ),
          ),
        ],
      ),
      body: Column(
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
                  horizontal: 12,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SvgPicture.asset(
                          'assets/images/post_tab_person_gold.svg',
                          width: 120,
                          height: 180,
                          fit: BoxFit.contain,
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
                                    // Instant service
                                  },
                                ),

                                const SizedBox(width: 16),

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
          PostCard(),
        ],
      ),
    );
  }
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
