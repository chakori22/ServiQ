import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:local_markerplace/basket/app_bottom_bar.dart';
import 'package:local_markerplace/components/app_back_button.dart';
import 'package:local_markerplace/components/motion/entrance.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/core/app_routes.dart';
import 'package:local_markerplace/dashboard/model/post_details.dart';
import 'package:local_markerplace/dashboard/model/post_offer.dart';
import 'package:local_markerplace/dashboard/presentation/create_post/components/composer_fields.dart'
    show DashedBorderPainter;
import 'package:local_markerplace/dashboard/presentation/posts/presentation/components/make_offer_sheet.dart';
import 'package:local_markerplace/dashboard/presentation/posts/presentation/components/offer_card.dart';
import 'package:local_markerplace/dashboard/presentation/posts/presentation/components/requirement_card.dart'
    show authorInitials, requirementDetail, requirementHeadline, scheduledLabel;
import 'package:local_markerplace/dashboard/repository/post_offer_repository.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_assets.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_filter_chip.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_tab_bar.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/discovery/presentation/components/provider_avatar.dart';
import 'package:local_markerplace/discovery/presentation/components/status_pill.dart';
import 'package:local_markerplace/visit/model/visit_service.dart';
import 'package:local_markerplace/visit/presentation/visit_booked_page.dart';
import 'package:local_markerplace/visit/repository/visit_repository.dart';

/// 09 · 03 / 04 — one requirement and the offers on it.
///
/// The same screen serves both of the design's states: with offers it lists
/// them, and without it says so and offers a way to spread the word instead
/// of leaving the seeker on an empty page.
class RequirementPage extends StatefulWidget {
  const RequirementPage({
    super.key,
    required this.post,
    this.localityName,
    this.currentUsername,
    this.onOfferMade,
    this.onOfferAccepted,
    this.onClosed,
    this.offers,
    this.visits,
  });

  final PostDetails post;

  /// The area the requirement was posted in, for the line under the chips.
  final String? localityName;

  /// The signed-in user's handle. Whoever posted the requirement is the only
  /// one who can accept an offer on it; everybody else can make one.
  final String? currentUsername;

  /// Told when an offer is made here, so the board can move its count.
  final ValueChanged<PostOffer>? onOfferMade;

  /// Told when the owner accepts, so the board can settle the requirement.
  final ValueChanged<PostOffer>? onOfferAccepted;

  /// The seeker took their own requirement down. Null where the screen has
  /// nobody to tell, and then closing is left off the menu.
  final VoidCallback? onClosed;

  /// Defaults to the shared store, which is where offers made anywhere in
  /// the session are kept.
  final PostOfferRepository? offers;

  /// Where an accepted offer's visit is built. Defaults to the shared store
  /// so it is the same visit the category flow adds to.
  final VisitRepository? visits;

  @override
  State<RequirementPage> createState() => _RequirementPageState();
}

class _RequirementPageState extends State<RequirementPage> {
  late final PostOfferRepository _offers =
      widget.offers ?? PostOfferRepository.shared;

  late final VisitRepository _visits = widget.visits ?? VisitRepository.shared;

  /// The page's own copy, so accepting settles it here immediately rather
  /// than waiting for the board underneath to rebuild.
  late PostDetails _post = widget.post;

  bool get _isMine => _post.isPostedBy(widget.currentUsername);

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

  Future<void> _makeOffer() async {
    final handle = widget.currentUsername?.trim() ?? '';
    final offer = await showMakeOfferSheet(
      context,
      offeredBy: handle.isEmpty ? 'You' : handle,
    );
    if (offer == null || !mounted) return;

    _offers.add(_post, offer);
    setState(() => _post = _post.copyWith(acceptCount: _post.acceptCount + 1));
    widget.onOfferMade?.call(offer);
    _notice('Offer sent.');
  }

