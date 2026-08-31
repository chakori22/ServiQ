import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/core/app_routes.dart';
import 'package:local_markerplace/dashboard/presentation/components/dashboard_shimmer.dart';
import 'package:local_markerplace/dashboard/repository/dashboard_repository.dart';

import '../bloc/your_post_bloc.dart';
import 'your_post_card.dart';

/// Full list behind "View All" on the dashboard's Your Posts rail.
///
/// The rail shows a horizontal preview; this page stacks the same cards
/// vertically so every post is reachable, with edit/delete actions per card.
class YourPostPage extends StatelessWidget {
  const YourPostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          YourPostBloc(dashboardRepository: const DashboardRepository())
            ..add(const OnFetchPostDetails()),
      child: const YourPostView(),
    );
  }
}

class YourPostView extends StatefulWidget {
  const YourPostView({super.key});

  @override
  State<YourPostView> createState() => _YourPostViewState();
}

class _YourPostViewState extends State<YourPostView> {
  /// Which cards the user has expanded, by list position. Kept here rather
  /// than in the bloc: it's view state, and it survives refetches without the
  /// bloc having to carry it.
  final Set<int> _expandedPosts = <int>{};

  void _toggleExpanded(int index) {
    setState(() {
      if (!_expandedPosts.remove(index)) _expandedPosts.add(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: AppBar(
        elevation: 2,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            color: AppColor.indicativeBlueColor700,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        backgroundColor: AppColor.indicativeBlueColor50,
        surfaceTintColor: AppColor.neutralGreyColor100,
        title: const Text(
          'Your Posts',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColor.indicativeBlueColor700,
          ),
        ),
      ),
      body: BlocBuilder<YourPostBloc, YourPostState>(
        builder: (context, state) {
          if (state.yourPostsLoading) {
            return const YourPostListShimmer();
          }
          if (state.isEmpty) {
            return const _EmptyYourPosts();
          }
          return RefreshIndicator(
            color: AppColor.indicativeBlueColor600,
            onRefresh: () async {
              context.read<YourPostBloc>().add(const OnFetchPostDetails());
            },
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: state.yourPostDetails.length,
              separatorBuilder: (context, index) => Divider(
                height: 32,
                thickness: 1,
                color: AppColor.neutralGreyColor100,
              ),
              itemBuilder: (context, index) {
                final post = state.yourPostDetails[index];
                return YourPostCard(
                  post: post.copyWith(
                    isExpanded: _expandedPosts.contains(index),
                  ),
                  onToggleExpanded: () => _toggleExpanded(index),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// Shown when the user hasn't posted anything yet — a dead end otherwise,
/// so it offers the way to create one.
class _EmptyYourPosts extends StatelessWidget {
  const _EmptyYourPosts();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColor.indicativeBlueColor50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.post_add_rounded,
                size: 48,
                color: AppColor.indicativeBlueColor400,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "You haven't posted anything yet",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColor.neutralGreyColor700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Post a request and helpers around you can respond to it.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColor.neutralGreyColor500,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColor.indicativeBlueColor600,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
              ),
              onPressed: () =>
                  GoRouter.of(context).pushAppRoute(AppRoutes.instantForm),
              icon: const Icon(Icons.bolt_rounded),
              label: const Text('Post a request'),
            ),
          ],
        ),
      ),
    );
  }
}
