import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:local_markerplace/components/skeleton/skeleton.dart';
import 'package:local_markerplace/basket/app_bottom_bar.dart';
import 'package:local_markerplace/components/motion/entrance.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/dashboard/model/post_details.dart';
import 'package:local_markerplace/dashboard/model/post_status.dart';
import 'package:local_markerplace/dashboard/presentation/posts/bloc/bloc/post_bloc.dart';
import 'package:local_markerplace/dashboard/presentation/posts/presentation/components/requirement_card.dart';
import 'package:local_markerplace/dashboard/presentation/posts/presentation/requirement_page.dart';
import 'package:local_markerplace/dashboard/repository/dashboard_repository.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_filter_chip.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_header.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_tab_bar.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/network/auth_session.dart';

/// Everything the seeker has posted, grouped by where it got to.
///
/// The board answers "what does the area need"; this answers "what did I
/// ask for, and what happened" — which is why it is its own screen rather
/// than a chip on the board.
class MyPostsPage extends StatelessWidget {
  const MyPostsPage({
    super.key,
    this.localityName,
    this.onTabSelected,
    this.onPost,
  });

  final String? localityName;
  final ValueChanged<DiscoveryTab>? onTabSelected;
  final VoidCallback? onPost;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PostBloc(dashboardRepository: const DashboardRepository()),
      child: _MyPostsView(
        localityName: localityName,
        onTabSelected: onTabSelected,
        onPost: onPost,
      ),
    );
  }
}

class _MyPostsView extends StatefulWidget {
  const _MyPostsView({
    required this.localityName,
    required this.onTabSelected,
    required this.onPost,
  });

  final String? localityName;
  final ValueChanged<DiscoveryTab>? onTabSelected;
  final VoidCallback? onPost;

  @override
  State<_MyPostsView> createState() => _MyPostsViewState();
}

class _MyPostsViewState extends State<_MyPostsView> {
  PostStatus _tab = PostStatus.open;

  /// The signed-in handle. Read defensively: the screen is pumped without a
  /// session in tests and previews.
  String? get _signedInUsername {
    try {
      return context.read<AuthSession>().user?.username;
    } on ProviderNotFoundException {
      return null;
    }
  }

  @override
  void initState() {
    context.read<PostBloc>().add(
      OnFetchPostDetails(currentUsername: _signedInUsername),
    );
    super.initState();
  }

  /// Only the seeker's own requirements, whatever the board holds.
  List<PostDetails> _mine(List<PostDetails> all) {
    final me = _signedInUsername;
    return all.where((post) => post.isPostedBy(me)).toList();
  }

  Future<void> _open(PostDetails post) async {
    final bloc = context.read<PostBloc>();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RequirementPage(
          post: post,
          localityName: widget.localityName,
          currentUsername: _signedInUsername,
          onOfferAccepted: (offer) => bloc.add(OnOfferAccepted(post, offer)),
          onOfferMade: (_) => bloc.add(OnOfferMade(post)),
          onClosed: () => bloc.add(OnPostClosed(post)),
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<PostBloc, PostState>(
          builder: (context, state) {
            final mine = _mine(state.postDetails);
            final showing = mine.where((post) => post.status == _tab).toList();

            return Column(
              children: [
                DiscoveryHeader(
                  title: 'My posts',
                  subtitle: state.postsLoading
                      ? null
                      : '${mine.length} '
                            '${mine.length == 1 ? 'requirement' : 'requirements'}',
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      for (final (index, status)
                          in PostStatus.values.indexed) ...[
                        if (index > 0) const SizedBox(width: 8),
                        DiscoveryFilterChip(
                          label: _chipLabel(mine, status),
                          isSelected: _tab == status,
                          onTap: () => setState(() => _tab = status),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColor.discoveryBorder,
                ),
                Expanded(
                  child: state.postsLoading
                      // Never a spinner: the skeleton is the shape of the
                      // posts that are coming.
                      ? const SkeletonList(caption: 'Loading your posts')
                      : showing.isEmpty
                      ? _Nothing(status: _tab, onPost: widget.onPost)
                      : ListView.separated(
                          key: ValueKey(_tab),
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                          itemCount: showing.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) => FadeSlideIn(
                            index: index,
                            child: RequirementCard(
                              post: showing[index],
                              onTap: () => _open(showing[index]),
                            ),
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: widget.onTabSelected == null
          ? null
          : AppBottomBar(
              current: DiscoveryTab.me,
              // The shell returns to itself; popping here too would take it
              // off the stack and leave the app black.
              onSelect: (tab) => widget.onTabSelected!(tab),
              onPost: widget.onPost,
            ),
    );
  }

  /// "Open 2" — the count is what makes the chips worth reading.
  static String _chipLabel(List<PostDetails> mine, PostStatus status) {
    final count = mine.where((post) => post.status == status).length;
    return count == 0 ? status.label : '${status.label}  $count';
  }
}

/// A status with nothing in it, said in that status's own terms.
class _Nothing extends StatelessWidget {
  const _Nothing({required this.status, required this.onPost});

  final PostStatus status;
  final VoidCallback? onPost;

  @override
  Widget build(BuildContext context) {
    final line = switch (status) {
      PostStatus.open =>
        'Nothing open right now. Post what you need and '
            'providers nearby will answer.',
      PostStatus.accepted =>
        'Nothing accepted yet. Take an offer on one of your posts and it '
            'moves here.',
      PostStatus.closed => 'Nothing closed. Posts you take down are kept here.',
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'No ${status.label.toLowerCase()} posts',
              textAlign: TextAlign.center,
              style: DiscoveryText.emptyTitle,
            ),
            const SizedBox(height: 10),
            Text(
              line,
              textAlign: TextAlign.center,
              style: DiscoveryText.caption.copyWith(height: 19 / 12.5),
            ),
            if (status == PostStatus.open && onPost != null) ...[
              const SizedBox(height: 22),
              PressableScale(
                onTap: onPost,
                pressedScale: 0.96,
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [
                        AppColor.discoveryGradientStart,
                        AppColor.discoveryGradientEnd,
                      ],
                    ),
                  ),
                  child: Text(
                    'Post a requirement',
                    style: DiscoveryText.onAccent(15, letterSpacing: -0.15),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
