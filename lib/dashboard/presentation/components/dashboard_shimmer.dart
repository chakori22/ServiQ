import 'package:flutter/material.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer placeholders for the dashboard's three horizontal card rails.
///
/// Each placeholder mirrors the real card's size and padding so nothing shifts
/// when the data lands — same rail height, same card width, same insets.

/// Wraps [child] in the app's shimmer sweep. One sweep across a whole rail
/// reads better than each card animating on its own.
class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColor.indicativeBlueColor100,
      highlightColor: AppColor.indicativeBlueColor50,
      child: child,
    );
  }
}

/// A single rounded placeholder standing in for a card.
class ShimmerCardBox extends StatelessWidget {
  const ShimmerCardBox({super.key, this.padding = EdgeInsets.zero});

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

/// Horizontal rail of placeholder cards, sized to match the real rail.
class _ShimmerRail extends StatelessWidget {
  const _ShimmerRail({
    required this.height,
    required this.itemWidth,
    required this.itemCount,
    required this.itemPadding,
  });

  final double height;
  final double itemWidth;
  final int itemCount;
  final EdgeInsets itemPadding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: DashboardShimmer(
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          // Placeholders shouldn't scroll — there is nothing to reach.
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          itemCount: itemCount,
          itemBuilder: (context, index) =>
              SizedBox(width: itemWidth, child: ShimmerCardBox(padding: itemPadding)),
        ),
      ),
    );
  }
}

/// Placeholder for the "Services Near Me" rail (matches [ServiceCard]).
class ServiceCardsShimmer extends StatelessWidget {
  const ServiceCardsShimmer({super.key, this.itemCount = 5});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return _ShimmerRail(
      height: 208,
      itemWidth: 174,
      itemCount: itemCount,
      itemPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}

/// Placeholder for the "Posts" rail (matches [DashboardPostCard]).
class PostCardsShimmer extends StatelessWidget {
  const PostCardsShimmer({super.key, this.itemCount = 3});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return _ShimmerRail(
      height: 304,
      itemWidth: 380,
      itemCount: itemCount,
      itemPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

/// Placeholder for the "Your Posts" section (matches [DashboardYourPostCard]).
///
/// The section header is drawn for real rather than shimmered, so the heading
/// doesn't pop in once the posts arrive.
class YourPostCardsShimmer extends StatelessWidget {
  const YourPostCardsShimmer({super.key, this.itemCount = 3});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 16),
          child: Text(
            'Your Posts',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColor.neutralGreyColor700,
              fontSize: 24,
            ),
          ),
        ),
        _ShimmerRail(
          height: 328,
          itemWidth: 380,
          itemCount: itemCount,
          itemPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ],
    );
  }
}

/// Vertical placeholder list for the full Your Posts page.
///
/// Mirrors the card's own stack — avatar and name row, image, description
/// line, footer line — so the page doesn't reflow when the posts arrive.
class YourPostListShimmer extends StatelessWidget {
  const YourPostListShimmer({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return DashboardShimmer(
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: itemCount,
        itemBuilder: (context, index) => const _YourPostSkeleton(),
      ),
    );
  }
}

class _YourPostSkeleton extends StatelessWidget {
  const _YourPostSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 20, backgroundColor: Colors.white),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _ShimmerLine(width: 120, height: 12),
                  SizedBox(height: 6),
                  _ShimmerLine(width: 80, height: 10),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 12),
          const _ShimmerLine(width: double.infinity, height: 12),
          const SizedBox(height: 6),
          const _ShimmerLine(width: 220, height: 12),
          const SizedBox(height: 12),
          const _ShimmerLine(width: 160, height: 12),
        ],
      ),
    );
  }
}

/// A single rounded bar standing in for a line of text.
class _ShimmerLine extends StatelessWidget {
  const _ShimmerLine({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// Placeholder tile for the services grid on the full Services page.
class ServiceGridShimmerTile extends StatelessWidget {
  const ServiceGridShimmerTile({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardShimmer(
      child: ShimmerCardBox(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
