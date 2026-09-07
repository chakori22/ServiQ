import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:local_markerplace/components/skeleton/skeleton.dart';
import 'package:local_markerplace/components/motion/entrance.dart';
import 'package:local_markerplace/basket/app_bottom_bar.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/core/app_routes.dart';
import 'package:local_markerplace/dashboard/model/post_details.dart';
import 'package:local_markerplace/dashboard/model/post_draft.dart';
import 'package:local_markerplace/dashboard/presentation/posts/presentation/components/requirement_card.dart';
import 'package:local_markerplace/dashboard/presentation/posts/presentation/requirement_page.dart';
import 'package:local_markerplace/dashboard/presentation/posts/presentation/components/post_upload_banner.dart';
import 'package:local_markerplace/dashboard/repository/dashboard_repository.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_assets.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_tab_bar.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_filter_chip.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_note.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/network/auth_session.dart';
import 'package:local_markerplace/notifications/presentation/notifications_sheet.dart';
import 'package:local_markerplace/notifications/repository/notification_repository.dart';

import '../bloc/bloc/post_bloc.dart';

/// How the board can be narrowed. All three stay on the board and swap the
/// list underneath; none of them leaves the screen.
enum BoardFilter { all, open, mine }

/// What the posts route is opened with.
///
/// The board is reached from several places that each know something
/// different — the composer knows the draft it just built, discovery knows
/// the area, Me knows the seeker wants their own — so they travel together
/// rather than fighting over a single `extra`.
class PostsArgs {
  const PostsArgs({
    this.draft,
    this.localityName,
    this.initialFilter = BoardFilter.all,
  });

  /// A post that has just been shared and still has to be uploaded.
  final PostDraft? draft;

  /// The area whose board this is.
  final String? localityName;

  /// Which chip is on when the board opens.
  final BoardFilter initialFilter;
}

class PostPage extends StatelessWidget {
  const PostPage({
    super.key,
    this.uploadingDraft,
    this.localityName,
    this.initialFilter = BoardFilter.all,
  });

  /// Set when the page was opened straight from a create-post form: the post
  /// the user just shared, whose upload this page runs and reports on.
  final PostDraft? uploadingDraft;

  /// The area whose board this is, shown in the locality bar. Null where the
  /// caller does not know it — a deep link, or a test — in which case the bar
  /// is left off rather than naming somewhere the user is not.
  final String? localityName;

  /// Which chip the board opens on. Me sends the seeker straight to their
  /// own requirements rather than to a screen of everybody's.
  final BoardFilter initialFilter;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PostBloc(dashboardRepository: const DashboardRepository()),
      child: PostScreenContainer(
        uploadingDraft: uploadingDraft,
        localityName: localityName,
        initialFilter: initialFilter,
      ),
    );
  }
}

/// 09 · 01 — the requirements board: what people nearby need done.
class PostScreenContainer extends StatefulWidget {
  const PostScreenContainer({
    super.key,
    this.uploadingDraft,
    this.localityName,
    this.initialFilter = BoardFilter.all,
  });

  final PostDraft? uploadingDraft;
  final String? localityName;
  final BoardFilter initialFilter;

