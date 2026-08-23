import 'package:flutter/material.dart';
import 'package:local_markerplace/app_color.dart';

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
      body: ClipPath(
        clipper: BottomCurveClipper(),
        child: Container(
          height: 250,
          color: AppColor.indicativeBlueColor300,
          child: Column(children: [
            
          ],),
        ),
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