  /// Taking an offer books the visit outright.
  ///
  /// Everything the visit flow normally asks for was settled by the offer
  /// itself: the provider named the price and the time, and accepting agreed
  /// to both. Sending the seeker to the slot picker afterwards would ask
  /// them to decide something they had just decided, so the requirement goes
  /// straight to a booked visit.
  Future<void> _accept(PostOffer offer) async {
    setState(
      () => _post = _post.copyWith(isAccepted: true, acceptedBy: offer.name),
    );
    widget.onOfferAccepted?.call(offer);

    final booked = _visits.bookFromOffer(
      providerName: offer.name,
      providerLine: [?widget.localityName, 'agreed ${offer.price}'].join(' · '),
      isVerifiedProvider: offer.badge == OfferBadge.verified,
      agreedWhen: _capitalised(offer.timing),
      service: VisitService(
        name: requirementHeadline(_post.description),
        detail: requirementDetail(_post.description) ?? '',
        unitPrice: rupeesFrom(offer.price),
      ),
    );
    if (!mounted) return;

    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => VisitBookedPage(visit: booked)));
    if (mounted) setState(() {});
  }

  /// Offers are written mid-sentence ("today, 4 – 6 pm"); the booked screen
  /// shows the timing as a heading of its own.
  static String _capitalised(String text) =>
      text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);

  /// The only thing in the menu so far, and only on your own post: taking
  /// it down. Closing is separate from accepting — a job can be settled, or
  /// simply no longer needed.
  Future<void> _openMenu() async {
    if (!_isMine || _post.isClosed) {
      return _notice('More options — coming soon.');
    }

    final close = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColor.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('This post', style: DiscoveryText.sheetTitle),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              child: Text(
                'Closing takes it off the board. Offers already made stay in '
                'your posts.',
                style: DiscoveryText.caption,
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.do_not_disturb_on_outlined,
                color: AppColor.authError,
              ),
              title: Text(
                'Close this post',
                style: DiscoveryText.sheetOptionDanger,
              ),
              onTap: () => Navigator.of(context).pop(true),
            ),
            ListTile(
              leading: const Icon(
                Icons.close_rounded,
                color: AppColor.discoveryTextTertiary,
              ),
              title: Text('Keep it open', style: DiscoveryText.sheetOption),
              onTap: () => Navigator.of(context).pop(false),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (close != true || !mounted) return;

    setState(() => _post = _post.copyWith(isClosed: true));
    widget.onClosed?.call();
    _notice('Post closed.');
  }

  @override
  Widget build(BuildContext context) {
    final received = _offers.offersOn(_post);

    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(onMore: _openMenu),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: FadeSlideIn(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        requirementHeadline(_post.description),
                        style: DiscoveryText.requirementTitle,
                      ),
                      const SizedBox(height: 14),
                      _AuthorRow(post: _post, isMine: _isMine),
                      const SizedBox(height: 14),
                      _MetaChips(post: _post),
                      const SizedBox(height: 12),
                      Text(
                        _postedLine(_post, widget.localityName),
                        style: DiscoveryText.footnoteStrong,
                      ),
                      if (requirementDetail(_post.description) != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          requirementDetail(_post.description)!,
                          style: DiscoveryText.body,
                        ),
                      ],
                      const SizedBox(height: 18),
                      // The design's requirement carries no photo, but a post
                      // in this app does, and it is usually the clearest
                      // thing about the job.
                      _RequirementPhoto(imageUrl: _post.imageUrl),
                      const SizedBox(height: 20),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColor.discoveryBorder,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              if (received.isEmpty)
                _NoOffers(
                  onShare: () =>
                      _notice('Sharing a requirement — coming soon.'),
                )
              else
                _Offers(
                  offers: received,
                  // Only the seeker who posted it decides, and only while it
                  // is still open.
                  canAccept: _isMine && !_post.isAccepted && !_post.isClosed,
                  // On the seeker's own closed post the work is done, so
                  // Accept is shown greyed rather than taken away. On
                  // somebody else's it was never theirs to press.
                  showDisabledAccept: _isMine && _post.isClosed,
                  onAccept: _accept,
                ),
              if (!_isMine && !_post.isAccepted && !_post.isClosed) ...[
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _MakeOfferButton(onTap: _makeOffer),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomBar(
        current: DiscoveryTab.posts,
        onSelect: (tab) {
          // Popping twice would be needed to reach the shell from here, so
          // the board above is left to forward the chosen tab on.
          Navigator.of(context).pop(tab);
        },
        onPost: () => GoRouter.of(
          context,
        ).pushAppRoute(AppRoutes.instantForm, extra: widget.localityName),
      ),
    );
  }
}

/// Who posted the requirement. Every one of these is somebody asking
/// somebody else for help, so the ask is worth a face and a name.
class _AuthorRow extends StatelessWidget {
  const _AuthorRow({required this.post, required this.isMine});

  final PostDetails post;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ProviderAvatar(
          initials: authorInitials(post.username),
          seed: post.username,
          size: 34,
          isVerified: false,
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            post.username,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: DiscoveryText.rowTitle,
          ),
        ),
        if (isMine) ...[
          const SizedBox(width: 8),
          const StatusPill.comingSoon(label: 'YOU'),
        ],
      ],
    );
  }
}

