import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:local_markerplace/components/motion/entrance.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/core/app_routes.dart';
import 'package:local_markerplace/dashboard/presentation/components/dashboard_shimmer.dart';
import 'package:local_markerplace/dashboard/repository/dashboard_repository.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_header.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/me/presentation/components/me_components.dart';

import '../bloc/your_post_bloc.dart';
import 'your_post_card.dart';

/// Full list behind "View All" on the dashboard's Your Posts rail.
///
/// The rail shows a horizontal preview; this page stacks the same requirement
/// cards the public board draws, with the owner's edit and delete actions on
/// each.
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

  void _notice(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: DiscoveryText.heroSubtitle.copyWith(color: AppColor.white),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<YourPostBloc, YourPostState>(
          builder: (context, state) {
            final posts = state.yourPostDetails;

            return Column(
              children: [
                DiscoveryHeader(
                  title: 'Your posts',
                  subtitle: state.yourPostsLoading
                      ? null
                      : '${posts.length} '
                            '${posts.length == 1 ? 'post' : 'posts'}',
                ),
                const SizedBox(height: 14),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColor.discoveryBorder,
                ),
                const SizedBox(height: 16),
                Expanded(child: _body(context, state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _body(BuildContext context, YourPostState state) {
    if (state.yourPostsLoading) return const YourPostListShimmer();
    if (state.isEmpty) return const _EmptyYourPosts();

    return RefreshIndicator(
      color: AppColor.discoveryAccent,
      onRefresh: () async {
        context.read<YourPostBloc>().add(const OnFetchPostDetails());
      },
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        itemCount: state.yourPostDetails.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final post = state.yourPostDetails[index];
          return YourPostCard(
            post: post.copyWith(isExpanded: _expandedPosts.contains(index)),
            index: index,
            onToggleExpanded: () => _toggleExpanded(index),
            onEdit: () => _notice('Editing a post — coming soon.'),
            onDelete: () => _notice('Deleting a post — coming soon.'),
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
        child: FadeSlideIn(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColor.discoveryTint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.post_add_rounded,
                  size: 40,
                  color: AppColor.discoveryAccent,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                "You haven't posted anything yet",
                textAlign: TextAlign.center,
                style: DiscoveryText.sectionTitle,
              ),
              const SizedBox(height: 8),
              Text(
                'Post a requirement and providers around you can answer it.',
                textAlign: TextAlign.center,
                style: DiscoveryText.footnoteStrong.copyWith(height: 18 / 12),
              ),
              const SizedBox(height: 26),
              OutlinedActionButton(
                label: 'Post a requirement',
                leading: const Icon(
                  Icons.bolt_rounded,
                  size: 18,
                  color: AppColor.discoveryGradientEnd,
                ),
                onTap: () =>
                    GoRouter.of(context).pushAppRoute(AppRoutes.instantForm),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