  @override
  State<PostScreenContainer> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreenContainer> {
  late BoardFilter _filter = widget.initialFilter;

  @override
  void initState() {
    context.read<PostBloc>().add(
      OnFetchPostDetails(currentUsername: _signedInUsername),
    );
    final draft = widget.uploadingDraft;
    if (draft != null) {
      context.read<PostBloc>().add(OnStartPostUpload(draft));
    }
    super.initState();
  }

  /// Opens the drawer, then refreshes so the bell's badge agrees with what
  /// was just read in it.
  Future<void> _openNotifications() async {
    await showNotificationsSheet(context);
    if (mounted) setState(() {});
  }

  /// Opens one requirement. If its own tab bar is used to leave, the tab it
  /// popped with is passed on up to the shell.
  Future<void> _openRequirement(PostDetails post) async {
    final bloc = context.read<PostBloc>();
    final next = await Navigator.of(context).push<DiscoveryTab>(
      MaterialPageRoute(
        builder: (_) => RequirementPage(
          post: post,
          localityName: widget.localityName,
          currentUsername: _signedInUsername,
          onOfferMade: (_) => bloc.add(OnOfferMade(post)),
          onOfferAccepted: (offer) => bloc.add(OnOfferAccepted(post, offer)),
        ),
      ),
    );
    if (!mounted || next == null) return;
    if (context.mounted) Navigator.of(context).pop(next);
  }

  void _selectFilter(BoardFilter filter) => setState(() => _filter = filter);

  /// The signed-in user's handle, which is what a post records as its
  /// author. Null where no session is in the tree — a preview, or a widget
  /// test pumping this screen on its own — and then nothing is "mine".
  String? get _signedInUsername {
    try {
      return context.read<AuthSession>().user?.username;
    } on ProviderNotFoundException {
      return null;
    }
  }

  List<PostDetails> _visible(List<PostDetails> posts) {
    switch (_filter) {
      case BoardFilter.open:
        return posts.where((post) => !post.isAccepted).toList();
      case BoardFilter.mine:
        final me = _signedInUsername;
        if (me == null) return const [];
        return posts.where((post) => post.username == me).toList();
      case BoardFilter.all:
        return posts;
    }
  }

  /// What to say when a filter leaves nothing behind. Each one has its own
  /// reason for being empty, and "nothing here" would explain none of them.
  String get _emptyMessage => switch (_filter) {
    BoardFilter.open => 'Every requirement here has been accepted.',
    BoardFilter.mine => "You haven't posted anything here yet.",
    BoardFilter.all => 'Nothing on the board yet — post the first requirement.',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        bottom: false,
        child: BlocConsumer<PostBloc, PostState>(
          listenWhen: (previous, current) =>
              current.errorMessage.isNotEmpty &&
              previous.errorMessage != current.errorMessage,
          listener: (context, state) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    state.errorMessage,
                    style: DiscoveryText.heroSubtitle.copyWith(
                      color: AppColor.white,
                    ),
                  ),
                ),
              );
            context.read<PostBloc>().add(const OnDismissAlertMessage());
          },
          builder: (context, state) {
            final posts = _visible(state.postDetails);

            return Column(
              children: [
                _BoardHeader(
                  localityName: widget.localityName,
                  unreadNotifications:
                      NotificationRepository.shared.unreadCount,
                  onNotifications: _openNotifications,
                ),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColor.discoveryBorder,
                ),
                if (state.uploadingDraft != null)
                  PostUploadBanner(
                    draft: state.uploadingDraft!,
                    progress: state.uploadProgress,
                    progressText: state.uploadProgressText,
                  ),
                const SizedBox(height: 16),
                FadeSlideIn(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'What people need here',
                          style: DiscoveryText.meName,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Answer one, or post your own',
                          style: DiscoveryText.footnoteStrong,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _BoardFilters(current: _filter, onSelect: _selectFilter),
                const SizedBox(height: 16),
                Expanded(
                  child: state.postsLoading
                      ? const SkeletonList(caption: 'Loading what people need')
                      : posts.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: DiscoveryNote(_emptyMessage),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          itemCount: posts.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 14),
                          itemBuilder: (context, index) => RequirementCard(
                            post: posts[index],
                            index: index,
                            onTap: () => _openRequirement(posts[index]),
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
      // The design draws the board as a tab, with the flow's bar under it and
      // the post button riding its edge. It is reached by a push rather than
      // by the shell swapping tabs, so leaving by any other tab pops back and
      // tells the shell which one to show.
      bottomNavigationBar: AppBottomBar(
        current: DiscoveryTab.posts,
        onSelect: (tab) {
          if (tab == DiscoveryTab.posts) return;
          Navigator.of(context).pop(tab);
        },
        onPost: () => GoRouter.of(
          context,
        ).pushAppRoute(AppRoutes.instantForm, extra: widget.localityName),
      ),
    );
  }
}

/// The board's top bar: the area it covers, and notifications.
///
/// The design draws this as a locality bar with no back affordance, because
/// there it is a tab. Here the board is pushed on top of whatever opened it,
/// so it keeps the app's back control on the left.
class _BoardHeader extends StatelessWidget {
  const _BoardHeader({
    required this.localityName,
    required this.unreadNotifications,
    required this.onNotifications,
  });

  final String? localityName;
  final int unreadNotifications;
  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    final locality = localityName;

    return SizedBox(
      height: 52,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Row(
          children: [
            if (locality == null)
              Expanded(child: Text('Posts', style: DiscoveryText.appBarTitle))
            else ...[
              SvgPicture.asset(
                DiscoveryAssets.pinHeader,
                width: 14,
                height: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  locality,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DiscoveryText.rowTitle.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
            const SizedBox(width: 10),
            _BellButton(
              badgeCount: unreadNotifications,
              onTap: onNotifications,
            ),
          ],
        ),
      ),
    );
  }
}

/// The notification bell and its unread count.
class _BellButton extends StatelessWidget {
  const _BellButton({required this.badgeCount, required this.onTap});

  final int badgeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      pressedScale: 0.88,
      onTap: onTap,
      child: SizedBox(
        width: 34,
        height: 34,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              top: 3,
              child: SvgPicture.asset(
                DiscoveryAssets.bell,
                width: 30,
                height: 30,
              ),
            ),
            if (badgeCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColor.authError,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(
                      fontFamily: DiscoveryText.family,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: AppColor.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// All / Open / Mine, in the flow's chip.
class _BoardFilters extends StatelessWidget {
  const _BoardFilters({required this.current, required this.onSelect});

  final BoardFilter current;
  final ValueChanged<BoardFilter> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          DiscoveryFilterChip(
            label: 'All',
            isSelected: current == BoardFilter.all,
            onTap: () => onSelect(BoardFilter.all),
          ),
          const SizedBox(width: 8),
          DiscoveryFilterChip(
            label: 'Open',
            isSelected: current == BoardFilter.open,
            onTap: () => onSelect(BoardFilter.open),
          ),
          const SizedBox(width: 8),
          DiscoveryFilterChip(
            label: 'Mine',
            isSelected: current == BoardFilter.mine,
            onTap: () => onSelect(BoardFilter.mine),
          ),
        ],
      ),
    );
  }
}