/// The way in for everybody who did not post the requirement.
class _MakeOfferButton extends StatelessWidget {
  const _MakeOfferButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      pressedScale: 0.97,
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [
              AppColor.discoveryGradientStart,
              AppColor.discoveryGradientEnd,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColor.discoveryGradientEnd.withValues(alpha: 0.30),
              blurRadius: 11,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Text(
          'Make an offer',
          style: DiscoveryText.onAccent(16.5, letterSpacing: -0.165),
        ),
      ),
    );
  }
}

String _postedLine(PostDetails post, String? localityName) => [
  ?localityName,
  post.isInstant ? 'needed now' : scheduledLabel(post.scheduledTime),
  'posted ${post.timeAgoText}',
].join(' · ');

class _Header extends StatelessWidget {
  const _Header({required this.onMore});

  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 20, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppBackButton(),
            const Spacer(),
            PressableScale(
              onTap: onMore,
              pressedScale: 0.85,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
                child: SvgPicture.asset(
                  DiscoveryAssets.more,
                  width: 4,
                  height: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The requirement's state, then its terms, as the design's row of chips.
class _MetaChips extends StatelessWidget {
  const _MetaChips({required this.post});

  final PostDetails post;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Closed wins over accepted, the same way the card reads it.
        if (post.isClosed)
          const StatusPill.closed()
        else if (post.isAccepted)
          const StatusPill.accepted()
        else
          const StatusPill.open(),
        DiscoveryFilterChip(label: '₹${post.budgetAmount.toStringAsFixed(0)}'),
        DiscoveryFilterChip(label: post.paymentMode),
      ],
    );
  }
}

class _RequirementPhoto extends StatelessWidget {
  const _RequirementPhoto({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 190,
        width: double.infinity,
        child: imageUrl.startsWith('assets/')
            ? Image.asset(imageUrl, fit: BoxFit.cover)
            : Image.file(
                File(imageUrl),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const ColoredBox(color: AppColor.providerMapFill),
              ),
      ),
    );
  }
}

/// The offers, under a count and the one line that explains what the badges
/// are worth.
class _Offers extends StatelessWidget {
  const _Offers({
    required this.offers,
    required this.canAccept,
    required this.showDisabledAccept,
    required this.onAccept,
  });

  final List<PostOffer> offers;

  /// True only for the seeker who posted the requirement, and only while it
  /// is still open. Everybody else reads the offers without acting on them.
  final bool canAccept;

  /// Draws Accept greyed instead of leaving it off — the requirement is
  /// theirs, but it is over.
  final bool showDisabledAccept;

  final ValueChanged<PostOffer> onAccept;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${offers.length} ${offers.length == 1 ? 'offer' : 'offers'}',
            style: DiscoveryText.sectionTitle,
          ),
          const SizedBox(height: 6),
          Text(
            'VERIFIED means ID and GST are both on file',
            style: DiscoveryText.metaMuted,
          ),
          const SizedBox(height: 16),
          for (final (index, offer) in offers.indexed) ...[
            if (index > 0) const SizedBox(height: 12),
            OfferCard(
              offer: offer,
              index: index,
              onAccept: canAccept ? () => onAccept(offer) : null,
              isDisabled: showDisabledAccept,
            ),
          ],
        ],
      ),
    );
  }
}

/// Nothing has come in yet — say so, say what happens next, and offer the one
/// thing the seeker can actually do about it.
class _NoOffers extends StatelessWidget {
  const _NoOffers({required this.onShare});

  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: FadeSlideIn(
        index: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Offers', style: DiscoveryText.sectionTitle),
            const SizedBox(height: 16),
            CustomPaint(
              painter: const DashedBorderPainter(radius: 18),
              child: Container(
                padding: const EdgeInsets.fromLTRB(30, 28, 30, 28),
                decoration: BoxDecoration(
                  color: AppColor.providerHeroMid,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColor.artBlueLight,
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        DiscoveryAssets.bell,
                        width: 26,
                        height: 26,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text('No offers yet', style: DiscoveryText.emptyTitle),
                    const SizedBox(height: 8),
                    Text(
                      'Providers nearby have been notified. Most posts get a '
                      'first offer within an hour.',
                      textAlign: TextAlign.center,
                      style: DiscoveryText.footnote.copyWith(height: 17 / 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _ShareButton(onTap: onShare),
          ],
        ),
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  const _ShareButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      pressedScale: 0.97,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColor.discoveryAccent.withValues(alpha: 0.35),
            width: 1.6,
          ),
        ),
        child: Text(
          'Share with neighbours',
          style: DiscoveryText.outlinedAction,
        ),
      ),
    );
  }
}
