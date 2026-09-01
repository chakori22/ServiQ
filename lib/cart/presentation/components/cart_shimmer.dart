import 'package:flutter/material.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:shimmer/shimmer.dart';

/// Placeholder for the cart while its lines, availability and address load.
///
/// Mirrors the real layout — tabs, review card, coupons row, two detail
/// cards — so the page does not jump when the data arrives.
class CartShimmer extends StatelessWidget {
  const CartShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColor.indicativeBlueColor100,
      highlightColor: AppColor.indicativeBlueColor50,
      child: const SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 24),
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ShimmerBlock(height: 54, radius: 28),
            SizedBox(height: 20),
            _ShimmerBlock(height: 20, width: 160),
            SizedBox(height: 12),
            _ShimmerBlock(height: 220),
            SizedBox(height: 16),
            _ShimmerBlock(height: 56),
            SizedBox(height: 24),
            _ShimmerBlock(height: 20, width: 140),
            SizedBox(height: 12),
            _ShimmerBlock(height: 150),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBlock extends StatelessWidget {
  const _ShimmerBlock({required this.height, this.width, this.radius = 16});

  final double height;
  final double? width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
