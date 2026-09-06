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
          itemBuilder: (context, index) => SizedBox(
            width: itemWidth,
            child: ShimmerCardBox(padding: itemPadding),
          ),
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
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (context, index) =>
            const _RequirementSkeleton(hasActions: true),
      ),
    );
  }
}

/// Placeholder for the posts board, which stacks the same requirement cards
/// without the owner's edit and delete actions.
class RequirementBoardShimmer extends StatelessWidget {
  const RequirementBoardShimmer({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return DashboardShimmer(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (context, index) => const _RequirementSkeleton(),
      ),
    );
  }
}

/// One requirement card, drawn as blank bars.
///
/// Kept to the real card's radius, padding and rhythm so nothing jumps when
/// the posts land.
class _RequirementSkeleton extends StatelessWidget {
  const _RequirementSkeleton({this.hasActions = false});

  /// Your Posts adds an Edit / Delete row under the footer.
  final bool hasActions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14.6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: _ShimmerLine(width: 200, height: 15)),
              const SizedBox(width: 10),
              Container(
                width: 60,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _ShimmerLine(width: 180, height: 12),
          const SizedBox(height: 18),
          const _ShimmerLine(width: double.infinity, height: 1),
          const SizedBox(height: 12),
          const Row(
            children: [
              _ShimmerLine(width: 70, height: 12),
              Spacer(),
              _ShimmerLine(width: 60, height: 11),
            ],
          ),
          if (hasActions) ...[
            const SizedBox(height: 16),
            const Row(
              children: [
                _ShimmerLine(width: 62, height: 30),
                SizedBox(width: 10),
                _ShimmerLine(width: 74, height: 30),
              ],
            ),
          ],
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
